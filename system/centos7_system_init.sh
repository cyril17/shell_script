#!/bin/bash

echo "centos 7 初始化脚本"

<<COMMENT
  这些事注释内容:
   FILE: CENTOS7-INIT.SH
   USAGE: sh centos7-init.sh
   CREATED: 2018.2.26
   VERSION: 1.0
COMMENT

selinux_conf="/etc/selinux/config"
sshd_conf="/etc/ssh/sshd_config"
# ntp_conf="/etc/ntp.conf"
profile_file="/etc/profile"
limit_file="/etc/security/limits.conf"
dir_s="/data_test"
services="NetworkManager abrt-ccpp.service abrt-oops.service abrtd.service bluetooth.service atd.service mdmonitor.service"


dns=$1

if [ $# -ne 1 ]
then
#判断参数是否为1个
echo "需要输入该服务器的地理位置如：bj"
exit 1
fi

echo "----您选择的dns为$1------"

# 安装基本软件
function install_soft
{
   yum install -y epel-release
   yum update -y
   yum install -y htop iotop iftop atop linux_logo lrzsz
}

# 禁用selinux
function selinux_off
{
   sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" $selinux_conf
}
#设置运行级别为文本
function set_level
{
   ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
}
# 设置dns
function set_dns
{
case $dns in
        bj)
                echo "nameserver 202.106.46.151
nameserver 202.106.46.152" >  /etc/resolv.conf ;;

        xg)
                echo "nameserver 202.130.97.66
nameserver 103.230.216.9" >  /etc/resolv.conf ;;

        sjz)
                echo "nameserver 202.106.46.151
nameserver 202.106.46.152" >  /etc/resolv.conf ;;
        dg)
                echo "nameserver 202.96.128.86
nameserver 202.96.128.96" > /etc/resolv.conf ;;
        *)
                echo "none $dns choice"
                exit;;
esac
}

# 设置ssh
function set_ssh
{
   sed -i "s/\#Port 22/Port 22288/g" $sshd_conf
}

# 创建初始化目录
function set_mkdoc
{
   if [ -d $dir_s ]
   then
   echo "目录已经创建"
   sleep 1
   return
   else
   echo "创建标准目录"
   mkdir $dir_s
   mkdir -p $dir_s/script
   mkdir -p $dir_s/softwate
   fi
}

# 设置时区
function set_time
{
   timedatectl set-timezone Asia/Shanghai
}


function set_history_limit
{
      ### history ####
 if  grep -q "HISTTIMEFORMAT" $profile_file
   then
    break
   else
        echo "# Set History Timestamp,Size
export HISTTIMEFORMAT=\"%Y-%m-%d %H:%M:%S \"
export HISTSIZE=1000
export HISTFILESIZE=10000

# Set open files (-n) 65535.default is 1024

ulimit -HSn 65535

# Set Alias Vi to Vim
alias vi='vim' " >>  $profile_file

  fi

      ### limit ###
        echo "
*               soft            nofile                  50000
*               hard            nofile                  65536
*               soft            nproc                  50000
*               hard            nproc                  50000   " >> $limit_file

echo "
*          soft    nproc     50000
root       soft    nproc     unlimited " >> /etc/security/limits.d/90-nproc.conf

}







# 禁用不必要的系统服务
function set_services
{

   for item in $services
   do
      systemctl disable $item
      #systemctl enable $item
      echo "disable  service $item"
      systemctl stop $item
      #systemctl start $item
      echo " stop service $item !"

   done

   if [ $? -eq 0 ]
   then
   echo "--禁用不必要的服务执行成功--"
   else
   echo "--错误没有执行成功--"
   return
   fi
}


# 磁盘IO调整

function set_diskIO
{
   echo deadline > /sys/block/sda/queue/scheduler
   echo "设置IO调度算法为deadline,默认情况下不适合ssd硬盘"
   iord_expire=`cat /sys/block/sda/queue/iosched/read_expire`
   iowr_expire=`cat /sys/block/sda/queue/iosched/write_expire`
   fr_merges=`cat /sys/block/sda/queue/iosched/front_merges`
   echo "磁盘读过期时间：$iord_expire 写过期时间：$iowr_expire 是否启用写合并：$fr_merges"
   sleep 1

}

# 内核参数调整

function set_kernel
{

cat >> /etc/sysctl.conf << EOF
#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1

# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

#关闭路由转发
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

#关闭sysrq功能
kernel.sysrq = 0

#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1

# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536

#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144

#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800

#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1

#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1

#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1

#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 30

#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000

#修改防火墙表大小，默认65536

#net.netfilter.nf_conntrack_max=655350

#net.netfilter.nf_conntrack_tcp_timeout_established=1200

# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

EOF

/sbin/sysctl -p

echo "内核参数设置完毕！恭喜系统性能已经大大提升"

}

function perform_end
{

   echo "执行结束！`date`"

}

##################################################


install_soft
set_time
set_history_limit
set_services
set_ssh
set_dns
set_mkdoc
set_diskIO
set_kernel
set_level
perform_end

