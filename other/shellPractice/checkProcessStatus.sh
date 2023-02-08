#!/bin/bash
if [ $# -eq 0 ]; then
    echo "参数过少"
    exit 
fi
NUM=$(ps -ef | grep $1 | wc -l)
if [ $NUM -eq 1 ]; then
    echo "$1 running."
else
    echo "$1 is not running."
fi
