<?php
require("/usr/local/zabbix/share/zabbix/alertscripts/sms/function.php");
$strMobile=$argv[1];
$content=$argv[2];
if (empty($strMobile))
	echo "error!";
else
	SendSMS($strMobile,$content);

?>
