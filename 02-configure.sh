#!/bin/bash

set -e

echo " LDAP Configuration"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo
read -p "Domain Name (example: namit.com): " DOMAIN

DOMAIN=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')

FIRST_PART=$(echo "$DOMAIN" | cut -d'.' -f1)
SECOND_PART=$(echo "$DOMAIN" | cut -d'.' -f2)

BASEDN="dc=$FIRST_PART,dc=$SECOND_PART"
ADMINDN="cn=admin,$BASEDN"
MAILHOST="mail.$DOMAIN"

echo
read -s -p "LDAP Admin Password: " LDAPPASS
echo

HASHED_PASS=$(slappasswd -s "$LDAPPASS")

echo
echo "Configuration Summary"
echo "---------------------"
echo "Domain     : $DOMAIN"
echo "Hostname   : $MAILHOST"
echo "Base DN    : $BASEDN"
echo "Admin DN   : $ADMINDN"
echo

read -p "Proceed? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 1
fi

echo
echo "[1/6] Configuring LDAP Database..."

cat > /tmp/ldap-db.ldif <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $BASEDN
-
replace: olcRootDN
olcRootDN: $ADMINDN
-
replace: olcRootPW
olcRootPW: $HASHED_PASS
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/ldap-db.ldif

echo
echo "[2/6] Creating Base Structure..."

cat > /tmp/base.ldif <<EOF
dn: $BASEDN
objectClass: top
objectClass: dcObject
objectClass: organization

o: $FIRST_PART
dc: $FIRST_PART

dn: ou=users,$BASEDN
objectClass: organizationalUnit
ou: users

dn: ou=groups,$BASEDN
objectClass: organizationalUnit
ou: groups
EOF

ldapadd \
-x \
-D "$ADMINDN" \
-w "$LDAPPASS" \
-f /tmp/base.ldif

echo
echo "[3/6] Creating Configuration Directory..."

mkdir -p /opt/mailserver

echo
echo "[4/6] Saving Configuration..."

cat > /opt/mailserver/mailserver.conf <<EOF
DOMAIN=$DOMAIN
MAILHOST=$MAILHOST

BASEDN=$BASEDN
ADMINDN=$ADMINDN

LDAPPASS=$LDAPPASS
<<<<<<< HEAD
USER_OU=$USER_OU
GROUP_OU=$GROUP_OU
EOF

echo
echo "[1/9] Creating LDAP OUs..."

cat > /tmp/ou.ldif <<EOF

dn: ou=$USER_OU,$BASEDN
objectClass: organizationalUnit
ou: $USER_OU

dn: ou=$GROUP_OU,$BASEDN
objectClass: organizationalUnit
ou: $GROUP_OU

ldapadd -x -D "$ADMINDN" -w "$LDAPPASS" -f /tmp/ou.ldif || true
=======

USER_OU=users
GROUP_OU=groups
EOF

chmod 600 /opt/mailserver/mailserver.conf
>>>>>>> 04af9dc (Completed Postfix Dovecot LDAP Roundcube automation)

echo
echo "[5/6] Verifying LDAP Login..."

ldapwhoami \
-x \
-D "$ADMINDN" \
-w "$LDAPPASS"

echo
echo "[6/6] Verifying LDAP Tree..."

ldapsearch \
-x \
-LLL \
-D "$ADMINDN" \
-w "$LDAPPASS" \
-b "$BASEDN"

echo
echo " LDAP Configuration Complete"

echo
<<<<<<< HEAD
echo "[5/9] Configuring Dovecot LDAP..."

cat > /etc/dovecot/dovecot-ldap.conf.ext <<EOF
hosts = 127.0.0.1

dn = $ADMINDN
dnpass = $LDAPPASS

ldap_version = 3

base = $BASEDN

pass_filter = (&(objectClass=posixAccount)(mail=%u))

user_filter = (&(objectClass=posixAccount)(mail=%u))

default_pass_scheme = SSHA

user_attrs = \
homeDirectory=home,\
uidNumber=uid,\
gidNumber=gid
EOF

echo
echo "[6/9] Configuring Maildir..."

sed -i '/mail_uid = vmail/d' \
/etc/dovecot/conf.d/10-mail.conf

sed -i '/mail_gid = vmail/d' \
/etc/dovecot/conf.d/10-mail.conf

#grep -q "^mail_location" \
#/etc/dovecot/conf.d/10-mail.conf \
#|| echo "mail_location = maildir:~/Maildir" \
#>> /etc/dovecot/conf.d/10-mail.conf

#grep -q "^first_valid_uid" \
#/etc/dovecot/conf.d/10-mail.conf \
#|| echo "first_valid_uid = 1000" \
#>> /etc/dovecot/conf.d/10-mail.conf

echo
echo "[7/9] Configuring LMTP..."

cat > /etc/dovecot/conf.d/99-lmtp.conf <<EOF
service lmtp {
 unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0600
   user = postfix
   group = postfix
 }
}
EOF

echo
echo "[8/9] Configuring Roundcube..."

if [ -f /etc/roundcube/config.inc.php ]; then

sed -i \
"s#\$config\['default_host'\].*#\$config['default_host'] = 'localhost';#" \
/etc/roundcube/config.inc.php || true

sed -i \
"s#\$config\['smtp_host'\].*#\$config['smtp_host'] = 'localhost';#" \
/etc/roundcube/config.inc.php || true

fi

echo
echo "[9/9] Restarting Services..."

systemctl restart postfix
systemctl restart dovecot

echo
echo "========================================"
echo " Configuration Complete"
echo "========================================"

echo
echo "Saved Configuration:"
=======
echo "Configuration File:"
>>>>>>> 04af9dc (Completed Postfix Dovecot LDAP Roundcube automation)
echo "/opt/mailserver/mailserver.conf"
