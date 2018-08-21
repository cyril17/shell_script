#!/bin/bash
# 日期：2018/4/23
# 介绍：bid-free.sh 用于hadoop的双向免密脚本，让填写机器互相之间免密登陆
#
# 注意：请勿修改脚本名,需要安装sshpass，也就是需要yum可用
# 功能：让填写机器互相之间免密登陆
#
# 适用：centos6+
# 语言：中文


#[使用设置]
#填写所有ip，空格分开
ip=(192.168.2.107 192.168.2.113 192.168.2.188)

#填写密码，需要统一密码
passwd=123456



#检测是否有值
if [ ! $passwd ];then
    echo '$passwd not found'
    exit
fi

a=`echo ${ip[0]}`

if [ ! ${a} ];then
    echo '$ip not found'
    exit
fi

create_sha() {
mkdir -p ~/.ssh
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
}

sshp() {
rpm -q sshpass
if [ $? -ne 0 ];then
    yum -y install sshpass
    rpm -q sshpass
    if [ $? -eq 0 ];then
        echo "sshpass install no"
    fi
fi
}

#检测本机
[ -f ~/.ssh/id_rsa ] || create_sha

sshp


for ip in `echo ${ip[*]}`
do
    a="sshpass -p $passwd  ssh root@${ip} -o StrictHostKeyChecking=no"

    $a mkdir -p /root/.ssh
    cat /root/.ssh/id_rsa.pub | $a 'cat >> /root/.ssh/authorized_keys'
    $a chmod 600 /root/.ssh/authorized_keys

    b=`$a [ -f mi.sh ] && echo 1 || echo 2`
    if [ $b -eq 1 ];then
        echo " $ip ok"
    else
        sshpass -p "$passwd" scp bid-free.sh root@${ip}:/root/
        $a chmod +x bid-free.sh
        $a bash bid-free.sh
    fi
done