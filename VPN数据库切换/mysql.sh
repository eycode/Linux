#!/bin/env bash
# Author:eycode

# 要求：
# 1. 10分钟检查一次VPN服务器
# 1.1 220出现问题时：切换到100数据库上，并发送邮件通知管理员，手动恢复设置（优先）
# 1.2 100数据库出现问题，220上没有问题：发送邮件通知管理员（优先）
# 1.3 220和100数据库都出现问题时，VPN服务正常：使用应急本地认证服务文件认证登录处理（优先）
# 1.4 VPN服务启动不了，出现异常时：自动修复异常或覆盖文件（后期）

# VPN状态监控文件
MYSQLADMIN="/usr/bin/mysqladmin"
MYSQLNAME="root"
MYSQLPASSWD="root3306"

MYSQLHOST_MASTER="192.168.0.220"
MYSQLPORT_MASTER="51858"

MYSQLHOST_SLAVE="127.0.0.1"
MYSQLPORT_SLAVE="3306"


CONNECT_MYSQL_PATH="/etc/pam.d"
CONNECT_MYSQL_MASTER="/home/openvpn-2.0.9/backup/openvpn-220"
CONNECT_MYSQL_SLAVE="/home/openvpn-2.0.9/backup/openvpn-100"

CONFIG_DIR="/home/openvpn-2.0.9/server"
OPENVPN_CONFIG_MASTER="/home/openvpn-2.0.9/backup/server.conf-mysql"
OPENVPN_CONFIG_SLAVE="/home/openvpn-2.0.9/backup/server.conf-localhost"

LOCAL_AUTH_PASS="/home/openvpn-2.0.9/backup/psw-file"
LOCAL_AUTH_SHELL="/home/openvpn-2.0.9/backup/checkpsw.sh"

MAIL_FILE="/home/openvpn-2.0.9/backup/mail.py"


# 检查Mysql状态是否正常
MYSQL_CHECK_STATUS(){
	if [ $1 == "MASTER" ]
	then
		$MYSQLADMIN -u$MYSQLNAME -p$MYSQLPASSWD -h $MYSQLHOST_MASTER -P $MYSQLPORT_MASTER ping &> /dev/null
		echo $?
	elif [ $1 == "SLAVE" ]
	then
		$MYSQLADMIN -u$MYSQLNAME -p$MYSQLPASSWD -h $MYSQLHOST_SLAVE -P $MYSQLPORT_SLAVE ping &> /dev/null
                echo $?
	fi
}

# 发送邮件告知管理员
SEND_MAIL(){
	if [ $1 == "FATAL" ]
	then
		/usr/bin/python $MAIL_FILE FATAL
		echo "VPN主从数据库不能使用，现在切换到本地认证模式"
	elif [ $1 == "ERROR" ]
	then
		/usr/bin/python $MAIL_FILE ERROR
		echo "主数据库已经停止运行，现在切换到从数据库上使用"
	elif [ $1 == "WARN" ]
	then
		/usr/bin/python $MAIL_FILE WARN
		echo "从数据库有异常，但不影响VPN主要功能，请及时处理"
	fi
}


# 重启相关服务
START_SERVER(){
	if [ $1 == "VPN" ]
	then
		pkill openvpn &> /dev/null
		sleep 5
		service openvpn start &> /dev/null
	elif [ $1 == "MYSQLD" ]
	then
		service mysqld restart &> /dev/null
	elif [ $1 == "SASLAUTHD" ]
	then
		systemctl restart saslauthd &> /dev/null
	fi
}

# 复制相关文件到指定位置
COPY_FILE(){
	if [ $1 == "MASTER" ]
	then
		# 当主数据库出现问题，从数据库正常
		cp $CONNECT_MYSQL_SLAVE $CONNECT_MYSQL_PATH/openvpn
		START_SERVER VPN && START_SERVER MYSQLD && START_SERVER SASLAUTHD
	
	elif [ $1 == "LOCAL" ]
	then
		# 当主从数据库不能使用时，启用本地认证模式
		cp $OPENVPN_CONFIG_SLAVE $CONFIG_DIR/server.conf
		cp $LOCAL_AUTH_PASS $LOCAL_AUTH_SHELL $CONFIG_DIR
		START_SERVER VPN
	fi
}


# 第一种情况：当主数据库正常，从数据库正常
if [ $(MYSQL_CHECK_STATUS MASTER) == '0' ] && [ $(MYSQL_CHECK_STATUS SLAVE) == '0' ]
then
        echo "success"
        exit 0

# 第二种情况：当主数据库出现问题，从数据库正常
elif [ $(MYSQL_CHECK_STATUS MASTER) == '1' ] && [ $(MYSQL_CHECK_STATUS SLAVE) == '0' ]
then
        SEND_MAIL ERROR
        COPY_FILE MASTER
        exit 1

# 第三种情况：当主数据没有问题，从数据库用问题
elif [ $(MYSQL_CHECK_STATUS MASTER) == '0' ] && [ $(MYSQL_CHECK_STATUS SLAVE) == '1' ]
then
        SEND_MAIL WARN
        exit 1

# 第四种情况：当主和从数据库都出现问题
elif [ $(MYSQL_CHECK_STATUS MASTER) == '1' ] && [ $(MYSQL_CHECK_STATUS SLAVE) == '1' ]
then
        SEND_MAIL FATAL
        COPY_FILE LOCAL
        exit 1
fi
