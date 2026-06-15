#!/bin/bash

set -e

source /opt/mailserver/mailserver.conf

echo "========================================"
echo " Dovecot 2.4 Configuration"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo
echo "[1/8] Creating Mail Storage..."

mkdir -p /var/mail/vhosts/$DOMAIN

groupadd -f vmail

if ! id vmail >/dev/null 2>&1; then
    useradd -r \
        -g vmail \
        -d /var/mail/vhosts \
        -s /usr/sbin/nologin \
        vmail
fi

chown -R vmail:vmail /var/mail/vhosts

echo
echo "[2/8] Backing Up Existing Configuration..."

mkdir -p /opt/mailserver/backup

[ -f /etc/dovecot/conf.d/10-auth.conf ] && cp /etc/dovecot/conf.d/10-auth.conf /opt/mailserver/backup/10-auth.conf.bak

[ -f /etc/dovecot/conf.d/10-master.conf ] && cp /etc/dovecot/conf.d/10-master.conf /opt/mailserver/backup/10-master.conf.bak

[ -f /etc/dovecot/conf.d/auth-ldap.conf.ext ] && cp /etc/dovecot/conf.d/auth-ldap.conf.ext /opt/mailserver/backup/auth-ldap.conf.ext.bak

echo
echo "[3/8] Restoring Default Dovecot Files..."

cp /usr/share/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf

cp /usr/share/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf

echo
echo "[4/8] Configuring LDAP Authentication..."

cat > /etc/dovecot/conf.d/auth-ldap.conf.ext <<EOL
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
EOL

chmod 600 /etc/dovecot/conf.d/auth-ldap.conf.ext

echo
echo "[5/8] Enabling LDAP Authentication..."

sed -i 's/^!include auth-system.conf.ext/#!include auth-system.conf.ext/' /etc/dovecot/conf.d/10-auth.conf

sed -i 's/^#auth_mechanisms.*/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-auth.conf

grep -q "auth-ldap.conf.ext" /etc/dovecot/conf.d/10-auth.conf || echo '!include auth-ldap.conf.ext' >> /etc/dovecot/conf.d/10-auth.conf

echo
echo "[6/8] Configuring Postfix Authentication Socket..."

cat > /etc/dovecot/conf.d/99-auth-postfix.conf <<EOL
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
EOL

echo
echo "[7/8] Configuring LMTP..."

cat > /etc/dovecot/conf.d/99-lmtp.conf <<EOL
protocol lmtp {
}

service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
EOL

echo
echo "[8/8] Validating Configuration..."

doveconf -n >/dev/null

echo "Configuration Valid"

echo
echo "Restarting Dovecot..."

systemctl restart dovecot
systemctl enable dovecot >/dev/null 2>&1 || true

echo
echo "Checking Service..."

systemctl --no-pager status dovecot

echo
echo "========================================"
echo " Dovecot Configuration Complete"
echo "========================================"

