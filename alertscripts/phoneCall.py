#!/usr/bin/python
import sys
import requests
import json
import logging
import hashlib,base64
import time
import os

"""
本脚本采用的接口商

http://www.ucpaas.com
"""


SoftVersion="2014-06-30"
accountSid=""
appId=""
userToken=""
toSerNum=""
nowTime=time.strftime("%Y%m%d%H%M%s",time.gmtime())
templateId="1180"

def phoneCall(phoneNum,content):

    auText = "%s:%s" %(accountSid,nowTime)
    base_auNum = base64.b64encode(auText)
    auNum = base_auNum
    sigText="%s%s%s" % (accountSid,userToken,nowTime)
    mD5 = hashlib.md5()
    mD5.update(sigText.encode('utf-8'))
    sig = mD5.hexdigest().upper()
    url = "https://message.ucpaas.com/%s/Accounts/%s/Calls/voiceNotify?sig=%s" % (SoftVersion,accountSid,sig)
    headers = {
    'Host':'message.ucpaas.com',
    'Accept':'application/json',
    'Content-Type':'application/json;charset=utf-8',
    'Authorization':auNum,
    }

    params = {
    "voiceNotify":{
        "appId":appId,
        "to":phoneNum,
        "templateId":templateId,
        "type":"2",
        "toSerNum":toSerNum,
        "content":content,
        "playTimes" : "3"
     }
    }
    myRequests = requests.Session()
    r = myRequests.post(url=url,headers=headers,data=json.dumps(params),verify=False)
    data = r.text
    print data

if __name__ == "__main__":

	"""
	分组
	示例 testA组 testB组
	需要提前录制一段模板语音上传并且通过
	"""
    logName = '/tmp/phoneCall.log'
    if not os.path.exists(logName):
        os.system("touch %s" % logName) 
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s  %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename='/tmp/phoneCall.log',
                        filemode='a+')

    if len(sys.argv) >= 3:
	
		"""
		如果传入文本包含testA就播放语音模板1
		"""
        user = str(sys.argv[1])
        content = str(sys.argv[2])
        if 'testA' in content:
            d = {"name":"1"}
            phoneCall(user,json.dumps(d))
        elif 'testB' in content:
            d = {"name":"2"}
            phoneCall(user,json.dumps(d))
        logging.info('%s %s ' % (sys.argv[1], sys.argv[2]))
