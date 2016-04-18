#!/bin/bash
DOMAIN=${1}
cat << EOF > /etc/httpd/vhost.d/${DOMAIN}.conf
<VirtualHost *:80>
        ServerName ${DOMAIN}
        ServerAlias www.${DOMAIN}
        #### This is where you put your files for that domain: /var/www/vhosts/${DOMAIN}
        DocumentRoot /var/www/vhosts/${DOMAIN}

	SetEnvIf X-Forwarded-Proto https HTTPS=on

	#RewriteEngine On
	#RewriteCond %{HTTP_HOST} ^${DOMAIN}
	#RewriteRule ^(.*)$ http://www.${DOMAIN} [R=301,L]

        <Directory /var/www/vhosts/${DOMAIN}>
                Options -Indexes +FollowSymLinks -MultiViews
                AllowOverride All
		Order deny,allow
		Allow from all
        </Directory>
        CustomLog /var/log/httpd/${DOMAIN}-access.log combined
        ErrorLog /var/log/httpd/${DOMAIN}-error.log
        # New Relic PHP override
        <IfModule php5_module>
               php_value newrelic.appname ${DOMAIN}
        </IfModule>
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>

##
# To install the SSL certificate, please place the certificates in the following files:
# >> SSLCertificateFile    /etc/pki/tls/certs/${DOMAIN}.crt
# >> SSLCertificateKeyFile    /etc/pki/tls/private/${DOMAIN}.key
# >> SSLCACertificateFile    /etc/pki/tls/certs/${DOMAIN}.ca.crt
#
# After these files have been created, and ONLY AFTER, then run this and restart Apache:
#
# To remove these comments and use the virtual host, use the following:
# VI   -  :39,$ s/^#//g
# RedHat Bash -  sed -i '39,$ s/^#//g' /etc/httpd/vhost.d/${DOMAIN}.conf && service httpd reload
# Debian Bash -  sed -i '39,$ s/^#//g' /etc/apache2/sites-available/${DOMAIN} && service apache2 reload
##

#<VirtualHost _default_:443>
#        ServerName ${DOMAIN}
#        ServerAlias www.${DOMAIN}
#        DocumentRoot /var/www/vhosts/${DOMAIN}
#        <Directory /var/www/vhosts/${DOMAIN}>
#                Options -Indexes +FollowSymLinks -MultiViews
#                AllowOverride All
#        </Directory>
#
#        CustomLog /var/log/httpd/${DOMAIN}-ssl-access.log combined
#        ErrorLog /var/log/httpd/${DOMAIN}-ssl-error.log
#
#        # Possible values include: debug, info, notice, warn, error, crit,
#        # alert, emerg.
#        LogLevel warn
#
#        SSLEngine on
#        SSLCertificateFile    /etc/pki/tls/certs/2014-${DOMAIN}.crt
#        SSLCertificateKeyFile /etc/pki/tls/private/2014-${DOMAIN}.key
#        SSLCACertificateFile /etc/pki/tls/certs/2014-${DOMAIN}.ca.crt
#
#        <IfModule php5_module>
#                php_value newrelic.appname ${DOMAIN}
#        </IfModule>
#        <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
#                SSLOptions +StdEnvVars
#        </FilesMatch>
#
#        BrowserMatch \"MSIE [2-6]\" \
#                nokeepalive ssl-unclean-shutdown \
#                downgrade-1.0 force-response-1.0
#        BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown
#</VirtualHost>
EOF
mkdir /var/www/vhosts/${DOMAIN}
systemctl reload httpd
