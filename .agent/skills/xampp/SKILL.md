---
name: XAMPP
description: Skill for setting up and managing XAMPP local development environment, covering Apache, MySQL/MariaDB, PHP configuration, virtual hosts, and multi-project setup.
---

# XAMPP Skill

## Overview
XAMPP is a cross-platform local development stack: Apache + MariaDB + PHP + Perl. Use for rapid PHP development and testing on Windows, macOS, and Linux.

## Installation
- **Windows**: Download from [apachefriends.org](https://www.apachefriends.org/) → Install to `C:\xampp`
- **macOS**: Download `.dmg` → Install to `/Applications/XAMPP`
- **Linux**: `chmod +x xampp-linux-*-installer.run && sudo ./xampp-linux-*-installer.run`

## Directory Structure
```
C:\xampp\                        # Windows
├── apache\
│   └── conf\
│       ├── httpd.conf           # Apache main config
│       └── extra\
│           ├── httpd-vhosts.conf # Virtual hosts
│           └── httpd-ssl.conf    # SSL config
├── htdocs\                      # Document root (projects go here)
│   ├── myproject\
│   └── dashboard\
├── mysql\
│   ├── bin\                     # MySQL binaries
│   └── data\                    # Database files
├── php\
│   └── php.ini                  # PHP configuration
├── phpMyAdmin\                  # Database admin UI
└── xampp-control.exe            # Control panel
```

## PHP Configuration (php.ini)
```ini
; Key settings for development
display_errors = On
error_reporting = E_ALL
max_execution_time = 300
max_input_time = 300
memory_limit = 512M
post_max_size = 128M
upload_max_filesize = 128M
max_file_uploads = 50
date.timezone = Asia/Jakarta

; Extensions (uncomment as needed)
extension=gd
extension=intl
extension=mbstring
extension=pdo_mysql
extension=zip
extension=curl
extension=soap
extension=sodium
extension=openssl
```

## Virtual Hosts (Multi-Project)
```apache
# C:\xampp\apache\conf\extra\httpd-vhosts.conf

# Default localhost
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "C:/xampp/htdocs"
</VirtualHost>

# Project 1: Laravel
<VirtualHost *:80>
    ServerName laravel.local
    DocumentRoot "C:/xampp/htdocs/laravel-app/public"
    <Directory "C:/xampp/htdocs/laravel-app/public">
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog "logs/laravel-error.log"
</VirtualHost>

# Project 2: WordPress
<VirtualHost *:80>
    ServerName wordpress.local
    DocumentRoot "C:/xampp/htdocs/wordpress"
    <Directory "C:/xampp/htdocs/wordpress">
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### Windows Hosts File
```
# C:\Windows\System32\drivers\etc\hosts (edit as Admin)
127.0.0.1   laravel.local
127.0.0.1   wordpress.local
```

## MariaDB/MySQL
```bash
# Default credentials
# User: root
# Password: (empty)

# Access via CLI
C:\xampp\mysql\bin\mysql -u root

# Create database
CREATE DATABASE myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'myapp_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON myapp.* TO 'myapp_user'@'localhost';
FLUSH PRIVILEGES;
```

## Security (Development Only)
```
⚠️ XAMPP is for LOCAL DEVELOPMENT ONLY — NEVER expose to the internet

✅ DO:
- Set MySQL root password via phpMyAdmin
- Use virtual hosts per project
- Keep XAMPP updated

❌ DO NOT:
- Use XAMPP in production
- Leave default MySQL root without password
- Expose phpMyAdmin to network
```

## Common Issues & Fixes
| Issue | Solution |
|-------|---------|
| Port 80 in use | Stop IIS/Skype, or change Apache port in `httpd.conf` |
| Port 3306 in use | Stop existing MySQL service |
| PHP extension missing | Uncomment in `php.ini`, restart Apache |
| `.htaccess` not working | Enable `mod_rewrite` in `httpd.conf` (`LoadModule rewrite_module`) |
| Permission denied (macOS/Linux) | `sudo chmod -R 755 /opt/lampp/htdocs/` |

## Commands
```bash
# Windows (via XAMPP Control Panel or CLI)
C:\xampp\xampp_start.exe          # Start all services
C:\xampp\xampp_stop.exe           # Stop all services
C:\xampp\apache_start.bat         # Start Apache only
C:\xampp\mysql_start.bat          # Start MySQL only

# Linux
sudo /opt/lampp/lampp start       # Start all
sudo /opt/lampp/lampp stop        # Stop all
sudo /opt/lampp/lampp restart     # Restart all
```
