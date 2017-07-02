>系统：Centos6.5 64位
>
>python2.6版本
>
>Mysql5.5版本
>
>Apache2.4版本
>
>>参考地址：https://github.com/gitlabhq/gitlab-recipes/tree/master/install/centos

###安装相关依赖包
	[root@02823f2ac2ab ~]# wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 https://getfedora.org/static/0608B895.txt
	[root@02823f2ac2ab ~]# rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	[root@02823f2ac2ab ~]# rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	[root@02823f2ac2ab ~]# wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-remi http://rpms.famillecollet.com/RPM-GPG-KEY-remi
	[root@02823f2ac2ab ~]# rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
	[root@02823f2ac2ab ~]# rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	[root@02823f2ac2ab ~]# yum -y install readline readline-devel ncurses-devel gdbm-devel glibc-devel tcl-devel openssl-devel curl-devel expat-devel db4-devel byacc sqlite-devel libyaml libyaml-devel libffi libffi-devel libxml2 libxml2-devel libxslt libxslt-devel libicu libicu-devel system-config-firewall-tui redis sudo wget crontabs logwatch logrotate perl-Time-HiRes git cmake libcom_err-devel.i686 libcom_err-devel.x86_64 nodejs
	[root@02823f2ac2ab ~]# yum -y install python-docutils
	[root@02823f2ac2ab ~]# git --version
	git version 1.7.1  // 大于2.7.4
	[root@02823f2ac2ab ~]# 
	[root@02823f2ac2ab ~]# yum -y remove git
	[root@02823f2ac2ab ~]# yum -y install zlib-devel perl-CPAN gettext curl-devel expat-devel gettext-devel openssl-devel
	[root@02823f2ac2ab ~]# mkdir /tmp/git && cd /tmp/git
	[root@02823f2ac2ab git]# curl --progress https://www.kernel.org/pub/software/scm/git/git-2.9.0.tar.gz | tar xz
	######################################################################## 100.0%
	[root@02823f2ac2ab git]# ll
	total 12
	drwxrwxr-x 21 root root 12288 Jun 13  2016 git-2.9.0
	[root@02823f2ac2ab git]# cd git-2.9.0/
	[root@02823f2ac2ab git-2.9.0]# ./configure --prefix=/usr/local/git2.9 && make && make install
	[root@02823f2ac2ab git-2.9.0]# ln -fs /usr/local/git2.9/bin/git /usr/bin/
	[root@02823f2ac2ab git-2.9.0]# mkdir /tmp/ruby && cd /tmp/ruby
	[root@02823f2ac2ab ruby]# curl --progress https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.9.tar.gz | tar xz
	[root@02823f2ac2ab ruby-2.1.9]# ./configure --prefix=/usr/local/ruby2.1 --disable-install-rdoc && make && make install
	[root@02823f2ac2ab ruby-2.1.9]# ln -fs /usr/local/ruby2.1/bin/ruby /usr/bin/
	[root@02823f2ac2ab ruby-2.1.9]# ruby -v
	ruby 2.1.9p490 (2016-03-30 revision 54437) [x86_64-linux]
	[root@02823f2ac2ab ruby-2.1.9]# 
	[root@02823f2ac2ab ruby-2.1.9]# yum -y install golang golang-bin golang-src
	[root@02823f2ac2ab ruby-2.1.9]# adduser --system --shell /bin/bash --comment 'GitLab' --create-home --home-dir /git/ git   //创建一个git储存目录

###配置数据库：
>注意：数据库需要使用innodb引擎，默认引擎

	mysql> CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
	GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES ON `gitlabhq_production`.* TO 'git'@'localhost' identified by '12345';
	mysql> flush privileges;

###测试新创建的数据库用户：
>注意：输入的是git的数据库用户密码

	[root@f62851e28990 ruby-2.1.9]# sudo	 -u git -H mysql -u git -p -D gitlabhq_production


###安装redis服务：
	[root@be6e5ec461a5 ~]# wget http://download.redis.io/releases/redis-3.0.6.tar.gz
	[root@be6e5ec461a5 ~]# tar xf redis-3.0.6.tar.gz -C /usr/local/      
	[root@be6e5ec461a5 ~]# cd /usr/local/redis-3.0.6/
	[root@be6e5ec461a5 redis-3.0.6]# make 
	[root@f62851e28990 redis-3.0.6]# sed -i 's/^port .*/port 0/' ./redis.conf
	[root@f62851e28990 redis-3.0.6]# sed -i 's/^# unixsocket/unixsocket/g' ./redis.conf


###修改redis配置文件：
	[root@be6e5ec461a5 redis-3.0.6]# vim redis.conf    	//这个配置文件在redis的安装目录下
	daemonize yes   									//默认启动后台运行
	logfile "/var/log/redis.log"   						//设置日志存放目录
	dir ./												//配置持久化文件存放位置，默认是根目录下


###修改启动脚本文件：
	[root@be6e5ec461a5 redis-3.0.6]# vim utils/redis_init_script
	# chkconfig:   2345 90 10
	REDISPORT=6379
	EXEC=/usr/local/redis-3.0.6/src/redis-server   		//启动服务文件
	CLIEXEC=/usr/local/redis-3.0.6/src/redis-cli   		//客户端启用文件
	
	PIDFILE=/var/run/redis.pid     						//redis的PID存储路径（这个文件路径要与配置文件中路径一致）
	CONF="/usr/local/redis-3.0.6/redis.conf"  			//redis配置文件
	
	[root@be6e5ec461a5 redis-3.0.6]# cp utils/redis_init_script /etc/init.d/redisd
	[root@be6e5ec461a5 redis-3.0.6]# chmod a+x /etc/init.d/redisd
	[root@be6e5ec461a5 redis-3.0.6]# chkconfig --add redisd
	[root@be6e5ec461a5 redis-3.0.6]# chkconfig --list redisd
	redisd         	0:off	1:off	2:on	3:on	4:on	5:on	6:off
	[root@be6e5ec461a5 redis-3.0.6]# 
	[root@be6e5ec461a5 redis-3.0.6]# service  redisd start
	Starting Redis server...
	[root@be6e5ec461a5 redis-3.0.6]# netstat -anput |grep 6379  //注意：因为禁止了监听端口，所以不会显示
	
	[root@f62851e28990 redis-3.0.6]# ps xauf |grep redis
	root     21939  0.1  0.0  36564  1796 ?        Ssl  12:01   0:00 /usr/local/redis-3.0.6/src/redis-server *:0
	[root@be6e5ec461a5 redis-3.0.6]# 
	[root@f62851e28990 redis-3.0.6]# usermod -aG redis git
	[root@f62851e28990 redis-3.0.6]# cd /git/
	[root@f62851e28990 git]# git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 8-9-stable gitlab