#!/bin/bash
set -e

# test if docker-compose exits
num=$(command -v docker-compose | wc -l)
echo $num
if [[ $num = 1 ]]; 
then 
 echo "###########################################"
 echo "docker-compose already exits, see following"
 echo "###########################################"
 docker-compose version
 echo "#########################################"
 echo "wanna install latest version? type y or n"
 echo "#########################################"
 read -p "input your selection:" choose
 case $choose in 
 "n")
   echo "##########"
   echo "exiting..."
   echo "##########"
   exit
   ;;
 "y")
   rm -f $(which docker-compose)
   ver=$(curl -X GET https://api.github.com/repos/docker/compose/tags |grep "name"|grep -v docs|grep -v rc|awk -F[\"] {'print $4'}|sort -rV|head -n 1)
   echo $ver
   sudo curl -L "https://github.com/docker/compose/releases/download/$ver/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   ;;
 esac
else
   echo "#########################" 
   echo "Installing docker-compose"
   echo "#########################" 
   ver=$(curl -X GET https://api.github.com/repos/docker/compose/tags |grep "name"|grep -v docs|grep -v rc|awk -F[\"] {'print $4'}|sort -rV|head -n 1)
   echo $ver
   sudo curl -L "https://github.com/docker/compose/releases/download/$ver/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose 
fi
echo "######################" 
echo "docker-compose version"
echo "######################" 
docker-compose version

echo "################" 
echo "Install Success!"
echo "################"