#! /bin/bash

############################################
#           服务器系统开发环境安装
# (install maven,tomcat,jdk,memcached,nginx)
#
#V1.0   Writen by:zxc   Date:2012-06-10
############################################

root_passwd='6379zxc!@'
admin_passwd='6379zxc!@'
svn_user='zxc337'
svn_passwd='123456'
svn_host_count=`grep -c 'svn.msun-inc.com' /etc/hosts`
yum clean all
yum groupinstall -y 'Development tools' 'Additional Development' 'Server Platform Development'
if [ ${svn_host_count} -le 0 ]; then
    echo '192.168.1.181 svn.msun-inc.com' >> /etc/hosts
fi
mvn_repo_count=`grep -c 'repo.msun-inc.com' /etc/hosts`
if [ ${mvn_repo_count} -le 0 ]; then
    echo '192.168.1.181 repo.msun-inc.com' >> /etc/hosts
fi
msun_dir='/msun/'
run_dir='/msun/run'
deploy_dir='/msun/deploy'
if [ ! -e ${msun_dir} ]; then
    mkdir ${msun_dir}
fi
if [ -e ${run_dir} ] || [ -e ${deploy_dir} ] ; then
    echo "${run_dir} or ${deploy_dir} dir already exists, exit now";
    exit 1;
fi
admin_group_count=`grep -c '^admin:' /etc/group`
if [ ${admin_group_count} -le 0 ]; then
    groupadd admin
fi
admin_user_count=`grep -c '^admin:' /etc/passwd`
if [ ${admin_user_count} -le 0 ]; then
    adduser admin -g admin
fi
usermod -g admin admin
chown admin.admin ${msun_dir}
echo ${admin_passwd} | passwd admin --stdin
echo ${root_passwd} | passwd root --stdin
su admin -c     "cd ${msun_dir} && \
        svn co http://svn.msun-inc.com/svn/app/standalone/script/trunk/run  \
        --username ${svn_user} --password ${svn_passwd} --non-interactive run && \
        svn co http://svn.msun-inc.com/svn/app/standalone/script/trunk/deploy \
        --username ${svn_user} --password ${svn_passwd} --non-interactive deploy \
        "
bash /msun/run/bin/init_env.sh
su admin -c     "bash /msun/run/bin/init_apps.sh"
