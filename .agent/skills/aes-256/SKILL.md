---
name: AES-256 Encryption
description: Skill for implementing AES-256 encryption and decryption — covering AES-256-GCM, AES-256-CBC, key management, IV/nonce handling, field-level encryption, file encryption, and implementations in Node.js, Python, and PHP/Laravel.
---

# AES-256 Encryption & Decryption Skill

## Overview
**AES-256** (Advanced Encryption Standard with 256-bit key) is the gold standard for symmetric encryption. It is approved by NIST, used by governments and military, and is the recommended encryption algorithm for UU PDP compliance (Data Pribadi Spesifik).

---

## AES Modes Comparison

| Mode | Name | Authentication | IV/Nonce | Recommended |
|------|------|---------------|----------|-------------|
| **GCM** | Galois/Counter Mode | ✅ Built-in (AEAD) | 12 bytes (96-bit) | ✅ **Primary choice** |
| **CBC** | Cipher Block Chaining | ❌ Needs separate HMAC | 16 bytes (128-bit) | ⚠️ Legacy systems only |
| **CTR** | Counter Mode | ❌ Needs separate HMAC | 16 bytes (128-bit) | ⚠️ Streaming data |
| **CCM** | Counter with CBC-MAC | ✅ Built-in (AEAD) | 7-13 bytes | ⚠️ Constrained devices |

> **Always use AES-256-GCM** — it provides both confidentiality AND authentication (detects tampering). CBC is legacy and requires separate HMAC to prevent padding oracle attacks.

---

## Node.js Implementation

### AES-256-GCM (Recommended)

```typescript
import { createCipheriv, createDecipheriv, randomBytes, scryptSync } from 'crypto';

// ✅ Constants
const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12;        // 96-bit nonce for GCM
const AUTH_TAG_LENGTH = 16;  // 128-bit auth tag
const KEY_LENGTH = 32;       // 256-bit key
const SALT_LENGTH = 16;      // 128-bit salt for key derivation

/**
 * Derive encryption key from password using scrypt
 * ✅ REQUIRED: Never use password directly as key
 */
function deriveKey(password: string, salt: Buffer): Buffer {
  return scryptSync(password, salt, KEY_LENGTH, {
    N: 16384,  // CPU/memory cost
    r: 8,      // Block size
    p: 1,      // Parallelization
  });
}

/**
 * Encrypt plaintext with AES-256-GCM
 * Output format: salt(16) + iv(12) + authTag(16) + ciphertext
 */
export function encrypt(plaintext: string, masterKey: string): string {
  const salt = randomBytes(SALT_LENGTH);
  const key = deriveKey(masterKey, salt);
  const iv = randomBytes(IV_LENGTH);

  const cipher = createCipheriv(ALGORITHM, key, iv, { authTagLength: AUTH_TAG_LENGTH });
  const encrypted = Buffer.concat([
    cipher.update(plaintext, 'utf8'),
    cipher.final(),
  ]);
  const authTag = cipher.getAuthTag();

  // Combine: salt + iv + authTag + ciphertext
  const result = Buffer.concat([salt, iv, authTag, encrypted]);
  return result.toString('base64');
}

/**
 * Decrypt ciphertext with AES-256-GCM
 * Throws if tampered (auth tag verification fails)
 */
export function decrypt(encryptedBase64: string, masterKey: string): string {
  const data = Buffer.from(encryptedBase64, 'base64');

  // Extract components
  const salt = data.subarray(0, SALT_LENGTH);
  const iv = data.subarray(SALT_LENGTH, SALT_LENGTH + IV_LENGTH);
  const authTag = data.subarray(SALT_LENGTH + IV_LENGTH, SALT_LENGTH + IV_LENGTH + AUTH_TAG_LENGTH);
  const ciphertext = data.subarray(SALT_LENGTH + IV_LENGTH + AUTH_TAG_LENGTH);

  const key = deriveKey(masterKey, salt);
  const decipher = createDecipheriv(ALGORITHM, key, iv, { authTagLength: AUTH_TAG_LENGTH });
  decipher.setAuthTag(authTag);

  const decrypted = Buffer.concat([
    decipher.update(ciphertext),
    decipher.final(),  // Throws if auth tag invalid (tampered)
  ]);

  return decrypted.toString('utf8');
}

// Usage
const masterKey = process.env.ENCRYPTION_KEY!; // 32+ character secret
const encrypted = encrypt('NIK: 3271234567890123', masterKey);
const decrypted = decrypt(encrypted, masterKey);
console.log(decrypted); // 'NIK: 3271234567890123'
```

### Using Raw 256-bit Key (Without Password Derivation)

