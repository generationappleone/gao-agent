---
name: HashiCorp Vault
description: Skill for HashiCorp Vault — secrets management engine with dynamic secrets, encryption as a service, PKI, and API integration.
---

# HashiCorp Vault — Secrets Management

## Overview
HashiCorp Vault is a secrets management platform providing secure storage, dynamic secrets generation, encryption as a service, PKI, and fine-grained access control.

## API
```bash
# Authenticate
export VAULT_TOKEN=$(vault login -method=userpass username=admin password=pass -format=json | jq -r '.auth.client_token')

# Store a secret
vault kv put secret/myapp/db username=admin password=supersecret

# Read a secret
vault kv get -format=json secret/myapp/db

# Dynamic database credentials
vault read database/creds/my-role

# Generate PKI certificate
vault write pki/issue/my-role common_name="app.example.com" ttl="720h"
```

### REST API
```python
import hvac

client = hvac.Client(url='https://vault.example.com:8200', token='YOUR_TOKEN')

# Write secret
client.secrets.kv.v2.create_or_update_secret(path='myapp/config', secret={'db_pass': 'secret123'})

# Read secret
secret = client.secrets.kv.v2.read_secret_version(path='myapp/config')
print(secret['data']['data']['db_pass'])

# Enable transit engine (encryption as a service)
client.sys.enable_secrets_engine(backend_type='transit', path='transit')
client.secrets.transit.create_key(name='my-key')
ciphertext = client.secrets.transit.encrypt_data(name='my-key', plaintext='base64data')
```

## Best Practices
- Use **dynamic secrets** to eliminate static credentials
- Enable **audit logging** for all secret access
- Implement **lease-based TTLs** for automatic credential rotation
- Use **AppRole** or **Kubernetes auth** for application authentication
