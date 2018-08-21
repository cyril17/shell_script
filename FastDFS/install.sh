#!/bin/bash


if [ -z $(rpm -qa | grep gcc-c++) ]
then
yum install -y make cmake gcc gcc-c++
fi
######################## user property #########################################
# 安装tracker机器的IP地址，如果部署其他tracker机器需要更改此ip
ip=172.16.75.128
# 用户路径
base_path=/usr/local/fastdfs
#指定tracker端口
tracker_port=22122
#nginx 端口
nginx_port=80
################################################################################

#进入初始目录
cd ~
#创建数据目录
mkdir -p $base_path


############################### 1、软件下载： ##################################

if [ -f V1.0.39*.gz ]
then
echo ""
else
wget https://github.com/happyfish100/libfastcommon/archive/V1.0.39.tar.gz
fi

if [ -f fastdfs*module*.gz ]
then
echo ""
else
#wget http://jaist.dl.sourceforge.net/project/fastdfs/FastDFS%20Nginx%20Module%20Source%20Code/fastdfs-nginx-module_v1.16.tar.gz
wget https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.20.tar.gz
fi

if [ -f V5.11*.gz ]
then
echo ""
else
#wget https://github.com/happyfish100/fastdfs/archive/V5.05.tar.gz
wget https://github.com/happyfish100/fastdfs/archive/V5.11.tar.gz
fi

if [ -f nginx-1.12.2*.gz ]
then
echo ""
else
#wget http://nginx.org/download/nginx-1.8.0.tar.gz
wget http://nginx.org/download/nginx-1.12.2.tar.gz
fi

if [ -f pcre*.gz ]
then
echo ""
else
#wget http://exim.mirror.fr/pcre/pcre-8.36.tar.gz
wget http://exim.mirror.fr/pcre/pcre-8.38.tar.gz

fi

if [ -f zlib*.gz ]
then
echo ""
else
#wget http://zlib.net/zlib-1.2.8.tar.gz
wget https://iweb.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz
fi

packages=`ls -l | grep 'gz$' | wc -l`
echo $packages
if [ $packages != 6 ]
then
echo "网络错误，下载少东西了"
exit
fi
######################### 判断文件是否下载好了 end ###############################

#2、libfastcommon安装：
cd ~
cp V1.0.39.tar.gz /usr/local/
tar -zxvf V1.0.39.tar.gz
cd libfastcommon-1.0.39
./make.sh
./make.sh install
rm -f /usr/local/V1.0.39.tar.gz

#libfastcommon.so默认安装到了/usr/lib64/libfastcommon.so，而FastDFS主程序设置的lib目录是/usr/local/lib，所以设置软连接
 ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so
 ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so
 ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
 ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so

#3、安装FastDFS:
cd ~
tar -zxvf V5.11.tar.gz -C /usr/local
cd /usr/local/fastdfs-5.11/

./make.sh
./make.sh install


#配置文件设置：
cd /etc/fdfs
cp tracker.conf.sample tracker.conf
cp storage.conf.sample storage.conf
cp client.conf.sample client.conf

#详细设置见附件
#tracker.conf配置中要修改的几个项：
#bind_addr=172.17.0.2
#port=22122
#http.server_port=8181
sed -i "s#\(bind_addr\).*#\1=$ip#" tracker.conf
sed -i "s#\(^port\).*#\1=$tracker_port#" tracker.conf
sed -i "s#\(base_path\).*#\1=$base_path#" tracker.conf
sed -i "s#\(^http.server_port\).*#\1=8181#" tracker.conf


#storage.conf配置中要修改的几个项：
#group_name=group1
#bind_addr=172.17.0.2
#port=23000
#base_path=/usrdata/fastdfs
#store_path0=/usrdata/fastdfs
#tracker_server=172.17.0.2:22122
#http.server_port=8888
sed -i "s#\(bind_addr\).*#\1=$ip#" storage.conf
sed -i "s#\(base_path\).*#\1=$base_path#" storage.conf
sed -i "s#\(store_path0\).*#\1=$base_path#" storage.conf
sed -i "s#\(tracker_server\).*#\1=$ip:$tracker_port#" storage.conf
sed -i "s#\(http.server_port\).*#\1=8888#" storage.conf

