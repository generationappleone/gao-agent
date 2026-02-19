---
name: Firebase
description: Skill for building applications with Firebase — covering Authentication, Firestore, Realtime Database, Cloud Storage, Cloud Functions, Hosting, Cloud Messaging (FCM), and Security Rules.
---

# Firebase Skill

## Overview
Firebase is Google's Backend-as-a-Service (BaaS) platform for building web and mobile applications with real-time capabilities.

**Reference**: [Firebase Documentation](https://firebase.google.com/docs)

## Setup
```bash
npm install firebase                    # Client SDK
npm install firebase-admin              # Admin SDK (server)
npx -y firebase-tools login
npx firebase init                       # Select services
```

## Authentication
```typescript
import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signInWithPopup, GoogleAuthProvider, onAuthStateChanged } from "firebase/auth";

const auth = getAuth();

// Sign up
const { user } = await createUserWithEmailAndPassword(auth, email, password);

// Sign in
await signInWithEmailAndPassword(auth, email, password);

// Google OAuth
const provider = new GoogleAuthProvider();
await signInWithPopup(auth, provider);

// Auth state listener
onAuthStateChanged(auth, (user) => {
  if (user) console.log("Logged in:", user.uid);
  else console.log("Logged out");
});

// Get ID token (for backend verification)
const token = await user.getIdToken();
```

## Firestore
```typescript
import { getFirestore, collection, doc, addDoc, getDoc, getDocs, updateDoc, deleteDoc, query, where, orderBy, limit, onSnapshot, serverTimestamp } from "firebase/firestore";

const db = getFirestore();

// Create
const docRef = await addDoc(collection(db, "users"), {
  name: "John", email: "john@example.com", createdAt: serverTimestamp(),
});

// Read
const docSnap = await getDoc(doc(db, "users", docRef.id));
if (docSnap.exists()) console.log(docSnap.data());

// Query
const q = query(collection(db, "users"), where("role", "==", "admin"), orderBy("createdAt", "desc"), limit(20));
const snapshot = await getDocs(q);
snapshot.forEach(doc => console.log(doc.id, doc.data()));

// Real-time listener
const unsubscribe = onSnapshot(q, (snapshot) => {
  snapshot.docChanges().forEach(change => {
    if (change.type === "added") console.log("New:", change.doc.data());
    if (change.type === "modified") console.log("Modified:", change.doc.data());
    if (change.type === "removed") console.log("Removed:", change.doc.data());
  });
});
```

## Cloud Functions
```typescript
import { onRequest } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";

// HTTP function
export const api = onRequest({ cors: true }, async (req, res) => {
  const users = await getFirestore().collection("users").get();
  res.json({ data: users.docs.map(d => ({ id: d.id, ...d.data() })) });
});

// Firestore trigger
export const onUserCreated = onDocumentCreated("users/{userId}", async (event) => {
  const user = event.data?.data();
  await sendWelcomeEmail(user?.email);
});
```

## Security Rules (Firestore)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }

    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.authorId == request.auth.uid;
    }
  }
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Security Rules** | Always configure — never leave open |
| **Admin SDK** | Use on server for privileged operations |
| **Composite indexes** | Create for complex queries |
| **Batch writes** | Use `writeBatch()` for atomic operations |
| **Pagination** | Use `startAfter()` cursor-based pagination |
| **Offline support** | Enable `enablePersistence()` for offline |
| **FCM** | Use topics for broadcast notifications |
| **Environment** | Use different projects for dev/staging/prod |
| **Cost** | Monitor reads/writes in Firebase console |
| **Unsubscribe** | Always clean up `onSnapshot` listeners |
