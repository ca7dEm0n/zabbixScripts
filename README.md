# Zabbix Scripts

### alertscripts
用于存储告警脚本

### docker-zabbix
替换修改`zabbix-server`服务启动，基于`Docker`下的一键部署.

### script
用于存放各告警脚本.

### 更新日志

- 2018年12月07日  新增端口自发现脚本
> conf: UserParameter=port_server_discover[*],/usr/local/zabbix/scripts/lld-port-server.sh $1
