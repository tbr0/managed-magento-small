#heat stack-create -u "https://raw.githubusercontent.com/tbr0/managed-magento-small/master/managed-magento-small.yml" \
heat stack-create -f "managed-magento-small.yml" \
-P 'magento_url=example.com;magento_eula=1' \
stack01-example.com
