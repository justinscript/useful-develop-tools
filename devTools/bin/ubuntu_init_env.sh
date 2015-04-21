#! /bin/bash

########################################
#         服务器系统环境初始化
# (初始化环境配置,安装基础软件,配置环境变量）
#
#V1.0   Writen by:zxc   Date:2012-06-10
########################################

# update system 
msun_profile_sh='/etc/profile.d/msun.sh'
msun_run="/usr/msun"
msun_binary=$msun_run
tmp_run='/tmp/run/'

function run_profile {
    if [ -e ${msun_profile_sh} ] ; then
        echo "${msun_profile_sh} alread exist, delete and rewrite ? "
        cat ${msun_profile_sh}
    fi
    tempfile=`mktemp`
cat > $tempfile <<EOF
# msun inc env

# java
export JAVA_HOME=/usr/data/jdk
export PATH=\$JAVA_HOME/bin:\$PATH

# maven
export MAVEN_HOME=/usr/data/maven
export PATH=\${MAVEN_HOME}/bin:\$PATH
EOF
/usr/bin/sudo mv $tempfile ${msun_profile_sh}
chmod +rx ${msun_profile_sh}
. ${msun_profile_sh}
}
function apt_getinstall_tools {
   sudo apt-get install subversion build-essential vim libssl1.0.0 libssl-dev libpcre3 libpcre3-dev nfs-common curl
}
function init_run_apps_env {

    for i in maven jetty jdk httpd nginx
    do
        if [ -e ${msun_run}/${i} ]; then
            rm -rf ${msun_run}/${i}
        fi
    done
    for i in apache-maven-3.0.3 jetty-distribution-7.5.4.v20111024 jdk1.6.0_29 httpd-2.2.21 nginx-1.0.10
    do
        if [ -e ${msun_binary}/${i} ]; then
            rm -rf ${msun_binary}/${i}
        fi
    done
    if [ -e ${tmp_run}/source/jdk1.6.0_29 ]; then
        rm -rf ${tmp_run}/source/jdk1.6.0_29
    fi

    tar -xf ${tmp_run}/source/apache-maven-3.0.3-bin.tar.gz -C ${msun_binary}
    ln -s ${msun_binary}/apache-maven-3.0.3 ${msun_run}/maven
    mv ${msun_run}/maven/conf/settings.xml ${msun_run}/maven/conf/settings.xml.orgi
    cp ${tmp_run}/bin/settings.xml ${msun_run}/maven/conf

    tar -xf ${tmp_run}/source/jetty-distribution-7.5.4.v20111024.tar.gz -C ${msun_binary}
    ln -s ${msun_binary}/jetty-distribution-7.5.4.v20111024 ${msun_run}/jetty

    cd ${tmp_run}/source
    chmod +x jdk-6u29-linux-x64.bin
    bash jdk-6u29-linux-x64.bin
    mv jdk1.6.0_29 ${msun_binary}
    ln -s ${msun_binary}/jdk1.6.0_29 ${msun_run}/jdk

    timestamp=`date +%s`
    compile_dir="/tmp/${timestamp}"
    if [ -e ${compile_dir} ]; then
        rm -rf ${compile_dir}
    fi
    mkdir ${compile_dir}
    
    tar -xf ${tmp_run}/source/httpd-2.2.21.tar.gz -C ${compile_dir}
    cd ${compile_dir}/httpd-2.2.21
    ./configure  --prefix=${msun_binary}/httpd-2.2.21   --with-mpm=worker   --enable-so  --enable-mods-shared=ssl  --enable-rewrite  --enable-proxy   --enable-proxy-http  --enable-deflate  --enable-headers   --enable-expires   --enable-ssl  --with-included-apr && make && make install && ln -s ${msun_binary}/httpd-2.2.21 ${msun_run}/httpd
    cd - 

    tar -xf ${tmp_run}/source/nginx-1.0.10.tar.gz -C ${compile_dir}
    cd ${compile_dir}/nginx-1.0.10
    ./configure   --without-mail_pop3_module   --without-mail_imap_module   --without-mail_smtp_module  --prefix=${msun_binary}/nginx-1.0.10  --with-http_gzip_static_module  --with-http_stub_status_module&& make && make install && ln -s ${msun_binary}/nginx-1.0.10 ${msun_run}/nginx
    cd -
}
function main {
	if [ ! -e $msun_run ]; then
	    mkdir -p $msun_run		
	fi
	run_profile
	apt_getinstall_tools
	init_run_apps_env	
}
main