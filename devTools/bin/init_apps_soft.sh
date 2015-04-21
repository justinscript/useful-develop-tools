#! /bin/bash

############################################
#           服务器系统开发环境安装
# (install maven,tomcat,jdk,memcached,nginx)
#
#V1.0   Writen by:zxc   Date:2012-06-10
############################################

#set config
msun='/data'
msun_run='/data/run'
msun_run_bin='/data/run/bin'
msun_source='/data/run/source'
msun_binary='/data/run/binary'

function pre_check {
    if [ ! -e ${msun_run} ] || [ ! -e ${msun_source} ] || [ ! -e ${msun_binary} ]; then
        echo "ERROR"
        exit 1
    fi
}
function init_run_apps_env {

    for i in maven tomcat jdk memcached nginx
    do
        if [ -e ${msun_run}/${i} ]; then
            rm -rf ${msun_run}/${i}
        fi
    done
    for i in apache-maven-3.0.5 apache-tomcat-7.0.54 jdk1.7.0_55 memcached-1.4.15 nginx-1.7.1
    do
        if [ -e ${msun_binary}/${i} ]; then
            rm -rf ${msun_binary}/${i}
        fi
    done
    if [ -e ${msun_source}/jdk1.7.0_55 ]; then
        rm -rf ${msun_source}/jdk1.7.0_55
    fi

    tar -xf ${msun_source}/apache-maven-3.0.5-bin.tar.gz -C ${msun_binary}
    ln -s ${msun_binary}/apache-maven-3.0.5 ${msun_run}/maven
    cp ${msun_run}/maven/conf/settings.xml ${msun_run}/maven/conf/settings.xml.orgi
    ##cp ${msun_run_bin}/settings.xml ${msun_run}/maven/conf

    tar -xf ${msun_source}/apache-tomcat-7.0.54.tar.gz -C ${msun_binary}
    ln -s ${msun_binary}/apache-tomcat-7.0.54 ${msun_run}/tomcat

    tar -xf ${msun_source}/jdk-7u55-linux-x64.tar.gz -C ${msun_binary}
    ln -s ${msun_binary}/jdk1.7.0_55 ${msun_run}/jdk

    tar -xf ${msun_source}/memcached-1.4.15.tar.gz -C ${compile_dir}
    cd ${compile_dir}/memcached-1.4.15
    ./configure  --enable-64bit  --prefix=${msun_binary}/memcached-1.4.15  --with-libevent=/usr/local/ && make && make install && ln -s ${msun_binary}/memcached-1.4.15 ${msun_run}/memcached
    cd -

    timestamp="init_env_"`date +%s`
    compile_dir="/tmp/${timestamp}"
    if [ -e ${compile_dir} ]; then
        rm -rf ${compile_dir}
    fi
    mkdir ${compile_dir}

    tar -xf ${msun_source}/nginx-1.7.1.tar.gz -C ${compile_dir}
    cd ${compile_dir}/nginx-1.7.1
    ./configure   --without-mail_pop3_module   --without-mail_imap_module   --without-mail_smtp_module  --prefix=${msun_binary}/nginx-1.7.1  --with-http_gzip_static_module  --with-http_stub_status_module&& make && make install && ln -s ${msun_binary}/nginx-1.7.1 ${msun_run}/nginx
    cd -

}

function main {
    pre_check
    init_run_apps_env
}
main
