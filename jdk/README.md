
下面为声明jdk环境变量
为了在下载jdk时不能通过验证，下载时需加入   --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"
即
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz
或者
ftp://39.104.166.198/jdk-8u172-linux-x64.tar.gz
ftp://39.104.166.198/jdk-7u80-linux-x64.tar.gz
或者
yum install java-1.8.0-openjdk.x86_64


解压，
tar  -xf    jdk-8u151-linux-x64.tar.gz

声明环境变量,
cat  > /etc/profile  <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_151
export JRE_HOME=$JAVA_HOME/jre
export CLASS_PATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
EOF