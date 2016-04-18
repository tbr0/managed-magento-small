#!/bin/bash
yum install -y lsyncd && curl "https://raw.githubusercontent.com/tbr0/managed-magento-small/master/resources/lsyncd.conf" > /etc/lsyncd.conf
curl "https://raw.githubusercontent.com/tbr0/managed-magento-small/master/resources/lsyncd-excludes.txt" > /etc/lsyncd-excludes.txt
mkdir /var/log/lsyncd
systemctl enable lsyncd && systemctl start lsyncd
