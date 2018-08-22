#!/bin/bash
# Redis Auto install 2016.1109

current_time=`date +%Y%m%d-%H%M`
redis_setup_dir="/usr/local/redis/"
redis_cluster_dir="/usr/local/redis-cluster/"
redis_version="redis-3.0.3"
redis_source_code="/usr/src/redis/${redis_version}.tar.gz"
redis_source_code_unzip_dir="/usr/src/redis/${redis_version}/"
url="http://download.redis.io/releases/${redis_version}.tar.gz"
ip="192.168.71.128"

yum -y install gcc wget

cd /usr/src/redis/
tar -xf ${redis_source_code}
cd ${redis_source_code_unzip_dir} && make
make PREFIX=${redis_setup_dir} install
cp redis.conf /usr/local/redis/

mkdir -p $redis_cluster_dir/redis7001
mkdir -p $redis_cluster_dir/redis7002
mkdir -p $redis_cluster_dir/redis7003
mkdir -p $redis_cluster_dir/redis7004
mkdir -p $redis_cluster_dir/redis7005
mkdir -p $redis_cluster_dir/redis7006

cp -rf $redis_setup_dir/* $redis_cluster_dir/redis7001
cp -rf $redis_setup_dir/* $redis_cluster_dir/redis7002
cp -rf $redis_setup_dir/* $redis_cluster_dir/redis7003
cp -rf $redis_setup_dir/* $redis_cluster_dir/redis7004
cp -rf $redis_setup_dir/* $redis_cluster_dir/redis7005
cp -rf $redis_setup_dir/* $redis_cluster_dir/redis7006

\cp /usr/src/redis/conf/redis7001/redis.conf $redis_cluster_dir/redis7001
\cp /usr/src/redis/conf/redis7002/redis.conf $redis_cluster_dir/redis7002
\cp /usr/src/redis/conf/redis7003/redis.conf $redis_cluster_dir/redis7003
\cp /usr/src/redis/conf/redis7004/redis.conf $redis_cluster_dir/redis7004
\cp /usr/src/redis/conf/redis7005/redis.conf $redis_cluster_dir/redis7005
\cp /usr/src/redis/conf/redis7006/redis.conf $redis_cluster_dir/redis7006

\cp /usr/src/redis/shutdown-auth.sh /usr/src/redis/start-all.sh $redis_cluster_dir/
chmod +x $redis_cluster_dir/shutdown-auth.sh $redis_cluster_dir/start-all.sh
/bin/sh /usr/local/redis-cluster/start-all.sh

#开始安装cluster
yum install -y ruby rubygems

cd /usr/src/redis/

gem install -l ./redis-3.2.1.gem
chmod +x redis-trib.rb
\cp /usr/src/redis/client.rb /usr/local/share/gems/gems/redis-3.2.1/lib/redis/client.rb

./redis-trib.rb create --replicas 1 $ip:7001 $ip:7002 $ip:7003 $ip:7004 $ip:7005  $ip:7006
