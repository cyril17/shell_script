#!/usr/bin/env bash

function environment() {
    if [[ "$USER" != "root" ]]; then
        echo "Current user is not root"
        return 1
    fi
    yum -y install wget cmake curl pcre pcre-devel lib zlib zlib-devel gcc gcc-c++ openssl openssl-devel &> /tmp/nginx_install.log
    # getUrl: Input download source address
    # getUrl='http://nginx.org/download/nginx-1.10.3.tar.gz'
    #wget -P /tmp/ $getUrl/nginx.tar.gz
    grep "nginx" /etc/passwd > /dev/null
    if [[ $? -ne 0 ]]; then  # check user and group
        groupadd nginx
        useradd -M -g nginx -s /sbin/nologin nginx
    fi
    echo -e '\e[31mInstallation nginx\e[0m'
    wget http://nginx.org/download/nginx-1.12.2.tar.gz && \
    tar -xzvf  nginx-1.12.2.tar.gz && rm -f nginx-1.12.2.tar.gz && cd nginx-1.12.2 &&\
    return 0
}; environment; [ $? -ne 0 ] && exit 1


function install() {
    # Compile before installation configuration
    ./configure --prefix=/usr/local/nginx \
                --user=nginx --group=nginx \
                --with-http_stub_status_module \
                --with-http_ssl_module \
                --without-http_upstream_ip_hash_module \
                &> /tmp/nginx_install.log
    if [[ $? -ne 0 ]]; then
        return 1
    else
        # make && make install
        make &> /tmp/nginx_install.log
        make install &> /tmp/nginx_install.log
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        return 0
    fi
}; install; [ $? -ne 0 ] && exit 1


function optimize() {
    ln -s /usr/local/nginx/sbin/* /usr/local/sbin/ > /dev/null
    cd ../
    cp `pwd`/nginx.sh  /etc/init.d/nginx
    cp `pwd`/nginx.conf  /usr/local/nginx/conf/nginx.conf
    # The number of CPU cores current server,
    # Amend the "worker_processes" field to the value of the processor
    processor=`cat /proc/cpuinfo | grep "processor" | wc -l`
    sed -i "s/^w.*;$/worker_processes  ${processor};/g" /usr/local/nginx/conf/nginx.conf
    chmod +x /etc/init.d/nginx
    chkconfig --add nginx
    retval=`chkconfig --level 3 nginx on`  # Configure nginx open start service
    return $retval
}; optimize; [ $? -ne 0 ] && exit 1


function run() {
    # Test nginx.conf file syntax is correct
    /etc/init.d/nginx test &> /tmp/nginx_run.log
    if [[ $? -ne 0 ]]; then
        retval=$?
    else  # Start nginx server
        /etc/init.d/nginx start &> /tmp/nginx_run.log
        if [[ $? -ne 0 ]]; then
            retval=$?
        fi
    fi
    return 0
}; run; [ $? -ne 0 ] && exit 1

function check() {
    # Modified index.html page content
    content=$"deployment on $(date "+%Y-%m-%d %H:%M:%S")"
    echo $content > /usr/local/nginx/html/index.html
    # View the index.html, and the output of the modified index.html page
    /etc/init.d/nginx start
    echo -n "Index.html: "; curl http://localhost
}; check