```typescript
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

/**
 * For when you already have a proper 256-bit key (e.g., from KMS)
 */
export function encryptWithKey(plaintext: string, key: Buffer): string {
  if (key.length !== 32) throw new Error('Key must be 32 bytes (256 bits)');

  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', key, iv);
  const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
  const authTag = cipher.getAuthTag();

  return Buffer.concat([iv, authTag, encrypted]).toString('base64');
}

export function decryptWithKey(encryptedBase64: string, key: Buffer): string {
  const data = Buffer.from(encryptedBase64, 'base64');
  const iv = data.subarray(0, 12);
  const authTag = data.subarray(12, 28);
  const ciphertext = data.subarray(28);

  const decipher = createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(authTag);
  return Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString('utf8');
}

// Generate a proper 256-bit key
const key = randomBytes(32);
console.log('Key (hex):', key.toString('hex'));     // Store securely in KMS
console.log('Key (base64):', key.toString('base64'));
```

---

## Python Implementation

### AES-256-GCM

```python
import os
import base64
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt

def derive_key(password: str, salt: bytes) -> bytes:
    """Derive 256-bit key from password using scrypt"""
    kdf = Scrypt(salt=salt, length=32, n=16384, r=8, p=1)
    return kdf.derive(password.encode())

def encrypt(plaintext: str, master_key: str) -> str:
    """Encrypt with AES-256-GCM. Returns base64 string."""
    salt = os.urandom(16)
    key = derive_key(master_key, salt)
    nonce = os.urandom(12)  # 96-bit nonce for GCM
    
    aesgcm = AESGCM(key)
    ciphertext = aesgcm.encrypt(nonce, plaintext.encode(), None)
    # ciphertext includes auth tag (last 16 bytes)
    
    # Combine: salt + nonce + ciphertext (with auth tag)
    result = salt + nonce + ciphertext
    return base64.b64encode(result).decode()

def decrypt(encrypted_b64: str, master_key: str) -> str:
    """Decrypt AES-256-GCM. Raises InvalidTag if tampered."""
    data = base64.b64decode(encrypted_b64)
    
    salt = data[:16]
    nonce = data[16:28]
    ciphertext = data[28:]  # Includes auth tag
    
    key = derive_key(master_key, salt)
    aesgcm = AESGCM(key)
    plaintext = aesgcm.decrypt(nonce, ciphertext, None)
    
    return plaintext.decode()

# Usage
master_key = os.environ['ENCRYPTION_KEY']
encrypted = encrypt('NIK: 3271234567890123', master_key)
decrypted = decrypt(encrypted, master_key)
```

### AES-256-CBC (Legacy Compatibility)

```python
import os
import base64
import hmac
import hashlib
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.padding import PKCS7

def encrypt_cbc(plaintext: str, key: bytes) -> str:
    """AES-256-CBC with HMAC-SHA256 for authentication"""
    iv = os.urandom(16)
    
    # Pad plaintext to block size
    padder = PKCS7(128).padder()
    padded = padder.update(plaintext.encode()) + padder.finalize()
    
    # Encrypt
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(padded) + encryptor.finalize()
    
    # HMAC for authentication (Encrypt-then-MAC)
    mac = hmac.new(key, iv + ciphertext, hashlib.sha256).digest()
    
    result = iv + mac + ciphertext
    return base64.b64encode(result).decode()

def decrypt_cbc(encrypted_b64: str, key: bytes) -> str:
    """AES-256-CBC with HMAC verification"""
    data = base64.b64decode(encrypted_b64)
    iv = data[:16]
    mac = data[16:48]
    ciphertext = data[48:]
    
    # Verify HMAC first (constant-time comparison)
    expected_mac = hmac.new(key, iv + ciphertext, hashlib.sha256).digest()
    if not hmac.compare_digest(mac, expected_mac):
        raise ValueError("Ciphertext tampered — HMAC verification failed")
    
    # Decrypt
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    padded = decryptor.update(ciphertext) + decryptor.finalize()
    
    # Unpad
    unpadder = PKCS7(128).unpadder()
    plaintext = unpadder.update(padded) + unpadder.finalize()
    
    return plaintext.decode()
```

---

## PHP / Laravel Implementation

```php
// ✅ Laravel uses AES-256-CBC by default (via APP_KEY)

// Using Laravel's built-in encryption (AES-256-CBC)
use Illuminate\Support\Facades\Crypt;

$encrypted = Crypt::encryptString('NIK: 3271234567890123');
$decrypted = Crypt::decryptString($encrypted);

// Custom AES-256-GCM in PHP
function encryptGcm(string $plaintext, string $key): string {
    $iv = random_bytes(12); // 96-bit nonce
    $ciphertext = openssl_encrypt(
        $plaintext, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag, '', 16
    );
    return base64_encode($iv . $tag . $ciphertext);
}

function decryptGcm(string $encryptedBase64, string $key): string {
    $data = base64_decode($encryptedBase64);
    $iv = substr($data, 0, 12);
    $tag = substr($data, 12, 16);
    $ciphertext = substr($data, 28);
    
    $plaintext = openssl_decrypt(
        $ciphertext, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag
    );
    
    if ($plaintext === false) {
        throw new \RuntimeException('Decryption failed — data may be tampered');
    }
    return $plaintext;
}
```

