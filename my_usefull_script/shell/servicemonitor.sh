#!/bin/bash
# by zxc
# 服务监控脚本主要监控apache,nginx,mysql,php,java等服务
#
#    service --> name to test
#    apache --> apache|apache2|http|httpd
#    nginx --> nginx
#    mysql --> mysql|mysqld
#    php-cgi --> php-cgi
#    vsftpd --> vsftp|vsftpd
#    pure-ftpd --> pure-ftp|pure-ftpd
#    apache-tomcat --> java
#    nrpe --> nrpe
# Set the service name you want to test and its max number of processes first.
# Don't forget to check the bin path for each service.

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

SERVICE="httpd mysqld vsftpd nrpe"
SERVICE_MAX=(70 5 5 1)

LOGPATH="/root"
APACHE_PATH="/usr/local/apache2"
NGINX_PATH="/usr/local/nginx"
PHP_PATH="/usr/local/php"
TOMCAT_PATH="/usr/local/apache-tomcat-6.0.26"
PURE_PATH="/usr/local/pureftpd"
NRPE_PATH="/usr/local/nagios"
i=0

if [ -e $LOGPATH/restart.log ]
then
    tail -n 40 $LOGPATH/restart.log > $LOGPATH/restart.tmp
    rm -rf $LOGPATH/restart.log
    mv $LOGPATH/restart.tmp $LOGPATH/restart.log
fi

for serv in $SERVICE
do
    counter=0
    counter=`ps -A | grep "$serv" | wc -l`

    if [ $counter -eq 0 ];then
        echo "$serv is off at $(date), starting..." >> $LOGPATH/restart.log
        case $serv in
            apache*|http*)
                #echo "apache start"
                $APACHE_PATH/bin/apachectl restart >> $LOGPATH/restart.log
                ;;
            nginx)
                #echo "nginx start"
                $NGINX_PATH/sbin/nginx -s reopen >> $LOGPATH/restart.log
                ;;
            mysql*)
                #echo "mysql start"
                #按照一般情况，在搭建服务器时就应该按照统一标准，此处可以按照实际情况修改一下
                if [ -e /etc/init.d/mysqld ];then
                    /etc/init.d/mysqld restart >> $LOGPATH/restart.log
                else
                    /etc/init.d/mysql restart >> $LOGPATH/restart.log
                fi
                ;;
            php-cgi)
                #echo "php-cgi start"
                $PHP_PATH/sbin/php-fpm restart >> $LOGPATH/restart.log
                ;;
            vsftp*)
                #echo "vsftpd start"
                /etc/init.d/vsftpd restart >> $LOGPATH/restart.log
                ;;
            pure-ftp*)
                #echo "pureftpd start"
                $PURE_PATH/sbin/pure-ftpd -B >> $LOGPATH/restart.log
                ;;
            java*)   #apache-tomcat
                #echo "tomcat start"
                $TOMCAT_PATH/bin/startup.sh >> $LOGPATH/restart.log
                ;;
            nrpe)
                #echo "nrpe start"
                $NRPE/bin/nrpe -c $NRPE/etc/nrpe.cfg
                ;;
            *)
                echo "Wrong service name while starting..." >> $LOGPATH/restart.log
                ;;
        esac
    else
        echo "$serv is on at $(date), next service..." >> $LOGPATH/restart.log
    fi

    if [ $counter -gt ${SERVICE_MAX[i]} ];then
        echo "$(date), too many $serv, needs to restart..." >> $LOGPATH/restart.log
        case $serv in
            apache*|http*)
                #echo "apache restart"
                $APACHE_PATH/bin/apachectl restart >> $LOGPATH/restart.log
                ;;
            nginx)
                #echo "nginx restart"
                $NGINX_PATH/sbin/nginx -s reload >> $LOGPATH/restart.log
                ;;
            mysql*)
                #echo "mysql restart"
                if [ -e /etc/init.d/mysqld ];
                then
                    /etc/init.d/mysqld restart >> $LOGPATH/restart.log
                else
                    /etc/init.d/mysql restart >> $LOGPATH/restart.log
                fi
                ;;
            php-cgi)
                #echo "php-cgi restart"
                $PHP_PATH/sbin/php-fpm restart >> $LOGPATH/restart.log
                ;;
            vsftp*)
                #echo "vsftpd restart"
                /etc/init.d/vsftp* restart >> $LOGPATH/restart.log
                ;;
            pure-ftp*)
                #echo "pureftpd restart"
                $PURE_PATH/sbin/pure-ftpd -B >> $LOGPATH/restart.log
                ;;
            java*)   #apache-tomcat
                #echo "tomcat restart"
                $TOMCAT_PATH/bin/startup.sh >> $LOGPATH/restart.log
                ;;
            nrpe)
                #echo "nrpe start"
                killall nrpe
                $NRPE/bin/nrpe -c $NRPE/etc/nrpe.cfg -d
                ;;
            *)
                echo "Warning: Wrong service name while restartiing..."  >> $LOGPATH/restart.log
                ;;
        esac
    fi
    let "i++"
done

exit 0