#!/bin/bash
# by zxc
#一个根据find命令组合的脚本，能够用来在指定目录下对指定后缀的文件搜索指定关键词或者在指定目录下根据指定的修改时间进行搜索文件

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

usage(){
    echo -e "find files\nUsage: $0 {s directory extension keyword|t directory [d|m] num extension}"
    exit 0
}

if [ $# -lt 4 ];then
    usage
else
    case $1 in
    s)
        if [ -e $2 -a -d $2 ];then
            find -P $2 -type f -name "*.$3" | xargs fgrep -n -H -R -s -l "$4" | xargs ls -lh
        else
            echo "$2 not exist or not a directory"
            exit 1
        fi
        ;;
    t)
        if [ $# -lt 5 ];then
            usage
        else
            if [ -e $2 -a -d $2 ];then
                case $3 in
                d)
                    find -P $2 -type f -name "*.$5" -ctime $4
                    ;;
                m)
                    find -P $2 -type f -name "*.$5" -cmin $4
                    ;;
                *)
                    usage
                    ;;
                esac
            else
                echo "$2 not exist or not a directory"
                exit 1
            fi
        fi
        ;;
    *)
        usage
        ;;
    esac
fi
exit $?