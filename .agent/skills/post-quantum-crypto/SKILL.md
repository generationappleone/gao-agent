---
name: Post-Quantum Cryptography
description: Skill for implementing post-quantum encryption algorithms — covering NIST PQC standards (ML-KEM/Kyber, ML-DSA/Dilithium, SLH-DSA/SPHINCS+), hybrid encryption, migration strategies, and quantum-safe TLS.
---

# Post-Quantum Cryptography (PQC) Skill

## Overview
**Post-quantum cryptography (PQC)** provides encryption algorithms resistant to attacks by quantum computers. In 2024, NIST finalized the first PQC standards. Current RSA and ECC encryption will be broken by sufficiently powerful quantum computers (estimated 2030-2040), making migration to PQC essential.

---

## Why Post-Quantum?

```
┌──────────────────────────────────────────────────────────────┐
│              QUANTUM THREAT TIMELINE                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Current algorithms vulnerable to quantum attacks:           │
│  ❌ RSA (2048, 4096)     → Broken by Shor's algorithm       │
│  ❌ ECDSA / ECDH         → Broken by Shor's algorithm       │
│  ❌ Diffie-Hellman       → Broken by Shor's algorithm       │
│                                                              │
│  Current algorithms SAFE from quantum attacks:               │
│  ✅ AES-256              → Grover's reduces to AES-128      │
│                             (still secure with 256-bit key)  │
│  ✅ SHA-256, SHA-3       → Grover's reduces security by     │
│                             half (still sufficient)          │
│                                                              │
│  "Harvest Now, Decrypt Later" attack:                        │
│  ⚠️ Adversaries collect encrypted data TODAY               │
│  ⚠️ Decrypt when quantum computers are available            │
│  ⚠️ Sensitive data with long lifetimes is at risk NOW       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## NIST PQC Standards (Finalized 2024)

| Standard | Algorithm | Type | Use Case | Based On |
|----------|-----------|------|----------|----------|
| **FIPS 203** ML-KEM | Kyber | Key Encapsulation (KEM) | Key exchange, TLS handshake | Lattice (MLWE) |
| **FIPS 204** ML-DSA | Dilithium | Digital Signature | Code signing, certificates, JWT | Lattice (MLWE) |
| **FIPS 205** SLH-DSA | SPHINCS+ | Digital Signature | Stateless signatures (backup) | Hash-based |
| **FIPS 206** FN-DSA | FALCON | Digital Signature | Compact signatures | Lattice (NTRU) |

### Parameter Sets

#### ML-KEM (Kyber) — Key Encapsulation
| Parameter | Security Level | PK Size | SK Size | Ciphertext | Shared Secret |
|-----------|---------------|---------|---------|------------|--------------|
| ML-KEM-512 | NIST Level 1 (≈AES-128) | 800 B | 1,632 B | 768 B | 32 B |
| ML-KEM-768 | NIST Level 3 (≈AES-192) | 1,184 B | 2,400 B | 1,088 B | 32 B |
| **ML-KEM-1024** | **NIST Level 5 (≈AES-256)** | **1,568 B** | **3,168 B** | **1,568 B** | **32 B** |

#### ML-DSA (Dilithium) — Digital Signatures
| Parameter | Security Level | PK Size | SK Size | Signature |
|-----------|---------------|---------|---------|-----------|
| ML-DSA-44 | NIST Level 2 | 1,312 B | 2,560 B | 2,420 B |
| **ML-DSA-65** | **NIST Level 3** | **1,952 B** | **4,032 B** | **3,309 B** |
| ML-DSA-87 | NIST Level 5 | 2,592 B | 4,896 B | 4,627 B |

---

## Python Implementation (liboqs)

```bash
pip install liboqs-python
# or
pip install pqcrypto
```

### ML-KEM (Kyber) — Key Encapsulation
```python
import oqs

def pqc_key_exchange():
    """Post-quantum key exchange using ML-KEM-1024 (Kyber)"""
    
    # === SERVER SIDE ===
    # Generate keypair
    kem = oqs.KeyEncapsulation("ML-KEM-1024")
    public_key = kem.generate_keypair()  # Send to client
    secret_key = kem.export_secret_key()
    
    # === CLIENT SIDE ===
    # Encapsulate (client creates shared secret + ciphertext)
    kem_client = oqs.KeyEncapsulation("ML-KEM-1024")
    ciphertext, shared_secret_client = kem_client.encaps_secret(public_key)
    # Send ciphertext to server
    
    # === SERVER SIDE ===
    # Decapsulate (server recovers shared secret)
    shared_secret_server = kem.decaps_secret(ciphertext)
    
    # Both sides now have the same shared secret (32 bytes)
    assert shared_secret_client == shared_secret_server
    
    # Use shared secret as AES-256-GCM key
    return shared_secret_server  # 32 bytes = AES-256 key


