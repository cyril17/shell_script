#!/bin/bash
#卸载已经安装的mysql，
rpm  -qa |grep   mysql*
rpm  -qa |grep   maria*

#查看系统里面有没有mysql 的repo（可以参考上面第一步卸载）
yum repolist all | grep mysql

#下载镜像源且安装
cd   /etc/yum.repos.d/
wget http://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm
rpm  -ivh   mysql57-community-release-el7-8.noarch.rpm
#再看看是否存在mysql的repo
yum repolist enabled | grep mysql

if [ $? -eq 0 ];then
    echo -e '\e[32mRepo Successful!\e[0m'
else
    echo -e '\e[31mFailed\e[0m'
    exit 0
fi

#配置repo源
#只能有一个是 enabled=1的（即你需要安装的那个版本），其他的都得enabled=0。
cd /etc/yum.repos.d/

cat > mysql-community.repo <<EOF
[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/7/\$basearch/
baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/7/\$basearch/

enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-community]
name=MySQL Tools Community
baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/7/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Enable to use MySQL 5.5
[mysql55-community]
name=MySQL 5.5 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.5-community/el/7/\$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Enable to use MySQL 5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/\$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-preview]
name=MySQL Tools Preview
baseurl=http://repo.mysql.com/yum/mysql-tools-preview/el/7/\$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF

#安装成功
if [ $? -eq 0 ];then
    echo -e '\e[32mRepo modify Successful!\e[0m'
else
    echo -e '\e[31m Repo modify Failed\e[0m'
    exit 0
fi

#安装
yum install -y mysql-community-server

#启动
service mysqld start