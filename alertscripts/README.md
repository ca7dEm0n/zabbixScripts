# 文件说明

### Emaill.py
* ZabbixAction 配置
```
Default message

HOST.HOST1:{HOST.HOST1}|HOST.IP1:{HOST.IP1}|EVENT.DATE:{EVENT.DATE}|EVENT.TIME:{EVENT.TIME}|TRIGGER.SEVERITY:{TRIGGER.SEVERITY}|TRIGGER.NAME:{TRIGGER.NAME}|ITEM.KEY1:{ITEM.KEY1}|ITEM.NAME1:{ITEM.NAME1}|ITEM.VALUE1:{ITEM.VALUE1}|ITEM.ID:{ITEM.ID}|TRIGGER.STATUS:{TRIGGER.STATUS}
```

* Media types
```
{ALERT.SENDTO}
{ALERT.SUBJECT}
{ALERT.MESSAGE}
```
* 其他配置
```
Emaill.py
	# 配置USER	-	zabbix登录账号，需要有相应权限
	# 配置PASSWD	-	zabbix登录密码
	# 配置HOST	-	zabbix域名
	# 配置logPng	-	公司log
	# 配置MAILNAME	-	邮箱名
	# 配置MAILUSER	-	邮箱账号
	# 配置MAILPASS	-	邮箱密码
	# 配置SMTPSERVER	-	邮箱服务器

crontab 配置一个定期删除图片文件
*/5 * * * * find /tmp  -cmin +1 -name 'zabbix-graph-itemID*' -delete
```

### webWechat.sh
* ZabbixAction 配置
```
Default message

{TRIGGER.NAME}|{ITEM.ID}|{TRIGGER.URL}|{TRIGGER.STATUS}
```
* Media types
```
{ALERT.SENDTO}
{ALERT.SUBJECT}
{ALERT.MESSAGE}
```
* 其他配置
```
webWechat.sh
	# 配置CropID
	# 配置Secret
```

### wechat.sh

* ZabbixAction 配置
```
Default message

Zabbix系统监控中心\n
故障通知\n
告警主机: {HOST.HOST1}({HOST.IP1})\n
告警时间: {EVENT.DATE} {EVENT.TIME}\n
告警等级: {TRIGGER.SEVERITY}\n
告警信息: {TRIGGER.NAME}\n
告警项目: {ITEM.KEY1}\n
问题详情: {ITEM.NAME1}:{ITEM.VALUE1}\n
当前状态: {TRIGGER.STATUS}\n
事件ID: {EVENT.ID}\n
```
* Media types
```
{ALERT.SENDTO}
{ALERT.SUBJECT}
{ALERT.MESSAGE}
```
* 其他配置
```
wechat.sh
	# 配置CropID
	# 配置Secret
```


### phoneCall.py
* ZabbixAction 配置
```
Default message

{HOST.HOST1}

# 不勾选回复信息 (Recovery message)
```
* Media types
```
{ALERT.SENDTO}
{ALERT.MESSAGE}
```
* 其他配置
```
phoneCall.py
	# 配置accountSid
	# 配置appId
	# 配置userToken
	# 配置toSerNum

采用接口商：http://www.ucpaas.com
```

### sms.sh
* ZabbixAction 配置
```
Default message

故障通知：{TRIGGER.NAME},{EVENT.DATE}-{EVENT.TIME}
```
* Media types
```
{ALERT.SENDTO}
{ALERT.MESSAGE}
```
* 其他配置
```
function.php
	# 配置 $id
	# 配置 $pwd

采用接口商：http://winic.org/
```


