# esi-devops

运维脚本

## 目录结构

```markup
--| docker
----| mongo
------| docker-compose.yml __ mongodb 容器的docker-compose
----| mysql
------| docker-compose.yml __ mysql 容器的docker-compose
--| scripts
----| docker_compose_install.sh __ docker compose安装脚本
----| docker_install.sh __ docker安装脚本
----| registry_install.sh __ docker registry安装脚本
----| registry_ui_install.sh __ registry ui安装脚本
----| template-scale-java.sh __ city-fire项目后端部署模板
----| template-scale-vue-nginx.sh __ city-fire项目前端部署模板
----| template-scale.sh __ redis scale模板
----| template.sh __ nodejs微服务生成容器脚本
--| test
----| template.test.sh __ template.sh的测试脚本
----| template-scale-java.test.sh __ template-scale-java.test.sh的测试脚本
----| template-scale-vue-nginx.test.sh __ template-scale-vue-nginx.test.sh的测试脚本
----| template-scale.test.sh __ template-scale.sh的测试脚本
```

## docker registry

- 外网 IP 106.12.161.226
- 内网 IP 192.168.16.5
- 端口 5000

## docker registry UI

- 外网 IP 106.12.161.226
- 内网 IP 192.168.16.5
- 端口 8000
- url [http://106.12.161.226:8000/](http://106.12.161.226:8000/)

## 数据库

### redis

- IP 180.76.155.25
- 端口 6379

### mysql

- IP 180.76.155.25
- 端口 3306
- 默认账号 root
- root 账号密码 Admin123
- 数据库文件路径 /data/mysql/data
- 数据库配置文件 /data/mysql/conf

### mongoDB

- IP 180.76.155.25
- 端口 27017
- 默认账号 无
- 数据库文件路径 /home/mongodb/data/db

## city-fire

### 后端

- IP 180.76.155.25
- 端口 8080
- url [http://180.76.155.25:8080/](http://180.76.155.25:8080/)

### 前端

- IP 180.76.155.25
- 端口 8081
- url [http://180.76.155.25:8081/](http://180.76.155.25:8081/)
