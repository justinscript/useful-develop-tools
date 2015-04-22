#!/bin/sh
# by zxc

#nginx daemon script

#chkconfig:     2345 08 99
#description:   manage script for nginx http(s) server
#processname:   nginx
#config:        /usr/local/nginx/conf/nginx.conf
#pidfile:       /usr/local/nginx/logs/nginx.pid

. /etc/rc.d/init.d/functions

. /etc/sysconfig/network

[ "$NETWORKING" = "no" ] && exit 0

CONFFILE="/usr/local/nginx/conf/nginx.conf"
PIDFILE="/usr/local/nginx/logs/nginx.pid"
NGINX="/usr/local/nginx/sbin/nginx"

prog=$(basename $NGINX)

configtest(){
    echo $"Testing config ..."
    $NGINX -t -c $CONFFILE && rm -f $PIDFILE
    return $?
}

status(){
    test -f $PIDFILE && echo "$prog is running `cat $PIDFILE`" || echo "$prog not running"
}

start(){
    [ -x $NGINX ] || exit 5
    [ -f $CONFFILE ] || exit 6
    configtest || exit 7
    echo $"Starting $prog ..."
    test -f $PIDFILE && (echo "Error: $prog is running" && exit 0) || $NGINX -c $CONFFILE
    retval=$?
    [ $retval -eq 0 ] && echo "Done!" || echo "Error: Fail to start $prog..."
}

stop(){
    echo $"Stopping $prog ..."
    test -f $PIDFILE && kill -QUIT `cat $PIDFILE` || (echo "Error: $prog not running" && exit 0)
    retval=$?
    [ $retval -eq 0 ] && echo "Done!" || echo "Error: Fail to stop $prog..."
}

restart(){
    echo $"Restarting $prog ..."
    test -f $PIDFILE && (kill -HUP `cat $PIDFILE` && echo "Done!") || (echo "$prog not running, trying to start" && start)
}

case $1 in
    status)
        status && exit 0
        ;;
    start)
        start && exit 0
        ;;
    stop)
        stop && exit 0
        ;;
    restart)
        restart && exit 0
        ;;
    configtest)
        configtest && exit 0
        ;;
    *)
        echo $"Usage: $0 {status|start|stop|restart|configtest}"
        exit 2
        ;;
esac