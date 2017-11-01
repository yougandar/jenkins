#!/bin/bash
DATE=`date +%Y%m%d%T`
LOG=/tmp/jenkins_deploy.log.$DATE
srcdir="/usr/share/jenkins"
jenkinsdir="/var/lib/jenkins"
user="admin"
passwd=`cat /var/lib/jenkins/secrets/initialAdminPassword`
url="localhost:8080"
#for installing hxselect#
sudo apt-get update
sudo apt install -y html-xml-utils >> $LOG
sleep 20
#setting the permissions
sudo chmod 777 /var/lib/jenkins/secrets >> $LOG
sudo chmod 777 /var/lib/jenkins/secrets/initialAdminPassword >> $LOG
#Download the Required Jenkins Files
echo "---Download the Required Jenkins Files---" >> $LOG
wget -P /usr/share/jenkins https://raw.githubusercontent.com/yougandar/test/master/job-configfile.xml >> $LOG
#Configuring Jenkins
echo "---Configuring Jenkins---"
cd /home/ubuntu/
curl -L -O http://localhost:8080/jnlpJars/jenkins-cli.jar >> $LOG
sudo cp ./jenkins-cli.jar /usr/share/jenkins/ >> $LOG
#wget -P /usr/share/jenkins http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar $srcdir/jenkins-cli.jar -s http://$url who-am-i --username $user --password $passwd >> $LOG
api=`curl --silent --basic http://$user:$passwd@$url/user/admin/configure | hxselect '#apiToken' | sed 's/.*value="\([^"]*\)".*/\1\n/g'` >> $LOG
CRUMB=`curl 'http://'$user':'$api'@'$url'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'` >> $LOG
echo $api >> $LOG
echo $CRUMB >> $LOG
#creating jenkins user
sleep 30 
java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd
sleep 30  
curl -X POST "http://$user:$api@$url/createItem?name=GameofLifeJob" --data-binary "@$srcdir/job-configfile.xml" -H "$CRUMB" -H "Content-Type: text/xml"
