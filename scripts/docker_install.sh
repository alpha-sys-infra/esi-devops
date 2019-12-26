#!/bin/bash
set -e

#uninstall docker if exist
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
if [ `rpm -qa|grep docker|wc -l` -eq 0 ] ;
then
echo "############################"
echo "No Docker Version Installed!"
echo "############################"
else
rpm -e --nodeps $(rpm -qa|grep docker)
echo "#######################"
echo "Old Version Uninstalled"
echo "#######################"
fi
                                  
#install requirements
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

#setup repo
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

#list docker versions
yum list docker-ce --showduplicates | sort -r| grep 'el7'|awk {'print $2'}|grep '^3'|awk -F [:-] {'print $2'}
verrepo=`yum list docker-ce --showduplicates | sort -r| grep 'el7'|awk {'print $2'}|grep '^3'|awk -F [:-] {'print $2'}`
#read a version from keyboard
echo "##########################################################"
echo "select a version from above and type it down，like 19.03.5"
echo "##########################################################"
while true
do
read -p "Input a Version:" ver
if [ ${#ver} = 7 ] ;
then
 if [[ $verrepo =~ $ver ]];
  then 
  sudo yum install -y docker-ce-$ver docker-ce-cli-$ver containerd.io
  break
 else
  echo "###############################"
  echo "input error, input like 19.03.5"
  echo "###############################"
 fi
else
echo "###############################"
echo "input error, input like 19.03.5"
echo "###############################"
fi
done

#start docker service
echo "###############################"
echo "Starting Docker Service"
echo "###############################"
sudo systemctl start docker
ps -ef|grep docker|grep -v grep
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
docker version
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

if [ `ps -ef|grep docker |grep -v grep|wc -l`> 0 ] ;
then
echo "#######################"
echo "Docker Install Success!"
echo "#######################"
else
echo "######################"
echo "Docker Install Failed!"
echo "######################"
fi