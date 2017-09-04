#/bin/bash
mobile="$1"
content=`echo $2|sed -e "s/\ /-/g"`
date=`date "+ %Y/%m/%d %H:%M:%S"`
sendphp="/usr/local/zabbix/share/zabbix/alertscripts/sms/msg.php"
/usr/bin/php $sendphp $mobile $content
echo $date  $mobile $content >> /tmp/sms.log
