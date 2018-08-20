source /home/jenkins/.bash_profile

#如果文件或者文件夹存在则删除
deleteWhenExist(){
 if [ -e $1 ]; then
  rm -rf $1
 fi
}

JAR_PID=`ps -aux | grep 'test-expro-choose.jar'|grep -v grep|awk '{print $2}'`
echo "Jar包pid${JAR_PID}"
if [ -n "${JAR_PID}" ]; then
        #关闭Jar
        kill -9 "${JAR_PID}"
        #循环检查Jar是否关闭
        while [ -n "${JAR_PID}" ]
        do
		#等待1秒
		sleep 1
		#获取8080端口运行进程PID，如果PID为空则表示Tomcat已经关闭
		JAR_PID=`ps -aux | grep 'test-expro-choose.jar' |grep -v grep|awk '{print $2}'`
		echo "${JAR_PID}"
		echo "正在关闭Jar包["${JAR_PID}"]..."
	done
	echo "成功关闭Jar包."
fi

jarFile="/home/jenkins/testTomcat/test-expro-choose.jar"

deleteWhenExist ${jarFile}

cp /home/jenkins/test-expro-choose.jar /home/jenkins/testTomcat/

rm -rf /home/jenkins/test-expro-choose.jar

echo "正在启动Jar"

java -jar /home/jenkins/testTomcat/test-expro-choose.jar >> /home/jenkins/testTomcat/choose-jarlog.out &

#检测Tomcat是否启动完成
while [ -z "${JAR_PID}" ]
do
 sleep 1
 JAR_PID=`ps -aux | grep 'test-expro-choose.jar' | grep -v grep|awk '{print $2}'`
 echo "正在启动Jar["${JAR_PID}"]..."
done

echo "成功启动Jar.test-expro-choose.jar"
