---
name: ionCube
description: Skill for PHP source code protection with ionCube — covering ionCube Encoder (encoding/obfuscation), ionCube Loader (runtime decoding), licensing, server setup, deployment, and troubleshooting.
---

# ionCube Skill

## Overview
**ionCube** is a PHP source code protection tool consisting of two parts:
- **ionCube Encoder** — compiles/encodes PHP source files into bytecode that cannot be reverse-engineered
- **ionCube Loader** — a PHP extension that decodes and executes ionCube-encoded files at runtime

It is widely used to protect commercial PHP applications, plugins, themes, and SaaS products from unauthorized copying, modification, or redistribution.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    IONCUBE WORKFLOW                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  DEVELOPMENT                    PRODUCTION                   │
│  ┌──────────────┐              ┌──────────────┐              │
│  │ PHP Source    │  Encoder    │ Encoded .php  │              │
│  │ (readable)   │ ─────────→  │ (protected)   │              │
│  │              │              │              │              │
│  │ <?php        │              │ <?php //003.. │              │
│  │ class App {  │              │ (bytecode)    │              │
│  │   ...        │              │              │              │
│  │ }            │              │              │              │
│  └──────────────┘              └──────┬───────┘              │
│                                       │                      │
│                                       ▼                      │
│                              ┌──────────────┐                │
│                              │ ionCube      │                │
│                              │ Loader (ext) │                │
│                              │ Decodes &    │                │
│                              │ Executes     │                │
│                              └──────────────┘                │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## ionCube Loader Installation

### Check Current PHP Version
```bash
php -v
php -m | grep ionCube
```

### Linux (CLI + Apache/Nginx)
```bash
# 1. Download Loader
cd /tmp
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xzf ioncube_loaders_lin_x86-64.tar.gz

# 2. Find PHP extension directory
php -i | grep extension_dir
# Example: /usr/lib/php/20230831

# 3. Copy matching loader
cp ioncube/ioncube_loader_lin_8.3.so /usr/lib/php/20230831/

# 4. Add to php.ini (MUST be first extension loaded)
# Find php.ini location:
php --ini

# Add to the TOP of php.ini (before all other extensions):
echo "zend_extension = ioncube_loader_lin_8.3.so" > /etc/php/8.3/mods-available/ioncube.ini

# 5. Enable module
sudo phpenmod -v 8.3 ioncube

# 6. Restart PHP
sudo systemctl restart php8.3-fpm
# or for Apache:
sudo systemctl restart apache2
```

### Docker
```dockerfile
FROM php:8.3-fpm

# Install ionCube Loader
ADD https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz /tmp/
RUN tar xzf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /tmp/ \
    && EXTENSION_DIR=$(php -r "echo ini_get('extension_dir');") \
    && cp /tmp/ioncube/ioncube_loader_lin_8.3.so ${EXTENSION_DIR}/ \
    && echo "zend_extension=ioncube_loader_lin_8.3.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf /tmp/ioncube*

# Verify
RUN php -m | grep ionCube
```

### Docker Compose
```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ./encoded-app:/var/www/html
    environment:
      - PHP_MEMORY_LIMIT=256M

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./encoded-app:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
```

### Windows (XAMPP / WAMP)
```
1. Download Windows loaders from ioncube.com
2. Copy ioncube_loader_win_8.3.dll to C:\xampp\php\ext\
3. Add to php.ini (FIRST zend_extension line):
   zend_extension = "C:\xampp\php\ext\ioncube_loader_win_8.3.dll"
4. Restart Apache
```

### cPanel / Plesk
```
cPanel:
  WHM → Software → PHP Extensions → Select ionCube Loader → Install
  or: MultiPHP INI Editor → Add zend_extension line

Plesk:
  Tools & Settings → PHP Settings → Select PHP version → ionCube Loader checkbox
```

### Verify Installation
```php
<?php
// ioncube_check.php — Upload to server and visit in browser

if (extension_loaded('ionCube Loader')) {
    echo "✅ ionCube Loader is installed\n";
    echo "Version: " . ioncube_loader_version() . "\n";
    echo "Loader Path: " . php_ini_loaded_file() . "\n";
    
    // Check loader info
    if (function_exists('ioncube_loader_iversion')) {
        $version = ioncube_loader_iversion();
        echo "Internal version: " . sprintf('%d.%d.%d', $version / 10000, ($version / 100) % 100, $version % 100) . "\n";
    }
} else {
    echo "❌ ionCube Loader is NOT installed\n";
    echo "PHP Version: " . PHP_VERSION . "\n";
    echo "Extension Dir: " . PHP_EXTENSION_DIR . "\n";
    echo "Loaded php.ini: " . php_ini_loaded_file() . "\n";
}
```

---

## ionCube Encoder

