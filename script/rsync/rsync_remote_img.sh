#!/bin/sh
export PATH=/bin:/sbin:/usr/bin:$PATH
function creating_established_ssh_tunnel {
    var=$(expect -c "
    set timeout 5
    spawn /usr/bin/ssh -o stricthostkeychecking=no -p 222 -f -N -L0.0.0.0:873:192.168.1.100:873 admin@222.92.117.33
    expect \"password:\"
    send \"6379zxc!@0402\r\"
    expect \"\\\\$\"
    ")
    echo $var | perl -pe 's/\r/\n/g'
}
count=`netstat -an|grep -c 0.0.0.0:873`
if [ $count -eq 0 ]; then
    creating_established_ssh_tunnel
fi
export RSYNC_PASSWORD='msun_rsync'
rsync -av msun_rsync@localhost::nfs_img /msun/nfs/img

