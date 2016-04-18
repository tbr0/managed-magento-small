#!/bin/bash
domain=${1}
cat << EOF > /etc/httpd/vhost.d/${domain}.conf
<VirtualHost *:80>
        ServerName ${domain}
        ServerAlias www.${domain}
        #### This is where you put your files for that domain: /var/www/vhosts/${domain}
        DocumentRoot /var/www/vhosts/${domain}

	SetEnvIf X-Forwarded-Proto https HTTPS=on

	#RewriteEngine On
	#RewriteCond %{HTTP_HOST} ^${domain}
	#RewriteRule ^(.*)$ http://www.${domain} [R=301,L]

        <Directory /var/www/vhosts/${domain}>
                Options -Indexes +FollowSymLinks -MultiViews
                AllowOverride All
		Order deny,allow
		Allow from all
        </Directory>
        CustomLog /var/log/httpd/${domain}-access.log combined
        ErrorLog /var/log/httpd/${domain}-error.log
        # New Relic PHP override
        <IfModule php5_module>
               php_value newrelic.appname ${domain}
        </IfModule>
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>

##
# To install the SSL certificate, please place the certificates in the following files:
# >> SSLCertificateFile    /etc/pki/tls/certs/${domain}.crt
# >> SSLCertificateKeyFile    /etc/pki/tls/private/${domain}.key
# >> SSLCACertificateFile    /etc/pki/tls/certs/${domain}.ca.crt
#
# After these files have been created, and ONLY AFTER, then run this and restart Apache:
#
# To remove these comments and use the virtual host, use the following:
# VI   -  :39,$ s/^#//g
# RedHat Bash -  sed -i '39,$ s/^#//g' /etc/httpd/vhost.d/${domain}.conf && service httpd reload
# Debian Bash -  sed -i '39,$ s/^#//g' /etc/apache2/sites-available/${domain} && service apache2 reload
##

#<VirtualHost _default_:443>
#        ServerName ${domain}
#        ServerAlias www.${domain}
#        DocumentRoot /var/www/vhosts/${domain}
#        <Directory /var/www/vhosts/${domain}>
#                Options -Indexes +FollowSymLinks -MultiViews
#                AllowOverride All
#        </Directory>
#
#        CustomLog /var/log/httpd/${domain}-ssl-access.log combined
#        ErrorLog /var/log/httpd/${domain}-ssl-error.log
#
#        # Possible values include: debug, info, notice, warn, error, crit,
#        # alert, emerg.
#        LogLevel warn
#
#        SSLEngine on
#        SSLCertificateFile    /etc/pki/tls/certs/2014-${domain}.crt
#        SSLCertificateKeyFile /etc/pki/tls/private/2014-${domain}.key
#        SSLCACertificateFile /etc/pki/tls/certs/2014-${domain}.ca.crt
#
#        <IfModule php5_module>
#                php_value newrelic.appname ${domain}
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
systemctl reload httpd
