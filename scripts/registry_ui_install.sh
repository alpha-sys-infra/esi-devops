#!/bin/bash
set -e

echo "###############################################################"
echo "If you installed this ui before, delete it and backup manually!"
echo "Installation will start in 10 seconds....."
echo "###############################################################"
sleep 15

echo "#####################################################"
echo "Input your registry url, like http://192.168.x.x:5000"
echo "#####################################################"
read -p "input:" url

echo "########################################"
echo "Input your registry username, like admin"
echo "########################################"
read -p "input:" username

echo "############################"
echo "Input your registry password"
echo "############################"
read -p "input:" password

echo "####################################"
echo "Input your prefer ui port, like 8000"
echo "####################################"
read -p "input:" port

echo "##########################################################"
echo "Input your prefer storage location, like /home/registry-ui"
echo "##########################################################"
read -p "input:" location
rm -rf ${location}
mkdir -p ${location}/{config,data}
cat > ${location}/config/config.yml <<EOF
listen_addr: 0.0.0.0:8000
base_path: /
registry_url: $url
verify_tls: false
registry_username: $username
registry_password: $password
event_listener_token: token
event_retention_days: 7
event_database_driver: sqlite3
event_database_location: data/registry_events.db
event_deletion_enabled: True
cache_refresh_interval: 10
anyone_can_delete: false
admins: [${username}]
debug: true
purge_tags_keep_days: 90
purge_tags_keep_count: 2
EOF

docker run -it -d -p 8000:8000 -v ${location}/config/config.yml:/opt/config.yml:ro -v ${location}/data:/opt/data \
    --name=registry-ui quiq/docker-registry-ui
if [[ `docker ps |grep "registry-ui"|wc -l` >0 ]];
then
echo "##################################################"
echo "Install Success! Touch it by http://yourip:${port}"
echo "##################################################"
else 
echo "###############"
echo "Install Failed!"
echo "###############"
fi