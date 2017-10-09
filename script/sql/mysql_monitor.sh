#! /bin/bash
# by zxc
# 脚本可以用来对mysql的运行做一些简单的自动化，包括显示当前进程，显示指定变量，显示当前状态，以及kill指定进程。目前所做的事还比较简单，都是通过mysqladmin命令来实现。代码及用法如下，使用前将mysql用户相关信息补全

#命令使用方法
#显示当前状态
#./mysql.sh s
#显示当前进程
#./mysql.sh p
#显示指定的变量，不指定keyword的话显示全部变量
#./mysql.sh v keyword
#显示扩展状态信息，不指定keyword则显示全部
#./mysql.sh e keyword
#kill指定进程
#./mysql.sh k id

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH


BINPATH="`which mysqladmin`"
USER=root
PASS=password

COMMAND="$BINPATH --user=$USER --password=$PASS"

usage(){
    echo -e "show mysql infomation\nUsage: `basename $BINPATH` [ s | p | v keyword | e keyword | k id]"
    exit 0
}

show_status(){
    $COMMAND status
}

show_processlist(){
    $COMMAND processlist
}

show_variables(){
    if [ $1 ];then
        $COMMAND variables | grep -i $1
    else
        $COMMAND variables
    fi
}

show_extended(){
    if [ $1 ];then
        $COMMAND extended-status | grep -i $1
    else
        $COMMAND extended-status
    fi
}

kill_process(){
    if [ $1 ];then
        $COMMAND kill $1
    else
        usage
    fi
}

if [ $# -lt 2 ];then
    usage
else
    case $1 in
    s)
        show_status
        ;;
    p)
        show_processlist
        ;;
    v)
        show_variables $2
        ;;
    e)
        show_extended $2
        ;;
    k)
        kill_process $2
        ;;
    *)
        usage
        ;;
    esac
fi
exit 0