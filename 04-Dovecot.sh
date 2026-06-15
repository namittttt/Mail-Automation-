#!/bin/bash

set -e

source /opt/mailserver/mailserver.conf

echo "========================================"
echo " Dovecot Configuration"
echo "========================================"

echo
echo "[1/7] Creating Mail Storage..."

mkdir -p /var/mail/vhosts/$DOMAIN

groupadd -f vmail

id vmail >/dev/null 2>&1 || 
useradd -r -g vmail -d /var/mail/vhosts -s /usr/sbin/nologin vmail

chown -R vmail:vmail /var/mail/vhosts

echo
echo "[2/7] Configuring LDAP Authentication..."

cat > /etc/dovecot/dovecot-ldap.conf.ext <<EOF
hosts = 127.0.0.1

dn = $ADMINDN
dnpass = $LDAPPASS

ldap_version = 3

base = ou=users,$BASEDN

auth_bind = yes

auth_bind_userdn = uid=%n,ou=users,$BASEDN

pass_filter = (mail=%u)

user_filter = (mail=%u)

user_attrs = 
=home=/var/mail/vhosts/$DOMAIN/%n,
=uid=vmail,
=gid=vmail
EOF

chmod 600 /etc/dovecot/dovecot-ldap.conf.ext

echo
echo "[3/7] Configuring LDAP PassDB..."

cat > /etc/dovecot/conf.d/auth-ldap.conf.ext <<EOF
passdb {
driver = ldap
args = /etc/dovecot/dovecot-ldap.conf.ext
}

userdb {
driver = ldap
args = /etc/dovecot/dovecot-ldap.conf.ext
}
EOF

echo
echo "[4/7] Enabling LDAP Authentication..."

grep -q "auth-ldap.conf.ext" 
/etc/dovecot/conf.d/10-auth.conf || 
echo "!include auth-ldap.conf.ext" \

> > /etc/dovecot/conf.d/10-auth.conf

sed -i 
's/^auth_mechanisms.*/auth_mechanisms = plain login/' 
/etc/dovecot/conf.d/10-auth.conf || true

echo
echo "[5/7] Configuring Postfix Authentication Socket..."

cat > /etc/dovecot/conf.d/99-auth-postfix.conf <<EOF
service auth {
unix_listener /var/spool/postfix/private/auth {
mode = 0660
user = postfix
group = postfix
}
}
EOF

echo
echo "[6/7] Configuring LMTP..."

cat > /etc/dovecot/conf.d/99-lmtp.conf <<EOF
protocol lmtp {
}

service lmtp {
unix_listener /var/spool/postfix/private/dovecot-lmtp {
mode = 0600
user = postfix
group = postfix
}
}
EOF

echo
echo "[7/7] Restarting Dovecot..."

systemctl restart dovecot

echo
echo "Verifying Configuration..."

doveconf -n

echo
echo "========================================"
echo " Dovecot Configuration Complete"
echo "========================================"
