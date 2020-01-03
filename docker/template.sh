#!/bin/bash
set -e

#parameter
container_name=$1
cpu_limit=$2
cpu_prev=$3
data_name=$4
ip_address=$5
memo_limit=$6
memo_prev=$7
port=$8
service_image=$9
service_name=$10
service_restart_policy=$11
service_env=$12
gitrepo=$13
gitbranch=$14

#build a docker image
mkdir /tmp/tempworkspace $$ cd /tmp/tempworkspace
git clone $gitrepo -b $gitbranch
route=`ls`
cd $route

cat > Dockerfile <<EOF
From $service_env
Maintainer goodgame
RUN apt-get update && \
    apt-get -y install curl && \
    curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - && \
    apt-get -y install python build-essential nodejs
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /src && cp -a /tmp/node_modules /src/
WORKDIR /src
ADD . /src
EXPOSE ???
CMD ["node", "/src/index.js"]
EOF

docker build -t 192.168.16.5:5000/${service_image} .
docker login -u admin -p admin 192.168.16.5:5000
docker push 192.168.16.5:5000/${service_image}
docker logout 192.168.16.5:5000

rm -rf /tmp/tempworkspace
#start a container

cat > /home/docker-compose.yaml<<EOF
version: '3.7'
services:
  ${service_name}:
    image: 192.168.16.5:5000/${service_image}
    container_name: ${container_name}
    ports:
      - ${port}:???
    volumes:
      - ${data_name}:???
    restart: ${service_restart_policy}
    deploy:
      resources:
        limits:
          cpus: ${cpu_limit}
          memory: ${memo_limit}
        reservations:
          cpus: ${cpu_prev}
          memory: ${memo_prev}
    networks:
        - ???
volumes:
  ${data_name}:
networks:
  ???
EOF

cd /home/
docker-compose up -d --compatibility
docker-compose ps