### Project File (encoder.project)
```ini
; ionCube Encoder Project File

--input /path/to/source/
--output /path/to/encoded/

; PHP version target
--php 83

; Encoding options
--optimize max
--no-short-tags

; Files to encode
--encode "*.php"

; Files to COPY without encoding (assets, configs, etc.)
--copy "*.html"
--copy "*.css"
--copy "*.js"
--copy "*.json"
--copy "*.xml"
--copy "*.yml"
--copy "*.yaml"
--copy "*.env.example"
--copy "*.md"
--copy "*.txt"
--copy "*.png"
--copy "*.jpg"
--copy "*.gif"
--copy "*.svg"
--copy "*.woff2"

; Exclude directories
--ignore ".git"
--ignore "node_modules"
--ignore "tests"
--ignore "vendor"    ; Re-install via composer on target
--ignore ".env"
--ignore "storage/logs"

; Obfuscation
--obfuscate all
--obfuscation-key "your-secret-obfuscation-key"

; Expiry (optional — for trial/demo versions)
; --expire-in 30d
; --expire-on 2026-12-31

; License enforcement (optional)
; --with-license license.key
; --passphrase "your-license-passphrase"

; Callback URL for license validation (optional)
; --callback-url "https://api.example.com/license/validate"

; Header message in encoded files
--message "Protected by ionCube Encoder. (c) 2026 Your Company."
```

### Encode via CLI
```bash
# Encode single file
ioncube_encoder83 --input source.php --output encoded.php

# Encode entire project
ioncube_encoder83 --project-file encoder.project

# Encode with license
ioncube_encoder83 --input /src/ --output /dist/ \
  --php 83 \
  --optimize max \
  --obfuscate all \
  --with-license license.key \
  --passphrase "secret" \
  --encode "*.php" \
  --copy "*.html" --copy "*.css" --copy "*.js" \
  --ignore ".git" --ignore "node_modules"
```

---

## Licensing System

### Generate License Key
```bash
# Create a license file tied to specific server/domain
ioncube_encoder83 --make-license \
  --passphrase "your-license-passphrase" \
  --property "domain=example.com" \
  --property "customer=PT Example Indonesia" \
  --property "max_users=50" \
  --expire-on 2027-01-01 \
  --output license.key

# Server-locked license (MAC address)
ioncube_encoder83 --make-license \
  --passphrase "your-license-passphrase" \
  --server-id "00:1A:2B:3C:4D:5E" \
  --output license.key

# IP-locked license
ioncube_encoder83 --make-license \
  --passphrase "your-license-passphrase" \
  --allowed-server "103.20.150.100" \
  --output license.key
```

### Read License Properties in PHP
```php
<?php
// Reading license properties in encoded application

function validateLicense(): array {
    // Check if running as encoded file
    if (!function_exists('ioncube_license_properties')) {
        return ['valid' => false, 'error' => 'Not running as ionCube encoded file'];
    }
    
    $properties = ioncube_license_properties();
    
    if ($properties === false) {
        return ['valid' => false, 'error' => 'License file not found or invalid'];
    }
    
    // Validate domain
    $licensedDomain = $properties['domain']['value'] ?? '';
    $currentDomain = $_SERVER['SERVER_NAME'] ?? php_uname('n');
    
    if ($licensedDomain && $licensedDomain !== $currentDomain) {
        return [
            'valid' => false,
            'error' => "License not valid for domain: {$currentDomain}",
        ];
    }
    
    // Check expiry
    if (function_exists('ioncube_license_has_expired') && ioncube_license_has_expired()) {
        return ['valid' => false, 'error' => 'License has expired'];
    }
    
    return [
        'valid' => true,
        'domain' => $licensedDomain,
        'customer' => $properties['customer']['value'] ?? 'Unknown',
        'max_users' => (int) ($properties['max_users']['value'] ?? 0),
    ];
}

// Usage in application bootstrap
$license = validateLicense();
if (!$license['valid']) {
    http_response_code(403);
    die("License Error: " . $license['error']);
}
```

---

## Laravel Project Encoding

```bash
# Laravel-specific encoding strategy

# 1. Encode only app/ directory (business logic)
ioncube_encoder83 \
  --input /project/app/ \
  --output /dist/app/ \
  --php 83 --optimize max --obfuscate all \
  --encode "*.php"

# 2. Copy everything else as-is
cp -r /project/config /dist/config
cp -r /project/database /dist/database
cp -r /project/public /dist/public
cp -r /project/resources /dist/resources
cp -r /project/routes /dist/routes
cp -r /project/bootstrap /dist/bootstrap
cp /project/artisan /dist/artisan
cp /project/composer.json /dist/composer.json
cp /project/composer.lock /dist/composer.lock

# 3. Install vendor on target (not from source)
cd /dist && composer install --no-dev --optimize-autoloader

# 4. Deploy /dist/ to production
```

