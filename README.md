# Mail Server Automation Suite

## Overview

Mail Server Automation Suite is a Bash-based automation project that deploys and manages a complete mail server infrastructure using:

* Postfix (SMTP Server)
* Dovecot (IMAP/POP3 Server)
* OpenLDAP (User Authentication & Directory Services)
* Roundcube (Webmail Interface)
* Apache2 (Web Server)

The project automates installation, configuration, user management, group alias creation, validation, and mail flow testing.

---

## Features

* Automated package installation
* OpenLDAP configuration
* Postfix SMTP configuration
* Dovecot IMAP/POP3 configuration
* Roundcube webmail integration
* LDAP user creation
* Email group/alias management
* Mail server validation
* Mail flow testing
* Centralized configuration management

---

## Architecture

```text
Browser
   │
   ▼
Roundcube Webmail
   │
 ┌─┴──────────────┐
 ▼               ▼
Dovecot         Postfix
(IMAP/POP3)      (SMTP)
   │
   ▼
 OpenLDAP
   │
   ▼
Maildir Storage
```

---

## Project Structure

```text
mailserver-automation/
│
├── 01-install.sh
├── 02-configure.sh
├── 03-postfixconf.sh
├── 04-Dovecot.sh
├── 05-Roundcube-config.sh
├── 06-create-user.sh
├── 07-create-group.sh
├── 08-validate.sh
├── 09-mailtestflow.sh
│
├── main.sh
├── README.md
├── logs/
├── reference/
└── templates/
```

---

## Scripts Description

### 01-install.sh

Installs required packages:

* Postfix
* Dovecot
* OpenLDAP
* Roundcube
* Apache2
* PHP Modules

---

### 02-configure.sh

Configures:

* LDAP Base DN
* LDAP Admin Account
* Organizational Units (OUs)
* Mail Server Variables

Creates:

```text
/opt/mailserver/mailserver.conf
```

---

### 03-postfixconf.sh

Configures:

* SMTP Service
* LDAP User Lookup
* Virtual Mail Domains
* Virtual Alias Maps
* LMTP Delivery

---

### 04-Dovecot.sh

Configures:

* IMAP
* POP3
* LDAP Authentication
* Maildir Storage
* Authentication Socket
* LMTP Service

---

### 05-Roundcube-config.sh

Configures:

* Roundcube IMAP Connection
* Roundcube SMTP Connection
* Apache Integration

---

### 06-create-user.sh

Creates:

* LDAP User Entry
* Mailbox Directory
* Maildir Structure

Example:

```text
lewis@domain.com
```

---

### 07-create-group.sh

Creates mailing groups and aliases.

Example:

```text
finance@domain.com
```

Forwarded to:

```text
lewis@domain.com
max@domain.com
```

---

### 08-validate.sh

Performs health checks for:

* LDAP
* Postfix
* Dovecot
* Apache
* Roundcube
* LMTP Socket
* Authentication Socket

---

### 09-mailtestflow.sh

Tests:

* User Lookup
* Mail Routing
* SMTP
* IMAP
* Group Aliases
* Mail Queue

---

## Installation

Clone repository:

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd mailserver-automation
```

Make scripts executable:

```bash
chmod +x *.sh
```

Install packages:

```bash
sudo ./01-install.sh
```

Configure LDAP and Mail Server:

```bash
sudo ./02-configure.sh
```

Configure Postfix:

```bash
sudo ./03-postfixconf.sh
```

Configure Dovecot:

```bash
sudo ./04-Dovecot.sh
```

Configure Roundcube:

```bash
sudo ./05-Roundcube-config.sh
```

Create Users:

```bash
sudo ./06-create-user.sh
```

Create Groups:

```bash
sudo ./07-create-group.sh
```

Validate Installation:

```bash
sudo ./08-validate.sh
```

Test Mail Flow:

```bash
sudo ./09-mailtestflow.sh
```

---

Mail Server Automation using Postfix, Dovecot, OpenLDAP, Roundcube and Bash Scripting.