#（3）启动
#启动tracker storage.conf
fdfs_trackerd /etc/fdfs/tracker.conf
fdfs_storaged /etc/fdfs/storage.conf

##############################4、安装nginx插件：#####################################
#（1）安装
cd ~
tar -zxvf V1.20.tar.gz
#tar -zxvf fastdfs-nginx-module_v1.16.tar.gz


#（2）config文件修改：
#vi config
#修改如下配置，我这里原来是
#CORE_INCS="$CORE_INCS /usr/local/include/fastdfs /usr/local/include/fastcommon/"
#改成
#CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
#这个是很重要的，不然在nginx编译的时候会报错的，我看网上很多在安装nginx的fastdfs的插件报错，都是这个原因，而不是版本不匹配。
cd fastdfs-nginx-module-1.20/src/
sed -i "s#\(CORE_INCS=\"\$CORE_INCS \).*#\1/usr/include/fastdfs /usr/include/fastcommon/\"#" config


#修改配置
#group_name=group1
#tracker_server=172.17.0.2:22122
#store_path0=/usrdata/fastdfs
#base_path=/usrdata/fastdfs
#url_have_group_name = true
sed -i "s#\(group_name\).*#\1=group1#" mod_fastdfs.conf
sed -i "s#\(tracker_server\).*#\1=$ip:$tracker_port#" mod_fastdfs.conf
sed -i "s#\(store_path0\).*#\1=$base_path#" mod_fastdfs.conf
sed -i "s#\(base_path\).*#\1=$base_path#" mod_fastdfs.conf
sed -i "s#\(url_have_group_name\).*#\1=true#" mod_fastdfs.conf

cp  mod_fastdfs.conf /etc/fdfs



#2)、配置文件服务器的软连接
ln -s /usr/local/fastdfs/data /usr/local/fastdfs/data/M00
#(配置文件中stoage存放数据的路径)


#同时将以下两个文件复制到/etc/fdfs/
cp /usr/local/fastdfs-5.11/conf/http.conf /etc/fdfs/
cp /usr/local/fastdfs-5.11/conf/mime.types /etc/fdfs/


#5、nginx安装：
#在每个Storage服务器上安装Nginx

#（1）pcre安装：
cd ~
tar -zxvf pcre-8.38.tar.gz
cd pcre-8.38
./configure
make && make install
cd ../

ln -s /usr/local/lib/libpcre.so.1 /lib64/

#（2）zlib安装：
cd ~
tar -zxvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make && make install


#（3）nginx安装：
cd ~
tar -zxvf nginx-1.12.2.tar.gz
cd nginx-1.12.2
ipath=`whoami`
./configure --prefix=/usr/local/nginx --add-module=/$ipath/fastdfs-nginx-module-1.20/src
make
make install



#在server中添加
#
#location /group1/M00{
#    root /usrdata/fastdfs/data;
#    ngx_fastdfs_module;
#}

#判断文件内容是否已经写入
nginxconf=`sed -n '/group1/p' /usr/local/nginx/conf/nginx.conf`

if [ -z $nginxconf ]
        then
                sed -i "s@#error_page.*@location /group1/M00{root /usrdata/fastdfs/data;ngx_fastdfs_module;}@" /usr/local/nginx/conf/nginx.conf
        else
                echo "nothing todo"
fi &> /dev/null



#启动:
kill -9 $(ps -A | grep nginx | cut -d "?" -f 1 ) &> /dev/null
/usr/local/nginx/sbin/nginx


#安装完成。
#6、测试文件上传：
sed -i "s#\(base_path=\).*#\1$base_path#" /etc/fdfs/client.conf
sed -i "s#\(tracker_server=\).*#\1$ip:$tracker_port#" /etc/fdfs/client.conf
cd ~
echo "hello world" > 1.txt
#/usr/bin/fdfs_test /etc/fdfs/client.conf upload 1.txt
result=`/usr/bin/fdfs_test /etc/fdfs/client.conf upload 1.txt |grep url | grep -v big`
echo "得到类似这样的 $result"
curl ${result:17}