### Laravel Encoder Project File
```ini
; laravel-encoder.project

--input /path/to/laravel/
--output /path/to/encoded-laravel/
--php 83
--optimize max
--obfuscate all

; Encode PHP business logic
--encode "app/*.php"
--encode "app/**/*.php"

; Do NOT encode these (framework needs them readable)
--copy "config/*.php"
--copy "routes/*.php"
--copy "database/**/*.php"
--copy "bootstrap/*.php"
--copy "artisan"
--copy "public/index.php"
--copy "resources/**/*"
--copy "composer.json"
--copy "composer.lock"
--copy ".env.example"

; Ignore
--ignore "vendor"
--ignore "node_modules"
--ignore ".git"
--ignore "tests"
--ignore "storage"
--ignore ".env"
```

---

## Troubleshooting

### Common Errors

```
Error: "The file X requires the ionCube PHP Loader"
Fix: Install ionCube Loader matching your PHP version

Error: "The file was encoded with a newer ionCube Encoder"
Fix: Update ionCube Loader to latest version

Error: "License has expired"
Fix: Generate new license key with updated expiry

Error: "Cannot use encoded file — server_id mismatch"
Fix: Generate license for correct server MAC/IP

Error: "ionCube Loader must be loaded as a Zend extension"
Fix: Use zend_extension (not extension) in php.ini
     Must be FIRST zend_extension line (before OPcache, Xdebug)
```

### php.ini Load Order
```ini
; ✅ CORRECT ORDER — ionCube MUST be first
zend_extension=ioncube_loader_lin_8.3.so    ; First!
zend_extension=opcache.so                    ; Second
; zend_extension=xdebug.so                  ; Development only

; ❌ WRONG — ionCube after other zend_extensions will fail
; zend_extension=opcache.so
; zend_extension=ioncube_loader_lin_8.3.so   ; Too late!
```

### Check Compatibility
```bash
# Check PHP version matches loader version
php -v
# PHP 8.3.x → use ioncube_loader_lin_8.3.so

# Check architecture (x86_64 vs ARM)
uname -m
# x86_64 → ioncube_loaders_lin_x86-64
# aarch64 → ioncube_loaders_lin_aarch64

# Check thread safety
php -i | grep "Thread Safety"
# If "enabled" → use _ts variant (e.g., ioncube_loader_lin_8.3_ts.so)
# If "disabled" → use standard (e.g., ioncube_loader_lin_8.3.so)
```

---

## CI/CD Integration

```yaml
# GitHub Actions — Encode and deploy
name: Encode & Deploy
on:
  push:
    branches: [main]

jobs:
  encode:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup ionCube Encoder
        run: |
          wget -q https://downloads.ioncube.com/encoder_downloads/ioncube_encoder_evaluation.tar.gz
          tar xzf ioncube_encoder_evaluation.tar.gz
          export PATH=$PWD/ioncube_encoder:$PATH
      
      - name: Encode Application
        run: |
          ioncube_encoder83 --project-file encoder.project
      
      - name: Deploy Encoded Files
        run: |
          rsync -avz /dist/ user@server:/var/www/html/
```

---

## PHP Version Compatibility

| PHP Version | Loader File | Encoder Flag | Status |
|-------------|------------|-------------|--------|
| PHP 8.4 | `ioncube_loader_lin_8.4.so` | `--php 84` | ✅ Supported |
| PHP 8.3 | `ioncube_loader_lin_8.3.so` | `--php 83` | ✅ Supported |
| PHP 8.2 | `ioncube_loader_lin_8.2.so` | `--php 82` | ✅ Supported |
| PHP 8.1 | `ioncube_loader_lin_8.1.so` | `--php 81` | ✅ Supported |
| PHP 8.0 | `ioncube_loader_lin_8.0.so` | `--php 80` | ⚠️ EOL |
| PHP 7.4 | `ioncube_loader_lin_7.4.so` | `--php 74` | ❌ EOL |

## Best Practices
1. **Loader first** — `zend_extension=ioncube_loader` MUST be first in php.ini
2. **Match PHP version** — loader version must match server's PHP exactly
3. **Encode only business logic** — don't encode config, routes, views, migrations
4. **Vendor via Composer** — don't encode vendor/; install on target with `composer install --no-dev`
5. **Test encoded output** — always test encoded files on a staging server before deploying
6. **License per customer** — use domain/IP/MAC locks for commercial distribution
7. **Keep source backup** — encoded files cannot be decoded; always keep originals safe
8. **OPcache compatibility** — ionCube works with OPcache, but loader must load first
9. **Thread safety check** — use `_ts` variant for thread-safe PHP (e.g., Apache worker MPM)
