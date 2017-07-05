## Git / GitHub / GitLab 优缺点简单分析：

#### Git：
	版本控制管理器，类似于SVN，但功能上和容错上比SVN更加优秀

#### GitHub：
	开源网站，Git的管理器WEB版，有免费和收费两种模式，免费用户有300M免费空间

个人认为写写代码，发发文章还是可以的。

#### 优点：

1.  就是是全球性最大的开源平台，很多很多超级大牛，和你一起写代码。

#### 缺点：

1.  对于一些没钱，有要装逼的野生程序员来说，网速是绝对的硬伤，例如我。
2.  有一些代码或资料我并不想公开，但是又没有钱的野生程序员来说，也是一种硬伤，例如我。


#### GitLab：
	是一个开源的GitWEB管理平台，类似于GitHub，可以在内部构建一个类似Github管理平台

#### 优点：

1.  完全可以在内部自行搭建，代码私有化
2.  图形化管理，方便对Git进行管理

#### 缺点：

1.  搭建起来比较麻烦，动手能力差的，直接掉坑。为了解决这个问题，可以使用以下方法

2.  Docker版本（对Docker没有认识的，可以找下我前面的文章）：

	[https://github.com/sameersbn/docker-gitlab](https://github.com/sameersbn/docker-gitlab "官方文档")  
	[http://www.tuicool.com/articles/bYbi2mJ](http://www.tuicool.com/articles/bYbi2mJ "中文版文档")

3.  Ubantu系统有图形化安装包

## 安装git服务器

#### Stup1: 安装Git和添加管理用户
	[root@iZ28kfmf1oqZ ~]# yum -y install git
	[root@iZ28kfmf1oqZ ~]# useradd git
	[root@iZ28kfmf1oqZ ~]# passwd git
	Changing password for user git.
	New password: 
	BAD PASSWORD: it is based on a dictionary word
	BAD PASSWORD: is too simple
	Retype new password: 
	passwd: all authentication tokens updated successfully.
	[root@iZ28kfmf1oqZ ~]# 

#### Stup2：使用SSH登录认证方式
	[root@iZ28kfmf1oqZ ~]# su git
	[git@iZ28kfmf1oqZ root]$ cd
	[git@iZ28kfmf1oqZ ~]$ ssh-keygen -t rsa
	Generating public/private rsa key pair.
	Enter file in which to save the key (/home/git/.ssh/id_rsa): 
	Created directory '/home/git/.ssh'.
	Enter passphrase (empty for no passphrase): 
	Enter same passphrase again: 
	Your identification has been saved in /home/git/.ssh/id_rsa.
	Your public key has been saved in /home/git/.ssh/id_rsa.pub.
	The key fingerprint is:
	6e:53:b0:dd:87:9e:48:2d:41:8e:a1:04:25:9e:0c:a6 git@iZ28kfmf1oqZ
	The key's randomart image is:
	+--[ RSA 2048]----+
	|  o ooo . .      |
	| o + + . =       |
	|E   + . o o      |
	|         + + .   |
	|        S = + .  |
	|       . o + o   |
	|        + . o    |
	|       . .       |
	|                 |
	+-----------------+
	[git@iZ28kfmf1oqZ ~]$ ll -a
	total 24
	drwx------  3 git  git  4096 Jul  2 19:04 .
	drwxr-xr-x. 3 root root 4096 Jul  2 19:01 ..
	-rw-r--r--  1 git  git    18 Oct 16  2014 .bash_logout
	-rw-r--r--  1 git  git   176 Oct 16  2014 .bash_profile
	-rw-r--r--  1 git  git   124 Oct 16  2014 .bashrc
	drwx------  2 git  git  4096 Jul  2 19:04 .ssh
	[git@iZ28kfmf1oqZ ~]$ 
	[git@iZ28kfmf1oqZ .ssh]$ touch authorized_keys
	[git@iZ28kfmf1oqZ .ssh]$ chmod 600 authorized_keys 
	[git@iZ28kfmf1oqZ .ssh]$ ll
	total 8
	-rw------- 1 git git    0 Jul  2 19:07 authorized_keys
	-rw------- 1 git git 1671 Jul  2 19:04 id_rsa
	-rw-r--r-- 1 git git  398 Jul  2 19:04 id_rsa.pub
	[git@iZ28kfmf1oqZ .ssh]$ 
	[git@iZ28kfmf1oqZ /]$ exit
	exit

**注意：**

**authorized_keys是没有的，需要自己创建，并要设置为600**

#### Stup3:创建Git仓库
	[root@iZ28kfmf1oqZ /]# mkdir /git
	[root@iZ28kfmf1oqZ git]# git init --bare eycode.git
	Initialized empty Git repository in /git/eycode.git/
	[root@iZ28kfmf1oqZ git]# ll eycode.git
	total 32
	drwxr-xr-x 2 root root 4096 Jul  2 21:39 branches
	-rw-r--r-- 1 root root   66 Jul  2 21:39 config
	-rw-r--r-- 1 root root   73 Jul  2 21:39 description
	-rw-r--r-- 1 root root   23 Jul  2 21:39 HEAD
	drwxr-xr-x 2 root root 4096 Jul  2 21:39 hooks
	drwxr-xr-x 2 root root 4096 Jul  2 21:39 info
	drwxr-xr-x 4 root root 4096 Jul  2 21:39 objects
	drwxr-xr-x 4 root root 4096 Jul  2 21:39 refs
	[root@iZ28kfmf1oqZ git]# chown -R git:git eycode.git/
	[root@iZ28kfmf1oqZ git]# ll
	total 4
	drwxr-xr-x 7 git git 4096 Jul  2 21:39 eycode.git
	[root@iZ28kfmf1oqZ git]# 
	
	[root@16bf6ea74dc8 git]# usermod -s /usr/bin/git-shell git
	[root@iZ28kfmf1oqZ git]# vim /etc/passwd
	git:x:504:504::/home/git:/usr/bin/git-shell


**注意：**

1.  仓库后缀为 .git
2.  命令参数详细参考：[https://git-scm.com/book/zh/v2](https://git-scm.com/book/zh/v2 "Git Book")
3.  将Git用户设置为不能登录服务器权限，可以登录Git，不能登录服务器



## Linux客户端上测试添加仓库和提交数据

	[root@26a513054e5c ~]# yum -y install git
	[root@26a513054e5c ~]# mkdir /git
	[root@26a513054e5c ~]# cd /git/
	[root@26a513054e5c git]# ll
	total 0
	[root@26a513054e5c git]# git init
	Initialized empty Git repository in /git/.git/
	[root@26a513054e5c git]# 
	[root@26a513054e5c git]# git remote add origin git@172.17.0.12:/git/eycode.git
	[root@26a513054e5c git]# git config --global user.name "git"
	[root@26a513054e5c git]# git config --global user.email eycode@163.com
	[root@26a513054e5c git]# git add test.txt 
	[root@26a513054e5c git]# git commit -m "init commit"   
	//Git 每次提交代码，都要写 Commit message（提交说明），否则就不允许提交。
	[root@26a513054e5c git]# git push origin master
	The authenticity of host '172.17.0.12 (172.17.0.12)' can't be established.
	RSA key fingerprint is da:29:2e:e2:a1:6d:c2:52:7c:31:61:0b:57:e8:6e:2d.
	Are you sure you want to continue connecting (yes/no)? yes
	Warning: Permanently added '172.17.0.12' (RSA) to the list of known hosts.
	git@172.17.0.12's password: 
	Counting objects: 3, done.
	Writing objects: 100% (3/3), 204 bytes, done.
	Total 3 (delta 0), reused 0 (delta 0)
	To git@172.17.0.12:/git/eycode.git
	 * [new branch]      master -> master
	[root@26a513054e5c git]# 

**注意：在Linux客户端上使用Git是不用密钥登录的，所以连接Git时需要输入Git用户密码即可**


## 在Windows下使用TortoiseGit提交数据到git服务器上

> 需要安装Git和TortoiseGit

#### Git非官方版本：

[http://dlsw.baidu.com/sw-search-sp/soft/e7/40642/Git-2.7.2-64-bit_setup.1457942968.exe](http://dlsw.baidu.com/sw-search-sp/soft/e7/40642/Git-2.7.2-64-bit_setup.1457942968.exe "64位的Git")


[http://dlsw.baidu.com/sw-search-sp/soft/4e/30195/Git-2.7.2-32-bit_setup.1457942412.exe](http://dlsw.baidu.com/sw-search-sp/soft/4e/30195/Git-2.7.2-32-bit_setup.1457942412.exe "32位的Git")


#### Git官方版：

[https://git-scm.com/downloads](https://git-scm.com/downloads "官方版所有版本")



#### TortoiseGit官方版：

[https://tortoisegit.org/download/](https://tortoisegit.org/download/ "官方版")


> 使用教程，请看另一篇文章：TortoiseGit使用指南



## 在另外一台Linux客户端上clone Git上的数据进行同步

	[root@26a513054e5c ~]# mkdir /eycode
	[root@26a513054e5c ~]# cd /eycode/
	[root@26a513054e5c eycode]# ll
	total 0
	[root@26a513054e5c eycode]# git clone git@172.17.0.12:/git/eycode.git
	Initialized empty Git repository in /eycode/eycode/.git/
	git@172.17.0.12's password: 
	remote: Counting objects: 3, done.
	remote: Total 3 (delta 0), reused 0 (delta 0)
	Receiving objects: 100% (3/3), done.
	[root@26a513054e5c eycode]# ll
	total 4
	drwxr-xr-x 3 root root 4096 Jul  3 11:41 eycode
	[root@26a513054e5c eycode]# cd eycode/
	[root@26a513054e5c eycode]# ll
	total 0
	-rw-r--r-- 1 root root 0 Jul  3 11:41 test.txt
	[root@26a513054e5c eycode]# 



剩下的GitHub迟点再说，待续没完.....