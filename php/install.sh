#!/bin/sh
#下载源代码
mkdir -p /usr/local/software;cd /usr/local/software
wget http://hk1.php.net/distributions/php-5.6.37.tar.gz
#http://hk1.php.net/distributions/php-7.0.31.tar.gz
#http://hk1.php.net/distributions/php-7.1.20.tar.gz
#http://hk1.php.net/distributions/php-7.2.9.tar.gz

#解压缩
tar -zxvf php-5.6.37.tar.gz
#进入源码目录
cd php-5.6.37
./configure --prefix=/usr/local/php --with-curl --with-freetype-dir --with-gd --with-gettext --with-iconv-dir --with-kerberos --with-libdir=lib64 --with-libxml-dir --with-mysqli --with-openssl --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite --with-pear --with-png-dir --with-jpeg-dir --with-xmlrpc --with-xsl --with-zlib --with-bz2 --with-mhash --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-gd-native-ttf --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-sysvshm --enable-xml --enable-zip
make
make install
cp php.ini-development /usr/local/php/lib/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
groupadd www-data
useradd -g www-data www-data
echo "1:/usr/local/php/lib/php.ini 将 cgi.fix_pathinfo=1 设置成 0"
echo "2:修改 /usr/local/php/etc/php-fpm.d/www.conf 的user和group属性设置成www-data"
echo "export PATH=$PATH:/usr/local/php/bin" >> /etc/profile
source /etc/profile
cp /usr/local/php/bin/php /usr/local/bin: