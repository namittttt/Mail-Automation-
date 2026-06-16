#!/bin/bash

set -e

source /opt/mailserver/mailserver.conf

echo "========================================"
echo " Roundcube Configuration"
echo "========================================"

if [ ! -f /etc/roundcube/config.inc.php ]; then
    echo "Roundcube not installed."
    exit 1
fi

echo
echo "[1/5] Configuring Roundcube IMAP..."

#sed -i "/default_host/c\\\$config['default_host'] = 'localhost';" \
#/etc/roundcube/config.inc.php || true

grep -q "imap_host" /etc/roundcube/config.inc.php || \
echo "\$config['imap_host'] = 'localhost';" \
>> /etc/roundcube/config.inc.php

echo
echo "[2/5] Configuring Roundcube SMTP..."

sed -i "/smtp_host/c\\\$config['smtp_host'] = 'localhost';" \
/etc/roundcube/config.inc.php || true

grep -q "smtp_host" /etc/roundcube/config.inc.php || \
echo "\$config['smtp_host'] = 'localhost';" \
>> /etc/roundcube/config.inc.php

#grep -q "smtp_port" /etc/roundcube/config.inc.php || \
#echo "\$config['smtp_port'] = 25;" \
#>> /etc/roundcube/config.inc.php

echo
echo "[3/5] Setting Product Name..."

grep -q "product_name" /etc/roundcube/config.inc.php || \
echo "\$config['product_name'] = 'Namit Mail';" \
>> /etc/roundcube/config.inc.php

echo
echo "[4/5] Configuring Apache Virtual Host..."

cat > /etc/apache2/sites-available/mail.conf <<EOF
<VirtualHost *:80>

    ServerName $MAILHOST

    DocumentRoot /var/lib/roundcube/public_html

    <Directory /var/lib/roundcube/public_html>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/mail-error.log
    CustomLog \${APACHE_LOG_DIR}/mail-access.log combined

</VirtualHost>
EOF

a2dissite 000-default.conf >/dev/null 2>&1 || true
a2ensite mail.conf

systemctl reload apache2

echo
echo "[5/5] Verification..."

apache2ctl configtest

echo
echo "========================================"
echo " Roundcube Configuration Complete"
echo "========================================"

echo
echo "Access URL:"
echo "http://$MAILHOST"
echo

echo "Roundcube IMAP Host : localhost"
echo "Roundcube SMTP Host : localhost"

