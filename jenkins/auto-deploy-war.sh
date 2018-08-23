source /home/jenkins/.bash_profile

#如果文件或者文件夹存在则删除
deleteWhenExist(){
 if [ -e $1 ]; then
  rm -rf $1
 fi
}

#Tomcat根目录
TOMCAT_HOME="/home/jenkins/testTomcat/apache-tomcat-8.5.14"
#端口
TOMCAT_PORT=9876
#TOMCAT_PID用于检测Tomcat是否在运行
TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`


#如果tomcat还在运行
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

warPath="${TOMCAT_HOME}/webapps/test.yaml-expro-api/"
warFile="${TOMCAT_HOME}/webapps/test.yaml-api.war"

deleteWhenExist ${warPath}
deleteWhenExist ${warFile}

#拷贝新编译的包到Tomcat
cp /home/jenkins/test-expro-api.war ${TOMCAT_HOME}/webapps/
rm -rf /home/jenkins/test-expro-api.war

${TOMCAT_HOME}/bin/startup.sh
echo "正在启动Tomcat["${TOMCAT_PORT}"]..."

#检测Tomcat是否启动完成
while [ -z "${TOMCAT_PID}" ]
do
 sleep 1
 #echo "TOMCAT_PID["${TOMCAT_PID}"]"
 TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`
 echo "正在启动Tomcat["${TOMCAT_PORT}"]..."
done

echo "成功启动Tomcat.test_expro"

