# coding:utf-8
#!/usr/bin/env python
# author : eycode
# 该文件用于发送邮件

import smtplib
import datetime
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

status = sys.argv[1]

_user = "oa@imay.com"
_pwd  = "2RS2M5DXs"
# to_list   = "%s" %email
to_list   = 'gongqinying@imay.com'

msg = MIMEMultipart()
msg["Accept-Language"] = "zh-CN"
msg["Accept-Charset"] = "ISO-8859-1,utf-8"
msg["Subject"] = u"VPN服务器状态邮件"
msg["From"]    = _user
msg['to'] = to_list

if status == "FATAL":
	part = MIMEText("严重：VPN主从数据库不能使用，现在切换到本地认证模式", _charset="utf-8")
	msg.attach(part)
elif status == "ERROR":
	part = MIMEText("错误：主数据库已经停止运行，现在切换到从数据库上使用", _charset="utf-8")
	msg.attach(part)
elif status == "WARN":
	part = MIMEText("提醒：从数据库有异常，但不影响VPN主要功能，请及时处理", _charset="utf-8")
	msg.attach(part)

server = smtplib.SMTP_SSL()
server.connect("smtp.exmail.qq.com", 465)
server.login(_user, _pwd)
server.sendmail(_user, to_list, msg.as_string())
server.close()
