#! /bin/env bash
# Author:eycode

# 该文件为故障恢复后还原文件
# 主从模式 && 本地认证模式

# 主从模式：替换文件，重启服务
# 本地模式：删除文件，重启服务

MYSQLADMIN="/usr/bin/mysqladmin"
MYSQLNAME="root"
MYSQLPASSWD="root3306"

MYSQLHOST_MASTER="192.168.0.220"
MYSQLPORT_MASTER="51858"

MYSQLHOST_SLAVE="127.0.0.1"
MYSQLPORT_SLAVE="3306"

CONNECT_MYSQL_PATH="/etc/pam.d"

CONFIG_DIR="/home/openvpn-2.0.9/server"
CONNECT_MYSQL_MASTER="/home/openvpn-2.0.9/backup/openvpn-220"
OPENVPN_CONFIG_MASTER="/home/openvpn-2.0.9/backup/server.conf-mysql"

LOCAL_AUTH_PASS="/home/openvpn-2.0.9/backup/psw-file"
LOCAL_AUTH_SHELL="/home/openvpn-2.0.9/backup/checkpsw.sh"


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


# 删相关文件
DEL_FILE(){
	# 当主库正常后，复制主库数据库配置文件到指定目录
	# 重启相关服务
	if [ $1 == "MASTER" ]
	then
		cp $CONNECT_MYSQL_MASTER $CONNECT_MYSQL_PATH/openvpn
		START_SERVER VPN && START_SERVER SASLAUTHD

	# 当主库和从库都正常时，删除本地认证文件
	# 复制VPN主配置文件到指定目录，重启服务
	elif [ $1 == "LOCAL" ]
	then
		rm -fr $CONFIG_DIR/psw-file $CONFIG_DIR/checkpsw.sh
		rm -fr $CONFIG_DIR/psw-file $CONFIG_DIR/psw-file
		cp $OPENVPN_CONFIG_MASTER $CONFIG_DIR/server.conf
		START_SERVER VPN && START_SERVER SASLAUTHD
	fi
}


# 第一种情况：当主库正常，从库也是正常时
if [ $(MYSQL_CHECK_STATUS MASTER) == '0' ] && [ $(MYSQL_CHECK_STATUS SLAVE) == '0' ]
then
	DEL_FILE MASTER
	echo "从数据库模式，切换到正常模式"
	exit 0

# 第二中情况：当主库正常时，同时在vpn目录下出现有本地认证文件时
elif [ $(MYSQL_CHECK_STATUS MASTER) == '0' ] && [ -f $CONFIG_DIR/checkpsw.sh ] && [ -f $CONFIG_DIR/psw-file ]
then
	DEL_FILE LOCAL
	echo "从本地认证模式，切换到正常模式"
	exit 0

# 第三种情况：当主库正常，从库不正常时
elif [ $(MYSQL_CHECK_STATUS MASTER) == '0' ] && [ $(MYSQL_CHECK_STATUS SLAVE) != '0' ]
then
	echo "从数据库出现异常，请及时处理"
	exit 1
fi