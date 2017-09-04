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
* 额外配置
```
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