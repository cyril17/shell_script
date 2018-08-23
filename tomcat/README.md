start or stop tomcat process

<<<<<<< HEAD
下载tomcat地址
wget   http://mirrors.shuosc.org/apache/tomcat/tomcat-8/v8.0.47/bin/apache-tomcat-8.0.47.tar.gz
=======


下载tomcat地址
wget   http://mirrors.shuosc.org/apache/tomcat/tomcat-8/v8.0.47/bin/apache-tomcat-8.0.47.tar.gz


>>>>>>> 1adf205e8481084e0e70e59a916b53d8c38150bc
或者
wget -c http://mirrors.shu.edu.cn/apache/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz



maven打包命令
mvn -DskipTests=true clean package
命令执行完成后, 在应用目录/target/下会有打出来的包,
