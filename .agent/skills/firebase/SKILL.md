---
name: Firebase
description: Skill for building applications with Firebase — covering Authentication, Firestore, Realtime Database, Cloud Storage, Cloud Functions, Hosting, Cloud Messaging (FCM), and Security Rules.
---

# Firebase Skill

## Overview
Firebase is Google's app development platform providing authentication, NoSQL databases (Firestore), file storage, serverless functions, hosting, and push notifications. Firebase is ideal for rapid development with real-time capabilities.

**References**:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

---

## Setup

```bash
npm install firebase firebase-admin
```

```typescript
// src/lib/firebase.ts (Client SDK)
import { initializeApp } from 'firebase/app';
import { getAuth, connectAuthEmulator } from 'firebase/auth';
import { getFirestore, connectFirestoreEmulator } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Connect to emulators in development
if (process.env.NODE_ENV === 'development') {
  connectAuthEmulator(auth, 'http://localhost:9099');
  connectFirestoreEmulator(db, 'localhost', 8080);
}
```

```typescript
// src/lib/firebase-admin.ts (Admin SDK — server only)
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

if (!getApps().length) {
  initializeApp({
    credential: cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT!)),
  });
}

export const adminAuth = getAuth();
export const adminDb = getFirestore();
```

---

## Authentication

```typescript
// src/services/auth.service.ts
import { auth } from '@/lib/firebase';
import {
  createUserWithEmailAndPassword, signInWithEmailAndPassword,
  signOut, onAuthStateChanged, GoogleAuthProvider, signInWithPopup,
  sendPasswordResetEmail, updateProfile, User, sendEmailVerification,
} from 'firebase/auth';

// Register
export async function register(email: string, password: string, name: string) {
  const { user } = await createUserWithEmailAndPassword(auth, email, password);
  await updateProfile(user, { displayName: name });
  await sendEmailVerification(user);
  return user;
}

// Login
export async function login(email: string, password: string) {
  const { user } = await signInWithEmailAndPassword(auth, email, password);
  return user;
}

// Google OAuth
export async function loginWithGoogle() {
  const provider = new GoogleAuthProvider();
  provider.addScope('profile');
  provider.addScope('email');
  const { user } = await signInWithPopup(auth, provider);
  return user;
}

// Logout
export async function logout() { await signOut(auth); }

// Password reset
export async function resetPassword(email: string) {
  await sendPasswordResetEmail(auth, email);
}

// Auth state observer
export function onAuthChange(callback: (user: User | null) => void) {
  return onAuthStateChanged(auth, callback);
}

// Get ID token for API calls
export async function getIdToken(): Promise<string | null> {
  const user = auth.currentUser;
  if (!user) return null;
  return user.getIdToken();
}
```

---

## Firestore CRUD

