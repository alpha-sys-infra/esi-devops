#!/bin/bash
set -e
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
echo "#####################################################################"
echo "Input your prefer registry storage location, like /home/registry-data"
echo "#####################################################################"
read -p "input:" location

#start container
docker run -d \
        -e STORAGE_PATH=/registry \
        -p ${port}:5000 \
        -v ${location}:/var/lib/registry \
        --restart=always \
        --name docker-registry \
        registry:latest

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

echo "################################################"
echo "Install Registry Success! URL: ${ipaddr}:${port}"
echo "################################################"
echo "start to test the registry, push a busybox"
echo "##########################################"
docker pull busybox
docker tag busybox:latest ${ipaddr}:${port}/busybox:latest
docker push ${ipaddr}:${port}/busybox:latest
echo "#########################################"
echo "curl http://${ipaddr}:${port}/v2/_catalog"
echo "#########################################"
curl http://${ipaddr}:${port}/v2/_catalog
echo "#############"
echo "Push Success!"
echo "#############"