def hybrid_encrypt(plaintext: str, recipient_public_key: bytes) -> dict:
    """
    Hybrid encryption: ML-KEM for key exchange + AES-256-GCM for data
    ✅ Recommended pattern for post-quantum encryption
    """
    import os
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    
    # 1. Post-quantum key encapsulation
    kem = oqs.KeyEncapsulation("ML-KEM-1024")
    ciphertext_kem, shared_secret = kem.encaps_secret(recipient_public_key)
    
    # 2. Derive AES key from shared secret
    # shared_secret is already 32 bytes = perfect AES-256 key
    aes_key = shared_secret
    
    # 3. Encrypt data with AES-256-GCM
    nonce = os.urandom(12)
    aesgcm = AESGCM(aes_key)
    ciphertext_data = aesgcm.encrypt(nonce, plaintext.encode(), None)
    
    return {
        'kem_ciphertext': ciphertext_kem,  # Send to recipient
        'nonce': nonce,
        'ciphertext': ciphertext_data,     # Encrypted data
        'algorithm': 'ML-KEM-1024 + AES-256-GCM',
    }


def hybrid_decrypt(encrypted: dict, secret_key: bytes) -> str:
    """Decrypt hybrid ML-KEM + AES-256-GCM"""
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    
    # 1. Recover shared secret
    kem = oqs.KeyEncapsulation("ML-KEM-1024", secret_key=secret_key)
    shared_secret = kem.decaps_secret(encrypted['kem_ciphertext'])
    
    # 2. Decrypt with AES-256-GCM
    aesgcm = AESGCM(shared_secret)
    plaintext = aesgcm.decrypt(encrypted['nonce'], encrypted['ciphertext'], None)
    
    return plaintext.decode()
```

### ML-DSA (Dilithium) — Digital Signatures
```python
import oqs

def pqc_sign_verify():
    """Post-quantum digital signature using ML-DSA-65 (Dilithium)"""
    
    # Generate keypair
    signer = oqs.Signature("ML-DSA-65")
    public_key = signer.generate_keypair()
    
    # Sign message
    message = b"Transfer Rp 5.000.000 to account 1234567890"
    signature = signer.sign(message)
    
    # Verify signature (can be done by anyone with public key)
    verifier = oqs.Signature("ML-DSA-65")
    is_valid = verifier.verify(message, signature, public_key)
    
    assert is_valid  # True if signature is valid
    return is_valid
```

---

## Node.js Implementation

```bash
npm install crystals-kyber
# or use liboqs-node
npm install liboqs-node
```

```typescript
// Using crystals-kyber (pure JS implementation)
import { KyberEncapsulate, KyberDecapsulate, KyberKeyGen } from 'crystals-kyber';

async function postQuantumKeyExchange() {
  // Server: Generate keypair
  const { publicKey, privateKey } = await KyberKeyGen(1024); // ML-KEM-1024
  
  // Client: Encapsulate
  const { ciphertext, sharedSecret: clientSecret } = await KyberEncapsulate(publicKey, 1024);
  
  // Server: Decapsulate
  const serverSecret = await KyberDecapsulate(ciphertext, privateKey, 1024);
  
  // Both have same 32-byte shared secret → use as AES-256-GCM key
  // clientSecret === serverSecret
  
  return serverSecret;
}
```

---

## Hybrid Approach (Classical + PQC)

```
✅ RECOMMENDED: Use BOTH classical and post-quantum algorithms

Why hybrid?
1. PQC algorithms are new — possible unknown vulnerabilities
2. Classical algorithms are well-tested for decades
3. Hybrid = secure against BOTH classical AND quantum attacks
4. If either algorithm is broken, the other still protects

Hybrid Key Exchange:
  Classical:  X25519 (ECDH) → shared_secret_1
  PQC:        ML-KEM-1024    → shared_secret_2
  Combined:   HKDF(shared_secret_1 || shared_secret_2) → final_key

Hybrid Signature:
  Classical:  Ed25519         → signature_1
  PQC:        ML-DSA-65       → signature_2
  Valid if:   BOTH signatures verify
```

### Hybrid Implementation
```python
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey, X25519PublicKey
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes
import oqs

