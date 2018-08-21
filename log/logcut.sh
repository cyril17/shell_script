#!/bin/bash
# 日期：2018/6/22
# 介绍：logcut.sh 简单的日志切割脚本，前3天的切割方便随时看，前4-10天的进行压缩，超出的删除
#
# 注意：会将其他带时间的日志压缩后删除
# 功能：日志切割 <日志格式： xxxxx.当前年-月-日.log> <压缩格式： xxxxx.当前年-月-日.tar.gz>
#
# 适用：centos6+
# 语言：中文

#流程
#主体：先检查是否是log文件，是则检查是否是切割后文件，不是则去切割，是则检查时间是否3天内的，3天外则压缩
#切割：检查是否有这个文件，有则将日志重定向到切割后的文件，清空日志。没有则复制一份，清空日志
#压缩：检查是否有这个文件，有则删除。压缩文件，并删除源文件
#检查压缩：检查是否有tar.gz结尾文件，有则匹配是否带时间，带时间则看是否超过10天，超过删除。不带时间则跳过

#[使用设置]
#日志文件所在目录，将切割这个文件夹下所有日志
log_dir=/ops/logs

#以切割形式保存的文件天数
date_cut=3

#以压缩形式保存的天数
date_yasuo=7



#[自动获取]
#当前年月日
date_now=`date +%F`

#当前年月
date_nian=`date +%Y-`

#前3天数组
date_cut_zu=($(for i in `seq 1 ${date_cut}`;do date -d -${i}days "+%F";done))

#前10天数组
date_time=`expr $date_cut + $date_yasuo`
date_yasuo_zu=($(for i in `seq 1 ${date_time}`;do date -d -${i}days "+%F";done))



#对日志名进行格式处理，$1填写要处理的文件
Format_Name() {
    local a=`echo ${1%%.log}`
    local b=`echo ${a%%-log}`
    echo $b
}

#对传入的日志文件进行切割处理,$1填写要切割文件
Cut_Log() {
    local file=`Format_Name $1`
    local cut_file="${file}.${date_now}.log"

    #先匹配是否已经有这个文件
    ls | grep "^${cut_file}$" &> /dev/null
    if [[ $? -eq 0 ]];then
        cat $1 >> $cut_file
        > $1
    else
        cp -p $i $cut_file
        > $1
    fi
}

#对当前文件进行压缩,$1填写要被压缩的文件
Yasuo_Log() {
    local file=`Format_Name $1`
    local yasuo_file="${file}.log.tar.gz"

    #先匹配是否已经有这个文件
    ls | grep "^${yasuo_file}$" &> /dev/null
    if [[ $? -eq 0 ]];then
        #有则删除，删除的都是3天中的，删除后从新打包
        rm -rf $yasuo_file
    fi

    tar -cf $yasuo_file $1
    rm -rf $i
}

#整理日志文件
Cut_Main() {
    #获取所有日志文件，不包含压缩文件
    for i in `ls | grep .log$`
    do
        #挑出当月的日志文件，否则去压缩
        echo $i | grep ${date_nian} &> /dev/null
        if [[ $? -eq 0 ]];then
            local a=`Format_Name $i`
            local b=`echo ${a:(-10)}` #当前日志年月日
            #看是否在数组中，不在则压缩
            echo ${date_cut_zu[*]} |grep -w $b &> /dev/null
        #echo $date_now
            if [[ $? -ne 0 ]];then
                [[ "$b" != "$date_now" ]] && Yasuo_Log $i
            fi
        else
            Cut_Log $i
        fi
    done
}

#整理压缩的日志文件
Yasuo_Main() {
    #获取所有压缩包
    for i in `ls | grep .tar.gz$`
    do
        echo $i | grep ${date_nian} &> /dev/null
        if [[ $? -eq 0 ]];then
            local a=`echo ${i%%.log.tar.gz}`
            local b=`echo ${a:(-10)}` #当前日志年月日

            #看是否在数组中，不在则删除
            echo ${date_yasuo_zu[*]} |grep -w $b &> /dev/null
            if [[ $? -ne 0 ]];then
                [[ "$b" != "$date_now" ]] && rm -rf $i
            fi
        else
            #不是当月的，其他类型压缩包，跳过
            continue
        fi
    done
}



#开始
if [[ ! -d $log_dir ]];then
    echo "$log_dir not found"
    exit 1
fi
cd $log_dir

Cut_Main
Yasuo_Main