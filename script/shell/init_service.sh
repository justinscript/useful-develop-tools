#!/bin/bash
#配置yum
mv /etc/yum.repos.d/CentOS-Debuginfo.repo /etc/yum.repos.d/CentOS-Debuginfo.repo$(date +%m%d)
mv /etc/yum.repos.d/CentOS-Media.repo /etc/yum.repos.d/CentOS-Media.repo$(date +%m%d)
mv /etc/yum.repos.d/CentOS-Vault.repo /etc/yum.repos.d/CentOS-Vault.repo$(date +%m%d)
yum clean all
#系统瘦身
yum -y groupremove "FTP Server" "Text-based Internet" "Windows File Server" "PostgreSQL Database" "News Server" "DNS Name Server" "Web Server" "Dialup Networking Support" "Mail Server" "Office/Productivity" "Ruby" "Office/Productivity" "Sound and Video" "X Window System" "X Software Development" "Printing Support" "OpenFabrics Enterprise Distribution"
#安装依赖包
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel  openldap-clients openldap-servers libxslt-devel libevent-devel ntp  libtool-ltdl bison libtool vim-enhanced
#关闭不必要的服务
chkconfig --list | awk '{print "chkconfig " $1 " off"}' > /tmp/chkconfiglist.sh;/bin/sh /tmp/chkconfiglist.sh;rm -rf /tmp/chkconfiglist.sh
chkconfig  crond on
chkconfig  irqbalance on
chkconfig  network on
chkconfig  sshd on
chkconfig  syslog on
chkconfig  iptables on
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/sysconfig/selinux
#i18n
sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
#修改启动模式
sed -i 's/id:.*$/id:3:initdefault:/g' /etc/inittab
#关闭不需要的tty
sed -i 's/3:2345:respawn/#3:2345:respawn/g' /etc/inittab
sed -i 's/4:2345:respawn/#4:2345:respawn/g' /etc/inittab
sed -i 's/5:2345:respawn/#5:2345:respawn/g' /etc/inittab
sed -i 's/6:2345:respawn/#6:2345:respawn/g' /etc/inittab
sed -i 's/ca::ctrlaltdel/#ca::ctrlaltdel/g' /etc/inittab
/sbin/init q
#修改PS1
echo 'PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\$ \[\e[33;40m\]"' >> /etc/profile
#修改shell命令的history记录个数
sed -i 's/HISTSIZE=.*$/HISTSIZE=100/g' /etc/profile
source /etc/profile
#记录每个命令
echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> /root/.bash_profile
#密码输错5次锁定180s
sed -i '4a auth        required      pam_tally2.so deny=5 unlock_time=180' /etc/pam.d/system-auth
#alias设置
sed -i '7a alias vi=vim' /root/.bashrc
#调整Linux的最大文件打开数
echo "* soft nofile 60000" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf
echo "ulimit -SH 65535" >> /etc/rc.local
#关闭ipv6
sed -i 's/NETWORKING_IPV6=.*$/NETWORKING_IPV6=no/g' /etc/sysconfig/network
#网络参数调整
sed -i 's/net.ipv4.tcp_syncookies.*$/net.ipv4.tcp_syncookies = 1/g' /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 1024 65000' >> /etc/sysctl.conf
sysctl -p
#校正时间
/usr/sbin/ntpdate ntp.api.bz
echo '*/5 * * * * /usr/sbin/ntpdate ntp.api.bz > /dev/null 2>&1' > /var/spool/cron/root;chmod 600 /var/spool/cron/root
/sbin/service crond restart
#iptables配置
sed -i 's/IPTABLES_MODULES="ip_conntrack_netbios_ns"/#IPTABLES_MODULES="ip_conntrack_netbios_ns"/g' /etc/sysconfig/iptables-config
cat > /etc/sysconfig/iptables << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
# -A INPUT -p udp -m udp --dport 20 -j ACCEPT
COMMIT
EOF
/sbin/service atd start
echo "/sbin/service iptables stop" | at now+3minutes
/sbin/service iptables restart
source /etc/profile