```typescript
// src/services/firestore.service.ts
import { db } from '@/lib/firebase';
import {
  collection, doc, getDoc, getDocs, addDoc, updateDoc, deleteDoc,
  query, where, orderBy, limit, startAfter, onSnapshot,
  serverTimestamp, increment, arrayUnion, arrayRemove,
  DocumentSnapshot, QueryConstraint, writeBatch, runTransaction,
} from 'firebase/firestore';

// ── Create ──
export async function createProduct(data: CreateProductInput) {
  const ref = await addDoc(collection(db, 'products'), {
    ...data,
    rating: 0,
    ratingCount: 0,
    status: 'draft',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return ref.id;
}

// ── Read single ──
export async function getProduct(id: string) {
  const snap = await getDoc(doc(db, 'products', id));
  if (!snap.exists()) throw new Error('Product not found');
  return { id: snap.id, ...snap.data() };
}

// ── List with pagination + filters ──
export async function listProducts(options: {
  category?: string;
  status?: string;
  sortBy?: string;
  pageSize?: number;
  cursor?: DocumentSnapshot;
}) {
  const constraints: QueryConstraint[] = [];

  if (options.status) constraints.push(where('status', '==', options.status));
  if (options.category) constraints.push(where('categoryId', '==', options.category));

  switch (options.sortBy) {
    case 'price_asc': constraints.push(orderBy('price', 'asc')); break;
    case 'price_desc': constraints.push(orderBy('price', 'desc')); break;
    case 'rating': constraints.push(orderBy('rating', 'desc')); break;
    default: constraints.push(orderBy('createdAt', 'desc'));
  }

  constraints.push(limit(options.pageSize || 20));
  if (options.cursor) constraints.push(startAfter(options.cursor));

  const q = query(collection(db, 'products'), ...constraints);
  const snap = await getDocs(q);

  return {
    data: snap.docs.map(d => ({ id: d.id, ...d.data() })),
    lastDoc: snap.docs[snap.docs.length - 1],
    hasMore: snap.docs.length === (options.pageSize || 20),
  };
}

// ── Update ──
export async function updateProduct(id: string, data: Partial<Product>) {
  await updateDoc(doc(db, 'products', id), {
    ...data,
    updatedAt: serverTimestamp(),
  });
}

// ── Toggle like ──
export async function toggleLike(productId: string, userId: string) {
  const ref = doc(db, 'products', productId);
  const snap = await getDoc(ref);
  const likes: string[] = snap.data()?.likes || [];

  if (likes.includes(userId)) {
    await updateDoc(ref, {
      likes: arrayRemove(userId),
      likeCount: increment(-1),
    });
  } else {
    await updateDoc(ref, {
      likes: arrayUnion(userId),
      likeCount: increment(1),
    });
  }
}

// ── Real-time listener ──
export function onProductsChange(callback: (products: Product[]) => void) {
  const q = query(collection(db, 'products'), where('status', '==', 'active'), orderBy('createdAt', 'desc'), limit(50));

  return onSnapshot(q, (snap) => {
    const products = snap.docs.map(d => ({ id: d.id, ...d.data() } as Product));
    callback(products);
  });
}

// ── Batch write ──
export async function batchUpdatePrices(updates: { id: string; price: number }[]) {
  const batch = writeBatch(db);
  updates.forEach(({ id, price }) => {
    batch.update(doc(db, 'products', id), { price, updatedAt: serverTimestamp() });
  });
  await batch.commit();
}

// ── Transaction ──
export async function purchaseProduct(productId: string, userId: string) {
  await runTransaction(db, async (transaction) => {
    const productRef = doc(db, 'products', productId);
    const snap = await transaction.get(productRef);

    if (!snap.exists()) throw new Error('Product not found');
    if (snap.data().stock <= 0) throw new Error('Out of stock');

    transaction.update(productRef, { stock: increment(-1) });
    transaction.set(doc(collection(db, 'orders')), {
      productId, userId, status: 'pending', createdAt: serverTimestamp(),
    });
  });
}
```

---

## Security Rules

```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return request.auth.uid == userId; }
    function isAdmin() { return request.auth.token.role == 'admin'; }

    match /products/{productId} {
      allow read: if true;
      allow create: if isAuthenticated() && isAdmin();
      allow update: if isAuthenticated() && isAdmin();
      allow delete: if isAuthenticated() && isAdmin();
    }

    match /orders/{orderId} {
      allow read: if isAuthenticated() && (isOwner(resource.data.userId) || isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && isAdmin();
    }

    match /users/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

---

## Cloud Storage

```typescript
import { storage } from '@/lib/firebase';
import { ref, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage';

export async function uploadFile(file: File, path: string): Promise<string> {
  const storageRef = ref(storage, path);
  const snap = await uploadBytes(storageRef, file, {
    contentType: file.type,
    customMetadata: { uploadedBy: 'user' },
  });
  return getDownloadURL(snap.ref);
}

export async function deleteFile(path: string) {
  await deleteObject(ref(storage, path));
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Security rules** | Never use open rules in production |
| **Admin SDK** | Server-only; never expose service account to client |
| **Emulators** | Use Firebase emulators for local development |
| **Indexes** | Create composite indexes for complex queries |
| **serverTimestamp** | Use for consistent server-side timestamps |
| **Batch/Transaction** | Batch for multi-writes, transaction for read-then-write |
| **Pagination** | Use `startAfter` cursor, not offset |
| **Listeners** | Unsubscribe `onSnapshot` on component unmount |
| **Offline** | Enable persistence for offline support |
| **ID tokens** | Use `getIdToken()` for backend API authentication |

---

## Rules Integration
- **Auth**: Email/password + Google OAuth + state observer
- **Firestore**: CRUD, pagination, real-time, batch, transactions
- **Security**: Rules with helper functions (isAuth, isOwner, isAdmin)
- **Storage**: Upload/download with typed metadata
- **Best practices**: Emulators, indexes, cursor pagination
