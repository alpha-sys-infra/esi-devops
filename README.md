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
