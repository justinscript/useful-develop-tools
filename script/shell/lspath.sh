#!/bin/bash
# by zxc
# 列出指定目录和其子目录下文件数量的shell脚本

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

#Begin
usage(){
        echo -e "Check inode of path\nUsage: $0 [mail|local] [max_length] [path_to_check]"
        exit 0
}

check(){
        if [ -e $2 -a -d $2 ];then
                dirs=`find -P $2 -maxdepth $1 -type d | grep -xv $2 | grep -xv . | sort`
                for d in $dirs
                do
                        if [ -e $d -a -d $d ];then
                                c=$(find -P $d -type f | wc -l)
                                printf "%-70s- %s\n" $d $c
                        fi
                done
                printf "%-70s- $(find -P $2 -type f | wc -l)\n" "Total:"
        else
                echo "Fail to get file dir"
        fi
}

if [ $# -lt 2 ];then
        usage
else
        if [ $3 ];then
                dir=$3
        else
                dir=$(pwd)
        fi
        case $1 in
        "mail")
                TMPLOG=`mktemp`
                echo "`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | head -n 1`" > $TMPLOG
                check $2 $dir >> $TMPLOG 2>&1
                mail -s "CHECKINODE INODE RESULT IN `date`" njutczd@gmail.com < $TMPLOG
                ;;
        "local")
                check $2 $dir
                ;;
        *)
                usage
                ;;
        esac
fi
exit $?
#End