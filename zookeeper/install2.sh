#!/bin/bash

#!!!Change the name!!!
#The zookeeper file should be figured out in the same directory with this script

ZOOKEEPER_FILE=zookeeper-3.4.6


cd  /usr/local/
tar -xzvf ${ZOOKEEPER_FILE}.tar.gz

cd ${ZOOKEEPER_FILE}

mkdir cluster

cd cluster

mkdir -p z1/data

mkdir -p z2/data

mkdir -p z3/data

echo 1 > z1/data/myid

echo 2 > z2/data/myid

echo 3 > z3/data/myid



echo "initLimit=10\nsyncLimit=5\ndataDir=../cluster/z1/data\nclientPort=2181\nserver.1=127.0.0.1:2222:2223\nserver.2=127.0.0.1:3333:3334\nserver.3=127.0.0.1:4444:4445" > z1/z1.cfg

echo  "initLimit=10\nsyncLimit=5\ndataDir=../cluster/z2/data\nclientPort=2182\nserver.1=127.0.0.1:2222:2223\nserver.2=127.0.0.1:3333:3334\nserver.3=127.0.0.1:4444:4445" > z2/z2.cfg

echo "initLimit=10\nsyncLimit=5\ndataDir=../cluster/z3/data\nclientPort=2183\nserver.1=127.0.0.1:2222:2223\nserver.2=127.0.0.1:3333:3334\nserver.3=127.0.0.1:4444:4445" > z3/z3.cfg


echo "The 3 nodes zookeeper has been configured successfully"

cd ../bin


echo "Start to start node1\n"

./zkServer.sh start ../cluster/z1/z1.cfg


echo "!!!!!!!!!!!!!!!!!Node1 is started!!!!!!!"

echo "Start to start node2\n"

./zkServer.sh start ../cluster/z2/z2.cfg

echo "!!!!!!!!!!!!!!!!!Node2 is started!!!!!!!"


echo "Start to start node3\n"

./zkServer.sh start ../cluster/z3/z3.cfg


echo "!!!!!!!!!!!!!!!!!Node3 is started!!!!!!!"
