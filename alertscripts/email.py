#!/usr/bin/python
# -*- coding: utf-8 -*-
import os,sys
import requests
import logging
import smtplib
import json
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.MIMEMultipart import MIMEMultipart
from email.header import Header

"""
crontab 配置一个定期删除图片文件
*/5 * * * * find /tmp  -cmin +1 -name 'zabbix-graph-itemID*' -delete
"""



# Zabbix配置
USER = ''
PASSWD = ''
HOST = ''

# 公司logo
logPng = ''


# 邮件配置
MAILNAME=""
MAILUSER=""
MAILPASS=""
SMTPSERVER="smtp.gmail.com"



myRequests = requests.Session()


# 对邮件传入的参数进行格式化
D = {}
subject = sys.argv[2]
J = sys.argv[3].replace("'","").replace("\"","").replace(" ","").split("|")
for i in range(0,len(J)):
    if J[i].count(':') > 1:
       key = J[i].split(":")[0]
       value = J[i].replace("%s:"%(key),"")
       D[key] = value
    else:
       D[J[i].split(":")[0]] = J[i].split(":")[1]



# 格式化
triggerHost = "<strong>告警主机: </strong>%s (%s)" % (D['HOST.HOST1'],D['HOST.IP1'])
triggerTime = "<strong>告警时间: </strong>%s %s" % (D['EVENT.DATE'],D['EVENT.TIME'])
triggerLevel = "<strong>告警等级: </strong>%s" % (D['TRIGGER.SEVERITY'])
triggerName  = "<strong>告警信息: </strong> %s" % (D['TRIGGER.NAME'])
triggerKey = "<strong>告警项目: </strong> %s" % (D['ITEM.KEY1'])
triggerText = "<strong>问题详情: </strong>%s %s" % (D['ITEM.NAME1'],D['ITEM.VALUE1'])
triggerItemID = D['ITEM.ID']
if D['TRIGGER.STATUS'] == 'OK':
    triggerStatus = "<strong>当前状态: </strong><span style='font-weight:bold;color:green;'>%s</span>" % (D['TRIGGER.STATUS'])
    mailSubject = '<div style="border-bottom:1px #D9D9D9 solid;font-size:18px;line-height:40px;color:#7BB009;">故障恢复</div>'
else:
    triggerStatus = "<strong>当前状态: </strong><span style='font-weight:bold;color:red;'>%s</span>" % (D['TRIGGER.STATUS'])
    mailSubject = '<div style="border-bottom:1px #D9D9D9 solid;font-size:18px;line-height:40px;color:#F00000;">故障通知</div>'


# 邮件正文
mailText = """
<html xmlns="http://www.w3.org/1999/xhtml">
<html><head><meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>$sub</title></head>
<body style="margin:0;padding:0;">

<table cellspacing="0" cellpadding="0" width="100%%" style="min-height:69px;border:1px #7BB009 solid;border-top-width:6px;font-family:'微软雅黑',sans-serif;font-size:14px;">
<tbody><tr><td><center><div style="text-align:left;max-width:100%%;min-height:69px;"><div style="float:left;height:69px;">
<a href="http://www.8891.com.tw" target="_blank" style="display:block;height:42px;width:131px;margin:13px 20px 0;">
<img style="border:none;" src="%s" height="50"  width="200" alt="591" title="591"/>
</a></div></div></center></td></tr></tbody></table>
<table cellspacing="0" cellpadding="0" width="100%%" style="border:1px #7BB009 solid;border-width:0 1px 0 1px;font-family:'微软雅黑',sans-serif;font-size:13px;">
<tbody><tr><td><center><div style="max-width:100%%;text-align:left;border-bottom:1px #D9D9D9 dashed;padding-bottom:20px;font-size:13px;">
<table width="100%%" cellspacing="0" cellpadding="8" style="font-size:13px;"><tbody><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
%s</td></tr><tr><td>
<img src="cid:p"></tr><tr><td>
</td></tbody></table></td></tr></tbody></table></div></center>	</td></tr></tbody></table>
<table cellspacing="0" cellpadding="0" width="100%%" style="border:1px #7BB009 solid;border-top:none;font-family:'微软雅黑',sans-serif;font-size:12px;line-height:35px;padding-bottom:30px;"></table></body>
</html>
""" % (logPng,mailSubject,triggerHost,triggerTime,triggerLevel,triggerName,triggerKey,triggerText,triggerStatus)


# 发送邮件
def SendMail(Recipient,Subject,Text,Img=None):
    msg = MIMEMultipart('alternative')
    msg['From']= "%s<%s>" % (MAILNAME,MAILUSER)
    msg['Subject'] = Header(Subject,'utf-8').encode()
    msg['To'] = Recipient
    if Img :
        fp = open(Img,'rb')
        msgImage = MIMEImage(fp.read())
        fp.close()
        msgImage.add_header('Content-ID','p')
        msg.attach(msgImage)
    part = MIMEText(Text, 'html', 'utf-8')
    msg.attach(part)

    smtp = smtplib.SMTP_SSL(SMTPSERVER,'465')
    #smtp = smtplib.SMTP(SMTPSERVER,587)
    try:
        smtp.ehlo()
     #   smtp.starttls()
        smtp.login(MAILUSER,MAILPASS)
        smtp.sendmail(MAILUSER,Recipient,msg.as_string())
    except Exception as e:
        print e
    finally:
        smtp.quit()


# 获取性能图		
def GetGraph(itemID,pName=None):
    try:
        loginUrl = "http://%s/zabbix/index.php" % HOST
        print loginUrl
        loginHeaders={
            "Host":HOST,
        }
        playLoad = {
            "name":USER,
            "password":PASSWD,
            "autologin":"1",
            "enter":"Sign in",
        }
        res = myRequests.post(loginUrl,headers=loginHeaders,data=playLoad)
        
        testUrl = "http://%s/zabbix/chart.php" % HOST
        testUrlplayLoad = {
            "period" :"3600",
            "itemids[0]" : itemID,
            "type" : "0",
            "profileIdx" : "web.item.graph",
            "width" : "700",
        }
        testGraph = myRequests.get(url=testUrl,params=testUrlplayLoad)
        #IMAGEPATH = os.path.join(os.getcwd(), 'itemid_%s.png' % itemID)
        IMAGEPATH = os.path.join('/tmp', pName)
        f = open(IMAGEPATH,'wb')
        f.write(testGraph.content)
        f.close()
        return pName
    except Exception as e:
        print e
        return False
    finally:
        myRequests.close()


if __name__ == "__main__":
    graphName = 'zabbix-graph-itemID-%s.png' % triggerItemID
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s  %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename='/tmp/testEmail.log',
                        filemode='a+')

    try:
        if os.path.exists('/tmp/%s' % graphName):
            SendMail(sys.argv[1], subject, mailText, Img="/tmp/%s" % graphName)
        else:
            itemPng = GetGraph(triggerItemID,graphName)
            if itemPng:
                SendMail(sys.argv[1],subject,mailText,Img="/tmp/%s" % itemPng)
            else:
                SendMail(sys.argv[1], subject, mailText)
        logging.info("%s %s %s" % (sys.argv[1], sys.argv[2], sys.argv[3]))
		
    except  Exception, e:
        logging.error('Error:%s', e)
		

		
