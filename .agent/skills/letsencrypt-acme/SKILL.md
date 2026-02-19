---
name: Let's Encrypt ACME
description: Skill for Let's Encrypt and ACME protocol — automated SSL/TLS certificate issuance and renewal using certbot and ACME API.
---

# Let's Encrypt — ACME SSL/TLS Certificates

## Overview
Let's Encrypt is a free, automated Certificate Authority using the ACME (Automatic Certificate Management Environment) protocol for automated SSL/TLS certificate management.

## Certbot CLI
```bash
# Obtain certificate (standalone)
certbot certonly --standalone -d example.com -d www.example.com

# Obtain certificate (webroot)
certbot certonly --webroot -w /var/www/html -d example.com

# Obtain wildcard certificate (DNS challenge)
certbot certonly --manual --preferred-challenges dns -d '*.example.com'

# Renew all certificates
certbot renew

# Auto-renewal via cron
0 0 1 * * certbot renew --post-hook "systemctl reload nginx"
```

## ACME API (programmatic)
```python
from acme import client, challenges, messages
from cryptography.hazmat.primitives.asymmetric import rsa

# Create ACME client
directory_url = "https://acme-v02.api.letsencrypt.org/directory"
# ... standard ACME flow: account creation, order, authorization, challenge, finalize
```

## Best Practices
- Use **DNS-01 challenge** for wildcard certificates
- Configure **automatic renewal** with cron or systemd timers
- Use **certbot** or **acme.sh** for simplified management
- Monitor certificate **expiration dates** proactively
