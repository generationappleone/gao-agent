---
name: Deploy Flutter
description: Skill for deploying Flutter applications — covering Android (APK/AAB, Play Store), iOS (App Store), Web (hosting), CI/CD with Codemagic/GitHub Actions, and release management.
---

# Deploy Flutter Skill

## Overview
Deployment strategies for Flutter apps across Android, iOS, Web, and Desktop platforms. Covers build configurations, signing, store submissions, and CI/CD.

---

## Android Deployment

### Build APK / AAB
```bash
# Debug APK
flutter build apk --debug

# Release APK (direct install)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Release AAB (Google Play Store — recommended)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Split APKs (smaller size per architecture)
flutter build apk --release --split-per-abi
# Output: app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, app-x86_64-release.apk
```

### Signing Configuration
```groovy
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file(System.getenv("KEYSTORE_PATH") ?: "upload-keystore.jks")
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Generate Keystore
```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload -storepass YOUR_PASSWORD
```

---

## iOS Deployment

```bash
# Build iOS
flutter build ios --release

# Build IPA (for distribution)
flutter build ipa --release
# Output: build/ios/ipa/app.ipa

# Specific export method
flutter build ipa --release --export-method app-store
```

---

## Web Deployment

```bash
# Build web
flutter build web --release --web-renderer canvaskit
# Output: build/web/

# With base URL (if not at root)
flutter build web --release --base-href /my-app/
```

### Deploy to Firebase Hosting
```bash
firebase init hosting  # Select build/web as public directory
firebase deploy --only hosting
```

### Deploy to Nginx
```nginx
server {
    listen 80;
    server_name app.example.com;
    root /var/www/flutter-web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## CI/CD (GitHub Actions)

```yaml
name: Build & Deploy Flutter
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          cache: true

      - run: flutter pub get
      - run: flutter build web --release

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
```

## Best Practices
1. **AAB over APK** — Google Play requires AAB; smaller downloads
2. **Signing keys** — store in CI secrets, never commit to repo
3. **Obfuscation** — `--obfuscate --split-debug-info=./debug-info/`
4. **CanvasKit for web** — better rendering than HTML renderer
5. **Flavor/Environment configs** — separate dev/staging/prod builds
6. **Version management** — auto-increment `versionCode` in CI
