#!/bin/bash

set -e

echo "========================================"
echo " Mail Server Installation"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo
echo "[1/5] Updating Package Repository..."

apt update

echo
echo "[2/5] Installing Required Packages..."

<<<<<<< HEAD
DEBIAN_FRONTEND=noninteractive apt install -y postfix postfix-ldap dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-ldap slapd ldap-utils roundcube roundcube-core apache2 php php-cli php-common php-ldap php-mbstring php-intl php-mysql pwgen mailutils telnet
=======
DEBIAN_FRONTEND=noninteractive apt install -y \
postfix \
postfix-ldap \
dovecot-core \
dovecot-imapd \
dovecot-pop3d \
dovecot-lmtpd \
dovecot-ldap \
slapd \
ldap-utils \
roundcube \
roundcube-core \
apache2 \
php \
php-cli \
php-common \
php-ldap \
php-mbstring \
php-intl \
php-mysql \
pwgen \
mailutils \
telnet

>>>>>>> 04af9dc (Completed Postfix Dovecot LDAP Roundcube automation)
echo
echo "[3/5] Enabling Services..."

systemctl enable slapd
systemctl enable postfix
systemctl enable dovecot
systemctl enable apache2

echo
echo "[4/5] Starting Services..."

systemctl restart slapd
systemctl restart postfix
systemctl restart dovecot
systemctl restart apache2

echo
echo "[5/5] Verifying Services..."

echo -n "LDAP      : "
systemctl is-active slapd

echo -n "Postfix   : "
systemctl is-active postfix

echo -n "Dovecot   : "
systemctl is-active dovecot

echo -n "Apache2   : "
systemctl is-active apache2

echo
echo "========================================"
echo " Installation Complete"
echo "========================================"
<<<<<<< HEAD
=======

echo
echo "Installed Components:"
echo " - OpenLDAP"
echo " - Postfix"
echo " - Dovecot"
echo " - Roundcube"
echo " - Apache2"
echo " - PHP"
>>>>>>> 04af9dc (Completed Postfix Dovecot LDAP Roundcube automation)
