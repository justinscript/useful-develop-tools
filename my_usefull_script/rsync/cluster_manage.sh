#!/usr/bin/bash
# remote ssh action
# 192.168.1.50,192.168.1.51,192.168.1.99,192.168.1.100,192.168.1.101,192.168.1.102,192.168.1.103
# sh cluster_manage.sh 192.168.1.100,192.168.1.101,192.168.1.102,192.168.1.103 "su admin -c 'svn up --username langzi --password 123456 --non-interactive /msun/deploy /msun/run /msun/static/style'"
# sh cluster_manage.sh 192.168.1.100,192.168.1.101,192.168.1.102,192.168.1.103 "su nisa -c '/msun/nisa/deploy/bin/killws' ; su warrior -c '/msun/warrior/deploy/bin/killws' ; su bops -c '/msun/bops/deploy/bin/killws' ; su rhine -c '/msun/rhine/deploy/bin/killws'; service nginx stop" ;
# sh cluster_manage.sh 192.168.1.50,192.168.1.51,192.168.1.99,192.168.1.100,192.168.1.101,192.168.1.102,192.168.1.103 "umount -f  /msun/static/nfs"
# "chmod go-rwx /msun/deploy/bin/* /msun/run/bin/*"
# sh cluster_manage.sh 192.168.1.100,192.168.1.101,192.168.1.102,192.168.1.103 "mount -t nfs -o  rsize=32768,wsize=32768,timeo=16,intr 192.168.1.100:/msun/nfs /msun/static/nfs"
admin_pass='6379zxc!@0402'
root_pass='6379zxc!@0402'
function run_cluster_command {
    if [ $# -lt 2 ]; then
        echo 'error usage: run_cluster_command manage_hosts commands...'
    fi
    ssh_hosts="$1"
    ssh_command="$2"
    for ssh_host in `echo ${ssh_hosts} | tr ',' ' '`
    do
        echo ${ssh_hosts}
        echo ${ssh_command}
        var=$(expect -c "
        set timeout 600
        spawn ssh -o stricthostkeychecking=no admin@${ssh_host}
        expect \"password:\"
        send \"${admin_pass}\r\"
        expect \"\\\\$\"
        send \"su\r\"
        expect \"Password:\"
        send \"${root_pass}\r\"
        expect \"\\\\#\"
        send \"${ssh_command}\r\"
        expect \"\\\\#\"
        ")
        if [ $? != 0 ]; then
            echo "error usage: run_cluster_command manage_hosts commands... $ssh_hosts $ssh_command"
            echo $var | perl -pe 's/\r/\n/g'
            exit 1
        fi
        echo $var | perl -pe 's/\r/\n/g'
    done
}
run_cluster_command "$1" "$2"