---

## Field-Level Encryption (Database)

```typescript
// ✅ Encrypt specific PII fields before storing in database
// Required for UU PDP: Data Pribadi Spesifik

interface UserRecord {
  id: string;
  name: string;                // Not encrypted (general data)
  email_encrypted: string;     // 🔐 Encrypted
  nik_encrypted: string;       // 🔐 Encrypted (Data Spesifik)
  phone_encrypted: string;     // 🔐 Encrypted
  search_hash: string;         // 🔍 HMAC hash for searchability
}

class FieldEncryption {
  private key: string;

  constructor() {
    this.key = process.env.FIELD_ENCRYPTION_KEY!;
  }

  encryptField(value: string): string {
    return encrypt(value, this.key);
  }

  decryptField(encrypted: string): string {
    return decrypt(encrypted, this.key);
  }

  // Searchable hash (can search without decrypting all records)
  searchHash(value: string): string {
    return createHmac('sha256', this.key)
      .update(value.toLowerCase().trim())
      .digest('hex');
  }
}

// Usage
const fe = new FieldEncryption();
const user = {
  id: 'usr-123',
  name: 'John Doe',
  email_encrypted: fe.encryptField('john@example.com'),
  nik_encrypted: fe.encryptField('3271234567890123'),
  phone_encrypted: fe.encryptField('+6281234567890'),
  search_hash: fe.searchHash('john@example.com'), // For WHERE clause
};

// Search by email without decrypting every row
const hash = fe.searchHash('john@example.com');
const found = await db.query('SELECT * FROM users WHERE search_hash = $1', [hash]);
```

---

## File Encryption

```typescript
import { createReadStream, createWriteStream } from 'fs';
import { pipeline } from 'stream/promises';
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

async function encryptFile(inputPath: string, outputPath: string, key: Buffer): Promise<void> {
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', key, iv);

  const output = createWriteStream(outputPath);
  output.write(iv); // Prepend IV

  await pipeline(createReadStream(inputPath), cipher, output);

  // Append auth tag
  const authTag = cipher.getAuthTag();
  const finalOutput = createWriteStream(outputPath, { flags: 'a' });
  finalOutput.write(authTag);
  finalOutput.end();
}
```

---

## Key Management

```
✅ DO:
  - Store keys in KMS (AWS KMS, Google Cloud KMS, Azure Key Vault)
  - Use envelope encryption (encrypt data key with master key)
  - Rotate keys periodically (every 90 days)
  - Use separate keys per purpose (field encryption vs file encryption)
  - Derive keys from password with scrypt/Argon2 (never raw password)

❌ DON'T:
  - Hardcode keys in source code
  - Store keys in .env files in production (use KMS)
  - Reuse IV/nonce (CATASTROPHIC for GCM — breaks all security)
  - Use MD5/SHA256 to derive keys (use scrypt/PBKDF2/Argon2)
  - Log encryption keys or plaintext PII
```

### Envelope Encryption Pattern
```
Master Key (in KMS, never leaves KMS)
  └── Encrypts → Data Encryption Key (DEK)
                    └── Encrypts → Actual data

Storage:
  - Encrypted DEK stored alongside data
  - To decrypt: KMS decrypts DEK → DEK decrypts data
  - To rotate: Re-encrypt DEK with new master key (data unchanged)
```

## Environment Variables
```bash
# Key derivation from password
ENCRYPTION_KEY=your-very-long-master-password-minimum-32-characters

# Or direct 256-bit key (base64)
ENCRYPTION_KEY_B64=A1B2C3D4E5F6... (32 bytes = 44 base64 chars)

# Field-level encryption
FIELD_ENCRYPTION_KEY=separate-key-for-database-field-encryption
```

## Best Practices
1. **AES-256-GCM over CBC** — GCM provides authentication, CBC doesn't
2. **Never reuse IV/nonce** — always `randomBytes()` for each encryption
3. **Derive keys properly** — scrypt, Argon2, or PBKDF2 (never raw)
4. **Envelope encryption** — for key rotation without re-encrypting data
5. **Encrypt PII at field level** — per UU PDP for Data Pribadi Spesifik
6. **Key rotation every 90 days** — automated via KMS
7. **Constant-time comparison** — use `crypto.timingSafeEqual` or `hmac.compare_digest`
