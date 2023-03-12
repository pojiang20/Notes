#!/bin/bash
if [ $# -eq 0 ]; then
    echo "缺少参数"
    exit
fi
now=$(date +%Y-%m-%d-%H:%M:%S)
filename="$now.log"
nohup ./$1 > $filename 2>&1 &

