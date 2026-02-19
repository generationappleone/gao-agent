---
name: Apache HTTP Server
description: Skill for configuring and managing Apache HTTP Server, covering virtual hosts, SSL/TLS, mod_rewrite, security hardening, reverse proxy, and performance tuning.
---

# Apache HTTP Server Skill

## Overview
Apache HTTP Server (httpd) is the world's most widely used web server. This skill covers virtual host configuration, SSL, URL rewriting, security hardening, and reverse proxy setup.

## Installation
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install apache2 -y
sudo systemctl enable apache2 && sudo systemctl start apache2

# CentOS/RHEL
sudo dnf install httpd -y
sudo systemctl enable httpd && sudo systemctl start httpd

# macOS (Homebrew)
brew install httpd
```

## Directory Structure
```
/etc/apache2/                    # Debian/Ubuntu
├── apache2.conf                 # Main configuration
├── ports.conf                   # Listen directives
├── sites-available/             # Virtual host configs
│   ├── 000-default.conf
│   └── myapp.conf
├── sites-enabled/               # Symlinks to active sites
├── mods-available/              # Available modules
├── mods-enabled/                # Active modules
└── conf-available/              # Additional configs

/etc/httpd/                      # CentOS/RHEL
├── conf/httpd.conf
├── conf.d/                      # Virtual hosts
└── conf.modules.d/              # Module configs
```

## Virtual Host Configuration

### HTTP (Port 80)
```apache
# /etc/apache2/sites-available/myapp.conf
<VirtualHost *:80>
    ServerName myapp.com
    ServerAlias www.myapp.com
    DocumentRoot /var/www/myapp/public

    # Redirect all HTTP to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    ErrorLog ${APACHE_LOG_DIR}/myapp-error.log
    CustomLog ${APACHE_LOG_DIR}/myapp-access.log combined
</VirtualHost>
```

### HTTPS (Port 443) with SSL
```apache
<VirtualHost *:443>
    ServerName myapp.com
    ServerAlias www.myapp.com
    DocumentRoot /var/www/myapp/public

    # SSL Configuration
    SSLEngine on
    SSLCertificateFile      /etc/letsencrypt/live/myapp.com/fullchain.pem
    SSLCertificateKeyFile   /etc/letsencrypt/live/myapp.com/privkey.pem

    # Modern TLS settings
    SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384
    SSLHonorCipherOrder     off
    SSLSessionTickets       off

    # HSTS
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

    # Directory permissions
    <Directory /var/www/myapp/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Security headers
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "DENY"
    Header always set X-XSS-Protection "0"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "camera=(), microphone=(), geolocation=()"
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"

    ErrorLog ${APACHE_LOG_DIR}/myapp-ssl-error.log
    CustomLog ${APACHE_LOG_DIR}/myapp-ssl-access.log combined
</VirtualHost>
```

### Reverse Proxy (Node.js / API Backend)
```apache
<VirtualHost *:443>
    ServerName api.myapp.com

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/api.myapp.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/api.myapp.com/privkey.pem

    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:3000/
    ProxyPassReverse / http://127.0.0.1:3000/

    # WebSocket support
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) ws://127.0.0.1:3000/$1 [P,L]

    # Timeout settings
    ProxyTimeout 300
    ProxyBadHeader Ignore
</VirtualHost>
```

## .htaccess (mod_rewrite)
```apache
# Laravel / PHP Framework
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Remove trailing slash
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)/$ /$1 [L,R=301]

# Cache static assets
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType image/avif "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# Gzip compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/css application/javascript application/json image/svg+xml
</IfModule>

# Block sensitive files
<FilesMatch "\.(env|git|htpasswd|log|sql|bak)$">
    Require all denied
</FilesMatch>
```

## Essential Modules
```bash
# Enable modules
sudo a2enmod rewrite ssl headers proxy proxy_http proxy_wstunnel deflate expires

# Enable site
sudo a2ensite myapp.conf
sudo apache2ctl configtest  # Test before restart
sudo systemctl reload apache2
```

## Security Hardening
```apache
# Hide Apache version
ServerTokens Prod
ServerSignature Off

# Disable directory listings
Options -Indexes

# Limit request size (10MB)
LimitRequestBody 10485760

# Timeout settings
Timeout 60
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
```

## Commands
```bash
sudo apache2ctl configtest    # Test config
sudo systemctl reload apache2 # Reload config
sudo systemctl restart apache2 # Full restart
sudo a2ensite myapp.conf      # Enable site
sudo a2dissite myapp.conf     # Disable site
sudo a2enmod rewrite          # Enable module
tail -f /var/log/apache2/error.log  # Watch errors
```

## Rules Integration
- **Security**: TLS 1.2+, security headers, .htaccess file blocking, ServerTokens Prod
- **ISO 27001**: Access logging, SSL enforcement, directory listing disabled
- **SEO**: HTTPS redirect, trailing slash normalization, cache headers