def hybrid_key_exchange_full():
    """
    X25519 + ML-KEM-1024 hybrid key exchange
    Secure against both classical and quantum attacks
    """
    
    # === Classical: X25519 ===
    server_x25519_private = X25519PrivateKey.generate()
    server_x25519_public = server_x25519_private.public_key()
    
    client_x25519_private = X25519PrivateKey.generate()
    client_x25519_public = client_x25519_private.public_key()
    
    classical_shared = server_x25519_private.exchange(client_x25519_public)
    
    # === Post-Quantum: ML-KEM-1024 ===
    kem = oqs.KeyEncapsulation("ML-KEM-1024")
    pqc_public_key = kem.generate_keypair()
    
    kem_client = oqs.KeyEncapsulation("ML-KEM-1024")
    kem_ciphertext, pqc_shared = kem_client.encaps_secret(pqc_public_key)
    
    pqc_shared_server = kem.decaps_secret(kem_ciphertext)
    
    # === Combine with HKDF ===
    combined_secret = classical_shared + pqc_shared_server
    
    final_key = HKDF(
        algorithm=hashes.SHA256(),
        length=32,  # 256-bit key for AES-256
        salt=None,
        info=b"hybrid-x25519-mlkem1024",
    ).derive(combined_secret)
    
    return final_key  # Use as AES-256-GCM key
```

---

## TLS 1.3 with Post-Quantum

```
Browser support (2024+):
  ✅ Chrome 124+   — X25519Kyber768 hybrid
  ✅ Firefox 128+  — X25519Kyber768 hybrid
  ✅ Edge 124+     — X25519Kyber768 hybrid

Server configuration (Nginx + OpenSSL 3.2+):
  ssl_ecdh_curve X25519Kyber768:X25519:P-256;

Cloudflare:
  ✅ Automatically enabled for all customers (2024)
  Uses X25519Kyber768Draft00 for key exchange
```

---

## Migration Strategy

```
Phase 1: Inventory (NOW)
  □ Identify all cryptographic usage in codebase
  □ List algorithms: RSA, ECDSA, ECDH, DH
  □ Assess data sensitivity and lifetime
  □ Prioritize: data with 10+ year confidentiality need

Phase 2: Hybrid (2024-2026)
  □ Implement hybrid key exchange (X25519 + ML-KEM)
  □ Implement hybrid signatures (Ed25519 + ML-DSA)
  □ Enable PQC in TLS (server and client)
  □ Test interoperability

Phase 3: PQC-Only (2027+)
  □ Transition to PQC-only when ecosystem is mature
  □ Remove classical algorithms when no longer needed
  □ Update all certificates to PQC
  □ Audit for remaining vulnerable algorithms

Urgency by data type:
  🔴 IMMEDIATE: Government secrets, military, health records
  🟠 SOON: Financial data, legal documents, trade secrets
  🟡 PLAN: Personal data (UU PDP), business communications
  🟢 MONITOR: Ephemeral data, short-lived sessions
```

---

## Algorithm Recommendations

```
Key Exchange / Encryption:
  ✅ ML-KEM-1024 (Kyber) — NIST FIPS 203, primary choice
  ✅ Hybrid: X25519 + ML-KEM-768 — recommended transition approach

Digital Signatures:
  ✅ ML-DSA-65 (Dilithium) — NIST FIPS 204, general purpose
  ✅ SLH-DSA-SHA2-256s (SPHINCS+) — NIST FIPS 205, hash-based backup
  ✅ FN-DSA-512 (FALCON) — NIST FIPS 206, compact signatures

Symmetric (already quantum-safe):
  ✅ AES-256-GCM — remains secure (see skills/aes-256/)
  ✅ ChaCha20-Poly1305 — remains secure
  ✅ SHA-3 / SHA-256 — remains secure

❌ DEPRECATED (quantum-vulnerable):
  ❌ RSA (any key size) — broken by Shor's algorithm
  ❌ ECDSA / ECDH — broken by Shor's algorithm
  ❌ DSA — broken by Shor's algorithm
  ❌ Diffie-Hellman — broken by Shor's algorithm
```

## Best Practices
1. **Start hybrid NOW** — combine classical + PQC during transition
2. **ML-KEM-1024 for encryption** — NIST Level 5, strongest security
3. **ML-DSA-65 for signatures** — balanced security and size
4. **AES-256 remains safe** — no need to replace symmetric encryption
5. **"Harvest now, decrypt later"** — encrypt sensitive long-lived data with PQC today
6. **Test key/signature sizes** — PQC keys are much larger than RSA/ECC
7. **Monitor NIST updates** — PQC standards are evolving
8. **Enable PQC TLS** — most browsers already support Kyber hybrid
