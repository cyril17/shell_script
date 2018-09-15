#!/bin/bash

function bak_data {
    dbname=$1
    d=`date +%y%d`
    host=172.96.207.1
    mysqldump -uroot -h$host -pxxxxxx -P3306 $dbname > /backup/$1.$d
}

tmp_fifofile="/tmp/$$.fifo"
mkfifo $tmp_fifofile
exec 1000<>$tmp_fifofile
rm -f $tmp_fifofile

thread=10
for ((i=0;i<$thread;i++))
do
    echo >&1000
done

for d in `cat /tmp/databases.list`
do
    read -u1000
    {
        bak_data $d
        echo >&1000
    }&
done

wait
exec 1000>&-





