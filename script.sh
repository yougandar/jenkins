#!/bin/bash
#Date - 26102017
#Developer - Sysgain

DATE=`date +%Y%m%d%T`
LOG=/tmp/jenkins_deploy.log.$DATE
srcdir="/usr/share/jenkins"
jenkinsdir="/var/lib/jenkins"
user="admin"
passwd=`cat /var/lib/jenkins/secrets/initialAdminPassword`
url="localhost:8080"

sudo apt-get update
sudo apt-get install -y default-jre 
sudo apt-get install -y default-jdk sleep 20
sudo apt-get install html-xml-utils sleep 10
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins 
sudo service jenkins restart

sudo apt install -y firewalld
sudo firewall-cmd --list-ports
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanant
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
sudo service jenkins restart 


#Download the Required Jenkins Files
echo "---Download the Required Jenkins Files---" >> $LOG
sudo wget -P $srcdir https://raw.githubusercontent.com/yougandar/test/master/job-configfile.xml >> $LOG
#Configuring Jenkins
echo "---Configuring Jenkins---"
sudo wget -P $srcdir http://$url/jnlpJars/jenkins-cli.jar
java -jar $srcdir/jenkins-cli.jar -s http://$url who-am-i --username $user --password $passwd
api=`curl --silent --basic http://$user:$passwd@$url/user/admin/configure | hxselect '#apiToken' | sed 's/.*value="\([^"]*\)".*/\1\n/g'`
CRUMB=`curl 'http://'$user':'$api'@'$url'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'`
echo $api
echo $CRUMB
#systemctl restart jenkins && sleep 30
sleep 30 && java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd
#creating jenkins user
sleep 30 && java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd && sleep 30

sudo curl -X POST "http://$user:$api@$url/createItem?name=GameofLifeJob" --data-binary "@$srcdir/job-configfile.xml" -H "$CRUMB" -H "Content-Type: text/xml"

