#!/bin/bash
#Time
log_time=`date +[%Y-%m-%d]%H:%M:%S`

###manual_properties###
tomcat_basehome=/opt/jenkins/test1
tomcat_port=9090
shell_environment=/bin/bash
war_Dir=/opt/jenkins
war_Name=springMVC.war
###manual_properties###

#update server environment
echo "**********************************  ${log_time} *************************************"
echo "updating server  environment start"
export JAVA_HOME=/usr/java/jdk1.8.0_172
export JRE_HOME=/usr/java/jdk1.8.0_172/jre
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar/
export CATALINA_2_HOME=/opt/jenkins/test1
export CATALINA_2_BASE=/opt/jenkins/test1
export TOMCAT_2_HOME=/opt/jenkins/test1
sleep 3
echo "updating server  environment  end"

#build check funcation
echo "check tomcat status..."
check_tomcat_status(){
      netstat -ant|grep ${tomcat_port} > /dev/null
      t=$?
       if [ $t -eq 0 ]; then
           echo "tomcat is running....port is ${tomcat_port}"
           echo "shutdown tomcat....."
           echo ">>>>>>>shutdown tomcat begin<<<<<<<<"
            ${shell_environment} ${tomcat_basehome}/bin/shutdown.sh
           echo ">>>>>>>shutdown tomcat end <<<<<<<<"
           sleep 5
       elif [ $t -ne 0 ];then
             echo "tomcat is poweroff"
              ${shell_environment} ${tomcat_basehome}/bin/shutdown.sh
             sleep 5
       fi
}

#check tomcat status invoke function
check_tomcat_status


#transfer  application package
deploy_Loaction=${tomcat_basehome}/webapps/
war_Dir_Data=`ls ${war_Dir}`
echo "--------------  begin  transfer  war package to tomcat webapps -------------------"

if [ -z $war_Dir ];then
     echo "Folder ${war_Dir} is empty.please check war package in this folder!"
     exit 1
else
     echo "Find ${war_Dir} exist war package ${war_Name}"
    # echo "deleteing old  package ${war_Name} in ${war_Dir}"
    # rm ${war_Dir}/${war_Name}
     echo "deleteing old  package ${war_Name} in ${deploy_Loaction}"
     rm ${deploy_Loaction}${war_Name}
     echo "start  transfer ${war_Name} to ${deploy_Loaction}"
     cp ${war_Dir}/${war_Name}  ${deploy_Loaction}
     sleep 3
fi
echo "--------------  transfer  war package to tomcat webapps  end -------------------"
#reboot tomcat
echo " >>>>>>>  rebooting  tomcat begin <<<<<<<<"
${shell_environment} ${tomcat_basehome}/bin/startup.sh
echo " >>>>>>>  rebooting  tomcat end <<<<<<<<"
echo "the log you can read in canalina.out"
echo "************************ deploy war package into container Successlly  **********************************"