vsftpd.conf配置文件解析

#设置为NO代表不允许匿名
anonymous_enable=YES

#设定本地用户可以访问，主要是虚拟宿主用户，如果设为NO那么所欲虚拟用户将无法访问。
local_enable=YES

#可以进行写的操作
write_enable=YES

#设定上传文件的权限掩码
local_umask=022

#禁止匿名用户上传
anon_upload_enable=NO

#禁止匿名用户建立目录
anon_mkdir_write_enable=NO

#设定开启目录标语功能
dirmessage_enable=YES

#设定开启日志记录功能
xferlog_enable=YES

#设定端口20进行数据连接
connect_from_port_20=YES

#设定禁止上传文件更改宿主
chown_uploads=NO

#设定vsftpd服务日志保存路劲。注意：改文件默认不纯在，需手动touch，且由于这里更改了vsftpd服务的宿主用户为手动建立的vsftpd，则必
须注意给予该用户对日志的读取权限否则服务启动失败。
xferlog_file=/var/log/vsftpd.log

#设定日志使用标准的记录格式
xferlog_std_format=YES

#设定空闲链接超时时间，这里使用默认/秒。
#idle_session_timeout=600

#设定最大连接传输时间，这里使用默认，将具体数值留给每个用户具体制定，默认120/秒
data_connection_timeout=3600

#设定支撑vsftpd服务的宿主用户为手动建立的vsftpd用户。注意：一旦更改宿主用户，需一起与该服务相关的读写文件的读写赋权问题.
nopriv_user=vsftpd

#设定支持异步传输的功能
#async_abor_enable=YES

#设置vsftpd的登陆标语
ftpd_banner=hello 欢迎登陆

#禁止用户登出自己的ftp主目录
chroot_list_enable=NO

#禁止用户登陆ftp后使用ls -R 命令。该命令会对服务器性能造成巨大开销，如果该项运行当多个用户使用该命令会对服务器造成威胁。
ls_recurse_enable=NO

#设定vsftpd服务工作在standalone模式下。所谓standalone模式就是该服务拥有自己的守护进程，在ps -A可以看出vsftpd的守护进程名。如果
不想工作在standalone模式下，可以选择SuperDaemon模式，注释掉即可，在该模式下vsftpd将没有自己的守护进程，而是由超级守护进程Xinetd全权代理，>与此同时，vsftpd服务的许多功能，将得不到实现。
listen=YES

#设定userlist_file中的用户将不能使用ftp
userlist_enable=YES


#设定pam服务下的vsftpd验证配置文件名。因此，PAM验证将参考/etc/pam.d/下的vsftpd文件配置。
pam_service_name=vsftpd

#设定支持TCPwrappers
tcp_wrappers=YES

#################################################以下是关于虚拟用户支持的重要配置项目，默认.conf配置文件中是不包含这些项目的，需手动添加。
#启用虚拟用户功能
guest_enable=YES

#指定虚拟的宿主用户
guest_username=virtusers

#设定虚拟用户的权限符合他们的宿主用户
virtual_use_local_privs=YES

#设定虚拟用户个人vsftp的配置文件存放路劲。这个被指定的目录里，将被存放每个虚拟用户个性的配置文件，注意的地方是：配置文件名必须
和虚拟用户名相同。
user_config_dir=/etc/vsftpd/vconf

#禁止反向域名解析，若是没有添加这个参数可能会出现用户登陆较慢，或则客户链接不上ftp的现象
reverse_lookup_enable=NO



虚拟用户的配置

local_root=/opt/vsftp/file
#指定虚拟用户仓库的具路径
anonymous_enable=NO
#设定不允许匿名访问
write_enable=YES
#允许写的操作
local_umask=022
#上传文件的权限掩码
anon_upload_enable=NO
#不允许匿名上传
anon_mkdir_write_enable=NO
#不允许匿名用户建立目录
idle_session_timeout=300
#设定空闲链接超时时间
data_connection_timeout=1000
#设定单次传输最大时间
max_clients=0
#设定并发客户端的访问数量
max_per_ip=0
#设定客户端的最大线程数
local_max_rate=0
#设定用户的最大传输速率，单位b/s