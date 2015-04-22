#!/bin/bash
# by zxc
#Shell下判断输入是否合法IP

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

usage(){
    echo -e "valid ipaddress\nUsage: $0 ipaddress"
    exit 0
}

valid_ip(){
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [ $# -lt 1 ];then
    usage
else
    if valid_ip "$1";then
        echo "$1 is valid ip address"
    else
        echo "$1 is INVALID ip address"
    fi
fi
exit 0