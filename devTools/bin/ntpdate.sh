#! /bin/bash
### by zxc

service ntpdate start
cat > /etc/cron.daily/ntpdate <<EOF
#!/bin/sh
service ntpdate start
EOF
chmod +x /etc/cron.daily/ntpdate