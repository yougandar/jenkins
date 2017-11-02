#!/bin/bash
#Date - 26102017
#Developer - Sysgain
#setting the variables#
DATE=`date +%Y%m%d%T`
LOG=/tmp/jenkins_deploy.log.$DATE
srcdir="/usr/share/jenkins"
jenkinsdir="/var/lib/jenkins"
user="admin"
passwd=`cat /var/lib/jenkins/secrets/initialAdminPassword`
url="localhost:8080"
#for installing hxselect#
sudo apt-get update
sudo apt install -y html-xml-utils
sleep 20
#setting the permissions
sudo chmod 777 /var/lib/jenkins/secrets
sudo chmod 777 /var/lib/jenkins/secrets/initialAdminPassword
#Download the Required Jenkins Files
echo "---Download the Required Jenkins Files---" >> $LOG
wget -P /usr/share/jenkins https://raw.githubusercontent.com/yougandar/test/master/configfile1.xml >> $LOG
sleep 20
#Configuring Jenkins
echo "---Configuring Jenkins---"
#sudo wget http://$url/jnlpJars/jenkins-cli.jar
#sudo cp jenkins-cli.jar $srcdir
#sudo wget -P $srcdir http://$url/jnlpJars/jenkins-cli.jar
wget -P /usr/share/jenkins http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar $srcdir/jenkins-cli.jar -s http://$url who-am-i --username $user --password $passwd
api=`curl --silent --basic http://$user:$passwd@$url/user/admin/configure | hxselect '#apiToken' | sed 's/.*value="\([^"]*\)".*/\1\n/g'`
CRUMB=`curl 'http://'$user':'$api'@'$url'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'`
echo $api
echo $CRUMB
sleep 30 
java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd 
sleep 30  
curl -X POST "http://$user:$api@$url/createItem?name=GameofLifeJob" --data-binary "@$srcdir/configfile1.xml" -H "$CRUMB" -H "Content-Type: text/xml"
