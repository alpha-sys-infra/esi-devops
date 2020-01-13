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

#代码库
gitrepo=${13}

#代码分支
gitbranch=${14}

#打包镜像
rm -rf /tmp/tempworkspace/
mkdir /tmp/tempworkspace && cd /tmp/tempworkspace

git clone $gitrepo --branch $gitbranch --depth 1
cd city-fire/target

cat > Dockerfile <<EOF
From java:8
Maintainer goodgame
COPY ${service_name}.jar /home/
RUN mkdir -p /home/logs/
WORKDIR /home
EXPOSE ${expose_port}
CMD ["/bin/sh","-c","nohup java -jar ${service_name}.jar --server.port=${expose_port} >>./logs/${service_name}.log 2>&1"]
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
mkdir -p /data/logs/${service_name}
#创建docker-compose.yaml
cd /home/${service_name}
cat > docker-compose.yaml<<EOF
version: '3.7'
services:
  lb:
    image: dockercloud/haproxy
    links:
      - ${service_name}
    ports:
        - ${export_port}:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
  
  ${service_name}:
    image: 192.168.16.5:5000/${service_image}
    volumes:
      - /data/${service_name}/svcdata:${data_name}
      - /data/logs/${service_name}:/home/logs
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
EOF

#启动服务
docker-compose up -d
docker-compose ps