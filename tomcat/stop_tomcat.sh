#!/bin/bash

#如果文件或者文件夹存在则删除
deleteWhenExist(){
 if [ -e $1 ]; then
  rm -rf $1
 fi
}


#Tomcat根目录
TOMCAT_HOME="/opt/jenkins/test1"
#端口
TOMCAT_PORT=9090
#TOMCAT_PID用于检测Tomcat是否在运行
TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`

#如果tomcat还在运行,则关闭
if [ -n "${TOMCAT_PID}" ]; then
        #关闭tomcat
        kill -9 "${TOMCAT_PID}"
        #循环检查Tomcat是否关闭
        while [ -n "${TOMCAT_PID}" ]
        do
                #等待1秒
                sleep 1
                #获取8080端口运行进程PID，如果PID为空则表示Tomcat已经关闭
                TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`
                echo "${TOMCAT_PID}"
                echo "正在关闭Tomcat["${TOMCAT_PORT}"]..."
        done
        echo "成功关闭Tomcat."
fi