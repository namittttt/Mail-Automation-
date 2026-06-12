#!/bin/bash

BACKUP_DIR="/backup/$(date +%F-%H%M)"

mkdir -p "$BACKUP_DIR"

echo "Creating Backup..."

cp -r /etc/postfix "$BACKUP_DIR/"
cp -r /etc/dovecot "$BACKUP_DIR/"
cp -r /etc/roundcube "$BACKUP_DIR/" 2>/dev/null || true

slapcat > "$BACKUP_DIR/ldap.ldif"

echo
echo "Backup Completed"
echo "Location:"
echo "$BACKUP_DIR"
