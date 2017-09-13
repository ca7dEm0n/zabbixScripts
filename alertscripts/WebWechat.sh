#!/bin/bash

# 配置cropid与secretid
CropID=''
Secret=''


# 其他配置信息
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret" 
Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
CONFIG=/usr/local/zabbix/etc/zabbix_server.conf
DBNAME=$(grep -v "^#" ${CONFIG} |grep DBName|sed "s/DBName=//g")
DBPASSWD=$(grep -v "^#" ${CONFIG} |grep DBPassword|sed "s/DBPassword=//g")
SQL=$(printf "mysql --user=%s -p%s" ${DBNAME} ${DBPASSWD})

# 设置间隔
NowTime=$(date +%s)
LastTime=$(expr $NowTime - 86400)

# 格式化传入文本
# 传入的格式：{TRIGGER.NAME}|{ITEM.ID}|{TRIGGER.URL}|{TRIGGER.STATUS}
TriggerName=$(echo $3 |awk -F "|" '{print $1}')
ItemID=$(echo $3 |awk -F "|" '{print $2}')
TriggerURL=$(echo $3 |awk -F "|" '{print $3}')
TriggerStatus=$(echo $3 |awk -F "|" '{print $4}')     

CACHEFILE='/tmp/'${ItemID}

function printTime() {
    date -d @$1 "+%m月%d日 %H:%M:%S"
}

# 获取上一次错误
function LastError() {
    ItemID=$(expr $1 + 1)
    SelectSQL=$(printf "USE zabbix;SELECT h.value,h.clock FROM history_str h WHERE h.itemid='%s' AND h.clock>='%s' AND h.clock<='%s' ORDER BY h.itemid DESC,h.clock DESC LIMIT %s,1;" ${ItemID} ${LastTime} ${NowTime} $2)
    SQLrequest=$(echo ${SelectSQL} |${SQL} )
    echo ${SQLrequest} | sed  "s/value\|clock//g"
}

function LastCode() {
    ItemID=$(expr $1 + 4)
    SelectSQL=$(printf "USE zabbix;SELECT value FROM history_uint h WHERE h.itemid='%s' ORDER BY h.clock DESC LIMIT 1;"  ${ItemID})
    SQLrequest=$(echo ${SelectSQL} |${SQL} )
    echo ${SQLrequest} | sed "s/value//g"
}

# 微信请求头
function body() {
        local int AppID=10                        #企业号中的应用id
        local UserID=$1                          #部门成员id，zabbix中定义的微信接收者
#        local PartyID=5                          #部门id，定义了范围，组内成员都可接收到消息
        local Msg=$(echo "$@" | cut -d" " -f3-)  #过滤出zabbix传递的第三个参数
        cat << EOF
        {
          "touser": "$UserID",
          "toparty": "$PartyID",
          "msgtype": "text",
          "agentid": "$AppID",
          "text": {
              "content": "$Msg"
          },
          "safe":"0"
        }
EOF
}

# 格式化微信文本
function text() {
        cat << EOF
        告警信息 : ${TriggerName} \n \n 
        当前状态码 :$2 \n \n
        最后一次报障信息 : $3 \n \n
        最后一次报障时间 : $4 \n \n
        告警链接 : ${TriggerURL} \n    
EOF
}

# 数据库查询
function iqMysql(){
    lasterror=$(LastError ${ItemID} 1)
    lasterrorTime=$(echo ${lasterror} |awk '{print $(NF)}')
    lasterrorText=$(echo ${lasterror%%${lasterrorTime}*} )
    lastcode=$(LastCode ${ItemID})
    Text=$(text $1 "${lastcode}" "${lasterrorText}" "$(printTime ${lasterrorTime})")
    echo ${Text}
}

if [ ${TriggerStatus} == "OK" ]
then
    Status="已恢复 \n\n"
else
    Status="网站异常 \n\n"
fi


# 读取缓存文件
if [ -e ${CACHEFILE} ]
then
    TIMEFLM=$(stat -c %Y ${CACHEFILE})
    TIMENOW=$(date +%s)
    if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 20 ];
    then
        Text=$(cat ${CACHEFILE})
    else
        Text=$(iqMysql $3)
        echo ${Text} > ${CACHEFILE}
    fi
else
    Text=$(iqMysql $3)
    echo ${Text} > ${CACHEFILE}
fi

#Send Wechat
/usr/bin/curl --data-ascii "$(body $1 $2 "${Status}${Text//\"/\'}")" $PURL

