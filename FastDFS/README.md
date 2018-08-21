此脚本前提为NGINX未安装，如果之前编译安装目录为/usr/local/nginx，则备份配置文件后可以直接运行此脚本


nginx1.12.2 编译出现 /usr/include/fastdfs/fdfs_define.h:15:27: fatal error: common_define.h: No such file or directory #31

/usr/include/fastdfs/fdfs_define.h:15:27: 致命错误：common_define.h：没有那个文件或目录
 #include "common_define.h"


修改fastdfs-nginx-module-1.20/src/config文件，修改如下：
ngx_module_incs="/usr/include/fastdfs /usr/include/fastcommon/"
CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
然后重新configure make make install，就可以.
