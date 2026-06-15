#!/bin/bash

set -e

source /opt/mailserver/mailserver.conf

echo "========================================"
echo " Dovecot 2.4 Configuration"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
echo "Run as root"
exit 1
fi

echo
echo "[1/8] Creating Mail Storage..."

mkdir -p /var/mail/vhosts/$DOMAIN

groupadd -f vmail

id vmail >/dev/null 2>&1 || 
useradd -r 
-g vmail 
-d /var/mail/vhosts 
-s /usr/sbin/nologin 
vmail

chown -R vmail:vmail /var/mail/vhosts

echo
echo "[2/8] Backing Up Existing Configuration..."

mkdir -p /opt/mailserver/backup

cp -f /etc/dovecot/conf.d/10-auth.conf 
/opt/mailserver/backup/10-auth.conf.bak 2>/dev/null || true

cp -f /etc/dovecot/conf.d/10-master.conf 
/opt/mailserver/backup/10-master.conf.bak 2>/dev/null || true

cp -f /etc/dovecot/conf.d/auth-ldap.conf.ext 
/opt/mailserver/backup/auth-ldap.conf.ext.bak 2>/dev/null || true

echo
echo "[3/8] Configuring LDAP Authentication..."

cat > /etc/dovecot/conf.d/auth-ldap.conf.ext <<EOF
ldap_uris = ldap://127.0.0.1

ldap_auth_dn = $ADMINDN
ldap_auth_dn_password = $LDAPPASS

ldap_base = ou=users,$BASEDN

passdb ldap {

ldap_filter = (&(objectClass=posixAccount)(mail=%{user}))

ldap_bind = yes
}

userdb ldap {

fields {
home = %{ldap:homeDirectory}
uid = vmail
gid = vmail
}

ldap_filter = (&(objectClass=posixAccount)(mail=%{user}))
}
EOF

chmod 600 /etc/dovecot/conf.d/auth-ldap.conf.ext

echo
echo "[4/8] Enabling LDAP Authentication..."

sed -i 
's/^!include auth-system.conf.ext/#!include auth-system.conf.ext/' 
/etc/dovecot/conf.d/10-auth.conf

grep -q "auth-ldap.conf.ext" 
/etc/dovecot/conf.d/10-auth.conf || 
echo '!include auth-ldap.conf.ext' \

> > /etc/dovecot/conf.d/10-auth.conf

sed -i 
's/^#auth_mechanisms.*/auth_mechanisms = plain login/' 
/etc/dovecot/conf.d/10-auth.conf || true

echo
echo "[5/8] Configuring Mail Storage..."

grep -q "^mail_driver" /etc/dovecot/dovecot.conf || 
cat >> /etc/dovecot/dovecot.conf <<EOF

mail_driver = maildir
mail_path = ~/Maildir
EOF

echo
echo "[6/8] Configuring Postfix Authentication Socket..."

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
echo "[7/8] Configuring LMTP..."

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
echo "[8/8] Validating Configuration..."

doveconf -n >/dev/null

echo "Configuration Valid"

echo
echo "Restarting Dovecot..."

systemctl restart dovecot

systemctl enable dovecot

echo
echo "Checking Service..."

systemctl --no-pager --full status dovecot

echo
echo "========================================"
echo " Dovecot Configuration Complete"
echo "========================================"

