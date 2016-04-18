#!/bin/bash
yum install -y varnish
wget -O /etc/varnish/default.vcl https://raw.githubusercontent.com/tbr0/managed-magento-small/master/resources/default.vcl
systemctl restart varnish
