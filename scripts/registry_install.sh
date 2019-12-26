#!/bin/bash
set -e
echo "######################################################################"
echo "Attention!!!!"
echo "This is an clean installation, will delete all old data and container!"
echo "Make sure you have old-data backup OR press ctrl+c to abort!"
echo "Installation will start 10 seconds later..."
echo "######################################################################"
sleep 20
#remove installation if exits
if [[ `docker ps | grep registry | wc -l` > 0 ]]; 
then
  docker ps | grep registry
  docker stop $(docker ps -a |grep registry|awk {'print $1'})
  docker rm $(docker ps -a |grep registry|awk {'print $1'})
fi

#collect configuration
echo "##########################################"
echo "Input your prefer registry port, like 5000"
echo "##########################################"
read -p "input:" port
echo "################################################################"
echo "Input your prefer registry storage location, like /home/registry"
echo "################################################################"
read -p "input:" location
rm -rf $location
mkdir -p ${location}/{auth,data}
echo "###################################"
echo "Input your prefer registry username"
echo "###################################"
read -p "input:" username
echo "###################################"
echo "Input your prefer registry password"
echo "###################################"
read -p "input:" password
docker run --rm --entrypoint htpasswd registry -Bbn $username $password > ${location}/auth/htpasswd
echo "Password Generated!"
#start container
docker run -d -v ${location}/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" -p ${port}:5000 -v ${location}/data:/var/lib/registry --restart=always  --name docker-registry  registry

# add insecure-registry
sudo mkdir -p /etc/docker
ipaddr=`ifconfig |grep ens192 -A 1|grep inet|awk {'print $2'}`
sudo cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["${ipaddr}:${port}"]
}
EOF

# Restart docker
systemctl daemon-reload
systemctl restart docker

echo "----------------------"
docker ps -a
echo "----------------------"

echo "##################################################"
echo "Install Registry Success! URL: ${ipaddr}:${port}"
echo "##################################################"
echo "start to test the registry, push a busybox"
echo "##########################################"
docker pull busybox
docker tag busybox:latest ${ipaddr}:${port}/busybox:latest
docker login ${ipaddr}:${port} -u $username -p $password
echo "##########"
echo "Logged in!"
echo "##########"
docker push ${ipaddr}:${port}/busybox:latest
echo "####################################################################"
echo "curl --basic -u username:passwd http://${ipaddr}:${port}/v2/_catalog"
echo "####################################################################"
curl --basic -u ${username}:${password} http://${ipaddr}:${port}/v2/_catalog
echo "#############"
echo "Push Success!"
echo "#############"
docker logout ${ipaddr}:${port}
echo "###########"
echo "Logged Out!"
echo "###########"