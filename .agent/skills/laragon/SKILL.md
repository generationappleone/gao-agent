---
name: Laragon
description: Skill for setting up and managing Laragon local development environment on Windows, covering auto virtual hosts, multi-PHP, SSL, services, and quick project creation.
---

# Laragon Skill

## Overview
Laragon is a fast, portable Windows development environment with auto virtual hosts, multi-PHP support, and one-click project creation. Superior to XAMPP for modern PHP development.

## Installation
- Download from [laragon.org](https://laragon.org/download/) (Full or Lite edition)
- Install to `C:\laragon` (portable — no system modifications)
- Start Laragon → "Start All"

## Key Advantages Over XAMPP
| Feature | Laragon | XAMPP |
|---------|---------|-------|
| Auto virtual hosts | ✅ Automatic | ❌ Manual config |
| SSL per project | ✅ One-click | ❌ Manual |
| Multi-PHP versions | ✅ Easy switch | ❌ Single version |
| Quick create | ✅ Laravel, WordPress, etc. | ❌ Manual |
| Portable | ✅ Fully | ❌ Partially |
| Modern services | ✅ Nginx, Redis, MongoDB | ❌ Limited |

## Directory Structure
```
C:\laragon\
├── bin\
│   ├── apache\           # Apache versions
│   ├── nginx\             # Nginx versions
│   ├── php\               # Multiple PHP versions
│   │   ├── php-8.2.15\
│   │   ├── php-8.3.3\
│   │   └── php-8.4.1\
│   ├── mysql\             # MySQL/MariaDB
│   ├── redis\             # Redis server
│   ├── nodejs\            # Node.js
│   └── git\               # Git
├── etc\
│   ├── apache2\
│   │   └── sites-enabled\ # Auto-generated vhosts
│   └── ssl\               # SSL certificates
├── www\                   # Projects root
│   ├── mylaravel\         # → mylaravel.test
│   ├── mywordpress\       # → mywordpress.test
│   └── myapp\             # → myapp.test
└── laragon.exe            # Control panel
```

## Auto Virtual Hosts
Laragon automatically creates virtual hosts for every folder in `C:\laragon\www\`:

```
C:\laragon\www\myproject\  →  http://myproject.test
C:\laragon\www\blog\       →  http://blog.test
C:\laragon\www\api\        →  http://api.test
```

### Custom Document Root (Laravel/PHP frameworks)
```apache
# Laragon Menu → Apache → sites-enabled → auto.mylaravel.test.conf
# Auto-generated, but can be customized:

<VirtualHost *:80>
    DocumentRoot "C:/laragon/www/mylaravel/public"
    ServerName mylaravel.test
    <Directory "C:/laragon/www/mylaravel/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

## Quick Project Creation
```
Right-click Laragon tray → Quick app →
├── Laravel          # Creates Laravel project
├── WordPress        # Downloads & configures WordPress
├── Symfony          # Creates Symfony project
├── CodeIgniter      # Creates CI project
└── Custom...        # Custom Composer create-project
```

## Multi-PHP Version
```
1. Download PHP version from windows.php.net
2. Extract to C:\laragon\bin\php\php-x.x.x\
3. Laragon Menu → PHP → Select version
4. Restart Apache
```

## One-Click SSL
```
Right-click Laragon tray → Apache → SSL → Enable
# Generates self-signed cert for all .test domains
# Access: https://myproject.test
```

## Services Management
```
Laragon supports:
├── Web Server:   Apache or Nginx (switch with one click)
├── Database:     MySQL, MariaDB, PostgreSQL
├── Cache:        Redis, Memcached
├── Queue:        RabbitMQ
├── Search:       Elasticsearch
├── Mail:         MailHog (email testing)
└── Runtime:      Node.js, Python, Ruby, Go
```

## Database
```bash
# Default credentials
# Host: localhost
# User: root
# Password: (empty)
# Port: 3306

# Access via Laragon Terminal
mysql -u root -e "CREATE DATABASE myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

## Laragon Terminal
Laragon provides a pre-configured terminal with all tools in PATH:
```bash
# All these work out of the box:
php artisan serve
composer create-project laravel/laravel myapp
node -v && npm -v
git --version
mysql -u root
redis-cli ping
```

## php.ini Quick Settings
```
Laragon Menu → PHP → php.ini
# Key development settings auto-configured:
# display_errors = On
# upload_max_filesize = 128M
# max_execution_time = 300
```

## Tips & Best Practices
- Use `.test` TLD (auto-configured by Laragon)
- Keep PHP versions in separate folders under `bin\php\`
- Use Laragon Terminal instead of Windows CMD for PATH support
- Enable Redis for Laravel cache/session/queue development
- Use MailHog for email testing (`MAIL_HOST=localhost`, `MAIL_PORT=1025`)

## Rules Integration
- **Security**: Development only — never expose Laragon to the internet
- **Dependencies**: Easy PHP version switching helps test compatibility
