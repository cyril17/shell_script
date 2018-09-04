#!/bin/bash
#mysql数据库备份
DATE=$(date +%F_%H-%M-%S)
HOST=172.16.75.251  #MySQL的主机ip
DB=wordpress    #数据库名
USER=root  #数据库用户名
PASS=123456 #数据库密码
PORT=13333
MAIL="guoshengye@opstest.cn gsy36559067@163.com"  #收取邮箱的地址
BACKUP_DIR=/data/db_backup
SQL_FILE=${DB}_full_$DATE.sql
BAK_FILE=${DB}_full_$DATE.tar.gz
cd $BACKUP_DIR
if mysqldump -h$HOST -u$USER -p$PASS -P$PORT --single-transaction --routines --triggers -B $DB > $SQL_FILE
then
    tar -zcvf  $BAK_FILE $SQL_FILE && rm -f $SQL_FILE
    if [ -s "$BAK_FILE" ]
    then
       echo "$DATE 内容" | mail -A exmail -v -s "博客数据库备份成功" $MAIL
    else
       echo "$DATE 内容" | mail -A exmail -v -s "博客数据库备份失败" $MAIL
    fi
else
    echo "$DATE 内容" | mail -A exmail -v -s "博客数据库备份失败" $MAIL
fi
find $BACKUP_DIR -name '*.tar.gz' -ctime +14 -exec rm {} \;