#!/bin/bash
###SCRIPT_NAME:weixin.sh###
###send message from weixin for zabbix monitor###

# 参数		必须	说明
# touser	否	成员ID列表（消息接收者，多个接收者用‘|’分隔，最多支持1000个）。特殊情况：指定为@all，则向关注该企业应用的全部成员发送
# toparty	否	部门ID列表，多个接收者用‘|’分隔，最多支持100个。当touser为@all时忽略本参数
# totag		否	标签ID列表，多个接收者用‘|’分隔。当touser为@all时忽略本参数
# msgtype	是	消息类型，此时固定为：text
# agentid	是	企业应用的id，整型。可在应用的设置页面查看
# content	是	消息内容
# safe		否	表示是否是保密消息，0表示否，1表示是，默认0##V1-2015-08-25###

#$1:部门成员id
#$2:主题
#$3:消息内容

CropID=''
Secret=''
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret" 
Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
 
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
 
function body() {
        local int AppID=2                        #企业号中的应用id
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
/usr/bin/curl --data-ascii "$(body $1 $2 $3)" $PURL



