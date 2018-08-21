- hosts: local
  tasks:
   - name: "create the tmp directory!"
     command: mkdir /usr/local/tmp
   - name: "delivery the war to the remote_host!"
     copy:
       src=/opt/jenkins/workspace/maven_test/target/oa.war
       dest=/usr/local/tmp/
   - name: "unzip the war!"
     command: unzip -qo /usr/local/tmp/quick4j.war -d  /tmp/jenkins/quick/webapps/ROOT/
   - name: "delete the tmp"
     command: rm -rf /usr/local/tmp
   - name: "stop the tomcat"
     shell: "ps -ef |grep tomcat |grep /tmp/jenkins/quick | grep -v grep |awk ‘{print $2}‘ |xargs kill -9"
   - name: "start the tomcat"
     shell: chdir=/tmp/jenkins/quick/bin nohup ./catalina.sh start &
