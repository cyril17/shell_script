#!/bin/bash

mkdir -p /usr/local/zookeeper
wget http://shell-auto-install.oss-cn-zhangjiakou.aliyuncs.com/package/zookeeper-3.5.2-alpha.tar.gz
tar zxvf zookeeper-3.5.2-alpha.tar.gz

cp -rf zookeeper-3.5.2-alpha z0
cp -rf zookeeper-3.5.2-alpha z1
mv zookeeper-3.5.2-alpha z2

cp file/zoo0.cfg z0/conf/zoo.cfg
cp file/zoo1.cfg z1/conf/zoo.cfg
cp file/zoo2.cfg z2/conf/zoo.cfg

mkdir -p /usr/local/zookeeper/z0/data/
mkdir -p /usr/local/zookeeper/z1/data/
mkdir -p /usr/local/zookeeper/z2/data/

mkdir -p /usr/local/zookeeper/z0/logs/
mkdir -p /usr/local/zookeeper/z1/logs/
mkdir -p /usr/local/zookeeper/z2/logs/

mv z0/*  /usr/local/zookeeper/z0/
mv z1/*  /usr/local/zookeeper/z1/
mv z2/*  /usr/local/zookeeper/z2/

rm -rf  ./ z0 z1 z2

echo "0" > /usr/local/zookeeper/z0/data/myid
echo "1" > /usr/local/zookeeper/z1/data/myid
echo "2" > /usr/local/zookeeper/z2/data/myid



