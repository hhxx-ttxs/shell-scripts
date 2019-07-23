#!/bin/bash


var=$(rpm -qa rsync) 

[ -z "$var" ] && yum install -y rsync &> /dev/null




useradd -M -s /sbin/nologin rsync 


[ ! -d /bakcup ] && mkdir /backup



chown -R rsync:rsync /backup



cat > /etc/rsyncd.conf <<EOF
uid = rsync
gid = rsync
port = 873
fake super = yes
use chroot = no
max connections = 200
timeout = 60
ignore errors 
read only = false
auth users = rsync_backup
secrets file = /etc/rsync.password
log file = /var/log/rsyncd.log



[backup]
comment = welcome to  backup server !
path = /backup



EOF

echo "rsync_backup:1" > /etc/rsync.password

chmod 600 /etc/rsync.password

systemctl start rsyncd &> /dev/null

systemctl enable rsyncd &> /dev/null






echo "Rsync Server Start Successful"

