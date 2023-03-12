#!/bin/bash

if [ $# -eq 0 ]; then
    echo "未输入参数"
    exit
fi

if [ -f $1 ]; then
    echo "文件$1存在"
    ls -l $1
elif [ -d $1 ]; then
    echo "目录$1存在"
    ls -l $1
else
    echo "不存在"
fi
