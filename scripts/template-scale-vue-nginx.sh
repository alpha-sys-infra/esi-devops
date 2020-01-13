#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
source ~/.nvm/nvm.sh
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

# #容器基础发行版
# service_env=${13}

#代码库
gitrepo=${13}

#代码分支
gitbranch=${14}

#容器初始命令
cmd=${15}

#打包镜像
rm -rf /tmp/tempworkspace
mkdir /tmp/tempworkspace && cd /tmp/tempworkspace
git clone $gitrepo -b $gitbranch
route=`ls`
cd $route

# 切换nodejs版本
nvm install v11.15.0
nvm use v11.15.0

npm install
npm run-script build

#创建nginx配置文件
cat > ${service_name}.conf<<EOF
server {
              listen ${expose_port};
              root /var/www/html/front/${service_name}/;
              location / {
                try_files \$uri \$uri/  /index.html;
              }
        }
EOF

# 创建dockerfile文件
cat > Dockerfile << EOF
FROM nginx:1.17.7
COPY --chown=1000:1000 ./dist/ /var/www/html/front/${service_name}/
COPY ./${service_name}.conf /etc/nginx/conf.d/
EXPOSE ${expose_port}

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

#创建docker-compose.yaml
cd /home/${service_name}
cat > docker-compose.yaml<<EOF
version: '3.7'
services:  
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
    ports:
      - ${export_port}:${expose_port}
EOF

#启动服务
#  --compatibility
docker-compose up -d
docker-compose ps
