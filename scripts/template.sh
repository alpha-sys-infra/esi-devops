#!/bin/bash
set -e

#parameter
#容器名
container_name=$1

#cpu资源限制
cpu_limit=$2
cpu_prev=$3

#volume路径
data_name=$4

#公网IP 
ip_address=$5

#内存资源限制
memo_limit=$6
memo_prev=$7

#容器暴露端口
expose_port=$8

#nginx暴露端口
export_port=$9

#镜像名:标签
service_image=${10}

#服务名
service_name=${11}

#服务重启策略
service_restart_policy=${12}

#容器基础发行版
service_env=${13}

#代码库
gitrepo=${14}

#代码分支
gitbranch=${15}

#容器初始命令
cmd=${16}

#打包镜像
rm -rf /tmp/tempworkspace
mkdir /tmp/tempworkspace && cd /tmp/tempworkspace
git clone $gitrepo -b $gitbranch
route=`ls`
cd $route

cat > Dockerfile <<EOF
From $service_env
MAINTAINER goodgame
RUN apt-get update && \
    apt-get -y install curl && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -y install python build-essential nodejs
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /src && cp -a /tmp/node_modules /src/
WORKDIR /src
ADD . /src
EXPOSE ${expose_port}
CMD ["node", "${cmd}"]
EOF

docker build -t 192.168.16.5:5000/${service_image} .
docker login -u admin -p admin 192.168.16.5:5000
docker push 192.168.16.5:5000/${service_image}
docker logout 192.168.16.5:5000

rm -rf /tmp/tempworkspace

#创建相关文件夹
mkdir -p /home/${service_name}
mkdir -p /data/${service_name}/svcdata
mkdir -p /data/${service_name}/redisdata
mkdir -p /data/${service_name}/nginxconf

#创建nginx配置文件
cat > /data/${service_name}/nginxconf/svc.conf<<EOF
server {
              listen 8090;
              location / {
                proxy_pass http://${service_name}:${expose_port};
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host \$host;
                proxy_cache_bypass \$http_upgrade;
              }
        }
EOF

#创建docker-compose.yaml
cd /home/${service_name}
cat > docker-compose.yaml<<EOF
version: '3.7'
services:
  nginx:
    image: nginx
    links:
      - ${service_name}
    ports:
      - ${export_port}:8090
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /data/${service_name}/nginxconf:/etc/nginx/conf.d
  
  ${service_name}:
    image: 192.168.16.5:5000/${service_image}
    container_name: ${container_name}
    volumes:
      - /data/${service_name}/svcdata:${data_name}
    restart: ${service_restart_policy}
    deploy:
      resources:
        limits:
          cpus: '${cpu_limit}'
          memory: ${memo_limit}M
        reservations:
          cpus: '${cpu_prev}'
          memory: ${memo_prev}M
    expose:
      - ${expose_port}
    links:
     - redis
    
  redis:
    image: redis 
    restart: always
    command: --appendonly yes
    expose:
      - 6379
    volumes:
      - /data/${service_name}/redisdata:/data
EOF

#启动服务
#  --compatibility
docker-compose up -d
docker-compose ps
