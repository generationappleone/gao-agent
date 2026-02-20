---
name: Apache HTTP Server
description: Skill for configuring and managing Apache HTTP Server, covering virtual hosts, SSL/TLS, mod_rewrite, security hardening, reverse proxy, and performance tuning.
---

# Apache HTTP Server Skill

## Overview
Apache HTTP Server (httpd) is one of the most widely used web servers. It provides virtual hosting, SSL/TLS, URL rewriting (mod_rewrite), reverse proxy (mod_proxy), access control, and module-based architecture. Apache is commonly used with PHP/Laravel applications.

**References**:
- [Apache HTTP Server Documentation](https://httpd.apache.org/docs/2.4/)
- [mod_rewrite Guide](https://httpd.apache.org/docs/2.4/mod/mod_rewrite.html)

---

## Virtual Host Configuration

```apache
# /etc/apache2/sites-available/myapp.conf
<VirtualHost *:80>
    ServerName myapp.com
    ServerAlias www.myapp.com
    DocumentRoot /var/www/myapp/public

    # Redirect to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

<VirtualHost *:443>
    ServerName myapp.com
    ServerAlias www.myapp.com
    DocumentRoot /var/www/myapp/public

    # SSL
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/myapp.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/myapp.com/privkey.pem
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5

    # Document root
    <Directory /var/www/myapp/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Security headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"

    # Gzip compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/css
        AddOutputFilterByType DEFLATE application/javascript application/json
        AddOutputFilterByType DEFLATE image/svg+xml
    </IfModule>

    # Static file caching
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType image/jpeg "access plus 1 year"
        ExpiresByType image/png "access plus 1 year"
        ExpiresByType image/svg+xml "access plus 1 year"
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType application/javascript "access plus 1 month"
        ExpiresByType font/woff2 "access plus 1 year"
    </IfModule>

    # Logging
    ErrorLog ${APACHE_LOG_DIR}/myapp_error.log
    CustomLog ${APACHE_LOG_DIR}/myapp_access.log combined
</VirtualHost>
```

---

## Laravel .htaccess

```apache
# /var/www/myapp/public/.htaccess
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect trailing slashes
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Handle front controller
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>

# Block sensitive files
<FilesMatch "^\.">
    Require all denied
</FilesMatch>
<FilesMatch "\.(env|log|sql|bak)$">
    Require all denied
</FilesMatch>
```

---

## Reverse Proxy

```apache
# Proxy to Node.js/Express app
<VirtualHost *:443>
    ServerName api.myapp.com

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/api.myapp.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/api.myapp.com/privkey.pem

    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/

    # WebSocket proxy
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://localhost:3000/$1" [P,L]

    # Rate limiting
    <IfModule mod_ratelimit.c>
        <Location /api/>
            SetOutputFilter RATE_LIMIT
            SetEnv rate-limit 1024
        </Location>
    </IfModule>
</VirtualHost>
```

---

## Commands

```bash
# Enable modules
sudo a2enmod rewrite ssl proxy proxy_http deflate expires headers

# Enable/disable site
sudo a2ensite myapp.conf
sudo a2dissite 000-default.conf

# Test configuration
sudo apache2ctl configtest

# Restart
sudo systemctl restart apache2
sudo systemctl reload apache2

# Check status
sudo systemctl status apache2
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **SSL/TLS** | TLS 1.2+ only, HSTS header, strong ciphers |
| **Security headers** | X-Frame-Options, CSP, X-Content-Type-Options |
| **AllowOverride** | Use `All` for .htaccess or `None` for performance |
| **mod_rewrite** | Front controller pattern for frameworks |
| **Gzip** | Compress text, CSS, JS, JSON, SVG |
| **Caching** | Expire static assets (1 year for immutable) |
| **Block sensitive** | Deny access to .env, .git, .log files |
| **Logging** | Separate error/access logs per virtual host |
| **Reverse proxy** | ProxyPass for backend API servers |
| **WebSocket** | Use mod_proxy_wstunnel for WS connections |

---

## Rules Integration
- **Virtual host**: SSL, security headers, gzip, caching
- **Rewrite**: Front controller, HTTPS redirect, trailing slash
- **Proxy**: Reverse proxy to Node.js/Express, WebSocket
- **Security**: Block sensitive files, deny directory listing
- **Performance**: mod_deflate, mod_expires, connection pooling
