#!/bin/bash
domain=${1}
yum install -y nfs-utils
echo "/var/www/vhosts/$domain/media 192.168.3.0/24(rw,sync,no_root_squash)" >> /etc/exports
echo "/var/www/vhosts/$domain/var 192.168.3.0/24(rw,sync,no_root_squash)" >> /etc/exports
systemctl enable rpcbind && systemctl enable nfs-server
systemctl start rpcbind && systemctl start nfs-server
