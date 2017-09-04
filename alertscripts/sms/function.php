<?php
//请注意接口是采用GB2312编码

// 配置$id $pwd 
function SendSMS($strMobile,$content){
			$url="http://service.winic.org:8009/sys_port/gateway/?id=%s&pwd=%s&to=%s&content=%s&time=";
			$id = urlencode("");
			$pwd = urlencode("");
			$to = urlencode($strMobile);
			$content = iconv("UTF-8","GB2312",$content); //将utf-8转为gb2312再发
			$rurl = sprintf($url, $id, $pwd, $to, $content);
			
			//初始化curl
   			$ch = curl_init() or die (curl_error());
  			//设置URL参数
   			curl_setopt($ch,CURLOPT_URL,$rurl);
   			curl_setopt($ch, CURLOPT_POST, 1);
   			curl_setopt($ch, CURLOPT_HEADER, 0);
   			//执行请求
   			$result = curl_exec($ch) ;
   			//取得返回的结果，并显示
   			echo $result;
   			echo curl_error($ch);
   			//关闭CURL
   			curl_close($ch);
} 


?>