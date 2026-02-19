---
name: Thales CipherTrust
description: Skill for Thales CipherTrust Manager — centralized key management, encryption, tokenization, and data security platform API.
---

# Thales CipherTrust — Key Management & Encryption

## Overview
Thales CipherTrust Manager provides centralized key lifecycle management, transparent encryption, application-level encryption, tokenization, and cloud key management (BYOK/HYOK).

## REST API
```python
import requests

# Authenticate
auth = requests.post("https://ciphertrust/api/v1/auth/tokens",
    json={"name": "admin", "password": "pass"})
token = auth.json()["jwt"]
headers = {"Authorization": f"Bearer {token}"}

# Create encryption key
key = requests.post("https://ciphertrust/api/v1/vault/keys2",
    headers=headers,
    json={"name": "my-aes-key", "algorithm": "AES", "size": 256, "usageMask": 12})

# Encrypt data
encrypted = requests.post("https://ciphertrust/api/v1/crypto/encrypt",
    headers=headers,
    json={"keyName": "my-aes-key", "plaintext": "base64-encoded-data"})

# Decrypt data
decrypted = requests.post("https://ciphertrust/api/v1/crypto/decrypt",
    headers=headers,
    json={"keyName": "my-aes-key", "ciphertext": encrypted.json()["ciphertext"]})
```

## Best Practices
- Implement **key rotation** policies
- Use **BYOK** for cloud encryption key ownership
- Enable **audit logging** for all key operations
