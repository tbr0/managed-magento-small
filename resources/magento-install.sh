#!/bin/bash
DOMAIN=${1}
DB_HOST=${2}
DB_NAME=${3}
DB_USER=${4}
DB_PASS=${5}

echo "Need to disable requiretty so we can run commands as Apache." && \
sed -i /etc/sudoers -e "s/Defaults    requiretty/#Defaults     requiretty/g" && \
echo "Installing Magento Depedencies" && \
yum install -y php56u-mcrypt php56u-soap && \
echo "Configuring Virtual Host" && \
curl -s -H "Host: ${DOMAIN}" http://justcurl.com | bash && \
systemctl reload httpd && \
echo "Downloading Latest Magento" && \
wget -O /var/www/vhosts/${DOMAIN}/magento.tgz http://c92a3489532391bf268e-49b46254d7042badb24da80286b0d71b.r87.cf5.rackcdn.com/magento-1.9.2.2.tar-2015-10-27-03-19-32.gz && \
cd /var/www/vhosts/${DOMAIN} && \
tar xvzf magento.tgz && \
rm magento.tgz && \
echo "Applying Permissions" && \
chown -R root:apache /var/www/vhosts/${DOMAIN} && \
find /var/www/vhosts/${DOMAIN} -type d -print0 | xargs -0 chmod 02775 && find /var/www/vhosts/${DOMAIN} -type f -print0 | xargs -0 chmod 0664 && \
## Magento Install Over PHP-CLI ##
echo "Installing Magento over PHP-CLI" && \
sudo -u apache /bin/php -f /var/www/vhosts/${DOMAIN}/install.php -- \
--license_agreement_accepted "yes" \
--locale "en_US" \
--timezone "America/Los_Angeles" \
--default_currency "USD" \
--db_host "${DB_HOST}" \
--db_name "${DB_NAME}" \
--db_user "${DB_USER}" \
--db_pass "${DB_PASS}" \
--url "http://${DOMAIN}/" \
--skip_url_validation "yes" \
--use_rewrites "yes" \
--use_secure "no" \
--secure_base_url "no" \
--use_secure_admin "no" \
--admin_firstname "Joe" \
--admin_lastname "User" \
--admin_email "admin@example.com" \
--admin_username "admin" \
--admin_password "test123" \
echo "Done."
