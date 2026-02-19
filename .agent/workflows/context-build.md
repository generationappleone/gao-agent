---
description: Context-aware build — automatically detects the project framework/language and executes the correct build command with validation and error handling.
---

# Context Build — Framework-Aware Build Engine

## Purpose
This workflow **automatically detects** the project's framework/language and runs the correct build command. It supports multi-project workspaces (e.g., backend + frontend in the same repo) and provides consistent build output with error handling.

---

## Activation
The user triggers this workflow by:
- Using `/context-build` to auto-detect and build the entire project
- Using `/context-build frontend` to build only the frontend
- Using `/context-build backend` to build only the backend
- Using `/context-build [framework]` to force a specific framework build (e.g., `/context-build flutter`)
- Using `/context-build --prod` to build for production

---

## Phase 1: Project Detection

### Step 1.1 — Scan Project Root
// turbo
Detect the project framework by checking for configuration files:

```bash
# List all project config files in root and immediate subdirectories
find . -maxdepth 2 \( \
  -name "package.json" -o \
  -name "pom.xml" -o \
  -name "build.gradle" -o \
  -name "build.gradle.kts" -o \
  -name "pubspec.yaml" -o \
  -name "Cargo.toml" -o \
  -name "go.mod" -o \
  -name "composer.json" -o \
  -name "requirements.txt" -o \
  -name "pyproject.toml" -o \
  -name "Pipfile" -o \
  -name "*.csproj" -o \
  -name "*.sln" -o \
  -name "Gemfile" -o \
  -name "Makefile" -o \
  -name "CMakeLists.txt" -o \
  -name "Dockerfile" \
\) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null
```

### Step 1.2 — Identify Framework
// turbo
Based on the detected files, determine the framework(s):

```
Detection Matrix:

File Found                    → Framework          → Build Command
─────────────────────────────────────────────────────────────────
package.json + next.config.*  → Next.js            → npm run build
package.json + vite.config.*  → Vite (React/Vue)   → npm run build
package.json + angular.json   → Angular            → ng build --configuration production
package.json + nuxt.config.*  → Nuxt.js            → npm run build
package.json (has react)      → React (CRA/other)  → npm run build
package.json (has vue)        → Vue.js             → npm run build
package.json (has svelte)     → SvelteKit          → npm run build
package.json (typescript)     → Node.js/TypeScript  → npx tsc --noEmit && npm run build
package.json (plain)          → Node.js            → npm run build

pom.xml                       → Java/Maven         → mvn clean package -DskipTests
build.gradle / build.gradle.kts → Java/Gradle      → ./gradlew build -x test
*.csproj / *.sln              → .NET/C#            → dotnet build --configuration Release
pubspec.yaml                  → Flutter/Dart       → flutter build (apk/web/ios)
go.mod                        → Go                 → go build ./...
Cargo.toml                    → Rust               → cargo build --release
composer.json                 → PHP/Laravel        → composer install --no-dev --optimize-autoloader
requirements.txt/pyproject    → Python             → pip install -e . / python -m build
Gemfile                       → Ruby/Rails         → bundle exec rails assets:precompile
```

If **multiple frameworks** detected (monorepo):
```markdown
📦 Multi-Project Workspace Detected:

| # | Project      | Framework        | Path         |
|---|-------------|-----------------|-------------|
| 1 | Frontend    | Next.js (React) | ./frontend/ |
| 2 | Backend     | Laravel (PHP)   | ./backend/  |
| 3 | Mobile      | Flutter         | ./mobile/   |

Build options:
1. 🔨 **Build all** — Build all projects in dependency order
2. 🎯 **Build specific** — Choose which project to build
3. 📋 **Show commands** — Display build commands without executing

Which option?
```

### Step 1.3 — Read Context & Rules
// turbo
Check for project context and mandatory rules:

```bash
# Check if context documentation exists
cat .agent/context/DEVELOPMENT_GUIDE.md 2>/dev/null | head -50
cat .agent/context/DEPENDENCIES.md 2>/dev/null | head -30
```

Also read mandatory rules:
- `.agent/rules/deep-thinking.md` — Quality standards (MANDATORY)
- Read the framework-specific skill for build best practices:
  - **Node.js/React/Next.js**: `skills/nodejs/SKILL.md` or `skills/nextjs/SKILL.md`
  - **Laravel**: `skills/laravel/SKILL.md`
  - **Java**: `skills/java/SKILL.md`
  - **Flutter**: `skills/flutter/SKILL.md`
  - **Python**: `skills/python/SKILL.md`
  - **Go**: `skills/golang/SKILL.md`
  - **.NET**: `skills/aspnet/SKILL.md`
  - **Rust**: `skills/rust/SKILL.md`

### Step 1.4 — Load Relevant Deployment Skill
// turbo
Based on the detected framework, read the corresponding deployment skill:

```
Framework detected → Read skill file
─────────────────────────────────────
React/Next.js     → skills/deploy-frontend/SKILL.md
Laravel/PHP       → skills/deploy-laravel/SKILL.md
Java/Spring       → skills/deploy-java/SKILL.md
Flutter           → skills/deploy-flutter/SKILL.md
Django/Flask      → skills/deploy-python/SKILL.md
Go                → skills/deploy-go/SKILL.md
.NET              → skills/deploy-dotnet/SKILL.md
```

---

## Phase 2: Pre-Build Checks

### Step 2.1 — Dependency Installation
// turbo
Ensure dependencies are installed before building:

```bash
# Node.js/JavaScript
if [ -f "package.json" ]; then
  if [ ! -d "node_modules" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm ci    # Use ci for reproducible builds
  fi
fi

# PHP/Laravel
if [ -f "composer.json" ]; then
  if [ ! -d "vendor" ]; then
    echo "📦 Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
  fi
fi

# Python
if [ -f "requirements.txt" ]; then
  echo "📦 Checking Python dependencies..."
  pip install -r requirements.txt
fi

# Flutter
if [ -f "pubspec.yaml" ]; then
  echo "📦 Getting Flutter packages..."
  flutter pub get
fi

# Java/Maven
if [ -f "pom.xml" ]; then
  echo "📦 Resolving Maven dependencies..."
  mvn dependency:resolve -q
fi

# Go
if [ -f "go.mod" ]; then
  echo "📦 Downloading Go modules..."
  go mod download
fi

# .NET
if ls *.csproj 1>/dev/null 2>&1; then
  echo "📦 Restoring .NET packages..."
  dotnet restore
fi
```

### Step 2.2 — Environment Check
// turbo
Verify environment is ready for build:

```bash
# Check for required env files
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
  echo "⚠️ Missing .env file. Creating from .env.example..."
  cp .env.example .env
fi

# Check Node.js version (if applicable)
if [ -f ".nvmrc" ]; then
  echo "Required Node version: $(cat .nvmrc)"
  echo "Current Node version: $(node -v)"
fi

# Check PHP version (if applicable)
if [ -f "composer.json" ]; then
  echo "Current PHP version: $(php -v | head -1)"
fi
```

---

## Phase 3: Build Execution

### Step 3.1 — Execute Build
// turbo
Run the appropriate build command based on detected framework:

#### Node.js / TypeScript / React / Next.js / Vue / Angular
```bash
echo "🔨 Building Node.js project..."
npm run build 2>&1 | tail -50
echo "Exit code: $?"
```

#### Java — Maven
```bash
echo "🔨 Building Java project (Maven)..."
mvn clean package -DskipTests 2>&1 | tail -50
echo "Exit code: $?"
```

#### Java — Gradle
```bash
echo "🔨 Building Java project (Gradle)..."
./gradlew clean build -x test 2>&1 | tail -50
echo "Exit code: $?"
```

#### Flutter
```bash
echo "🔨 Building Flutter project..."

# Detect target platform
if [ "$1" = "apk" ] || [ "$1" = "android" ]; then
  flutter build apk --release 2>&1 | tail -50
elif [ "$1" = "ios" ]; then
  flutter build ios --release 2>&1 | tail -50
elif [ "$1" = "web" ]; then
  flutter build web --release 2>&1 | tail -50
else
  # Default: build for web
  flutter build web --release 2>&1 | tail -50
fi
echo "Exit code: $?"
```

#### Go
```bash
echo "🔨 Building Go project..."
CGO_ENABLED=0 go build -ldflags="-s -w" -o ./bin/app ./cmd/... 2>&1 | tail -50
echo "Exit code: $?"
```

#### .NET / C#
```bash
echo "🔨 Building .NET project..."
dotnet build --configuration Release --no-restore 2>&1 | tail -50
echo "Exit code: $?"
```

#### PHP / Laravel
```bash
echo "🔨 Building Laravel project..."
composer install --no-dev --optimize-autoloader 2>&1 | tail -20
php artisan config:cache 2>&1
php artisan route:cache 2>&1
php artisan view:cache 2>&1
php artisan event:cache 2>&1
echo "✅ Laravel optimized for production"
```

#### Python (Django / Flask)
```bash
echo "🔨 Building Python project..."
# Type checking
if [ -f "pyproject.toml" ]; then
  python -m mypy . --ignore-missing-imports 2>&1 | tail -30
fi
# Collect static (Django)
if [ -f "manage.py" ]; then
  python manage.py collectstatic --noinput 2>&1 | tail -10
fi
echo "✅ Python project validated"
```

#### Rust
```bash
echo "🔨 Building Rust project..."
cargo build --release 2>&1 | tail -50
echo "Exit code: $?"
```

### Step 3.2 — Verify Build Output
// turbo
Verify that build artifacts were created:

```bash
# Node.js — check dist/build/.next directory
if [ -d "dist" ] || [ -d "build" ] || [ -d ".next" ] || [ -d "out" ]; then
  echo "✅ Build output found"
  du -sh dist/ build/ .next/ out/ 2>/dev/null
fi

# Java — check target/build directory
if [ -d "target" ] || [ -d "build/libs" ]; then
  echo "✅ Build output found"
  ls -la target/*.jar build/libs/*.jar 2>/dev/null
fi

# Flutter — check build directory
if [ -d "build" ]; then
  echo "✅ Build output found"
  du -sh build/ 2>/dev/null
fi

# Go — check binary
if [ -f "bin/app" ]; then
  echo "✅ Binary built: $(ls -la bin/app)"
fi

# .NET — check bin/Release
if [ -d "bin/Release" ]; then
  echo "✅ Build output found"
  du -sh bin/Release/ 2>/dev/null
fi
```

---

## Phase 4: Post-Build Actions

### Step 4.1 — Run Tests (Optional)
If the user specified `--test` or tests are configured:

// turbo
```bash
# Run framework-appropriate tests
npm test 2>&1 | tail -30                              # Node.js
mvn test 2>&1 | tail -30                              # Java Maven
./gradlew test 2>&1 | tail -30                        # Java Gradle
flutter test 2>&1 | tail -30                          # Flutter
go test ./... 2>&1 | tail -30                         # Go
dotnet test 2>&1 | tail -30                           # .NET
python -m pytest 2>&1 | tail -30                      # Python
php artisan test 2>&1 | tail -30                      # Laravel
```

### Step 4.2 — Security Audit
// turbo
```bash
# Node.js
npm audit --production 2>&1 | tail -20

# PHP
composer audit 2>&1 | tail -20

# Python
pip audit 2>&1 | tail -20

# Go
govulncheck ./... 2>&1 | tail -20
```

### Step 4.3 — Build Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ BUILD COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Framework:    [Detected framework]
Build Mode:   [Development / Production]
Duration:     [X seconds]
Output:       [Path to build artifacts]
Size:         [Build output size]

Build Status:
  ✅ Dependencies installed
  ✅ Build completed successfully
  ✅ Build artifacts verified
  ⚠️ 2 audit warnings (non-critical)

Build Artifacts:
  📁 dist/          → 2.4 MB (frontend bundle)
  📁 target/app.jar → 45 MB (backend JAR)

Next Steps:
  🚀 /context-deploy — Deploy to staging/production
  🧪 /context-test   — Run test suite
  📋 /context-plan   — Plan next feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Phase 5: Error Handling

### Build Failure
If the build fails:
1. **Read the error output** carefully
2. **Identify the error type:**
   - Compilation error → Show file, line, error message
   - Missing dependency → Run install command
   - Configuration error → Check env/config files
   - Out of memory → Suggest increasing heap size
3. **Attempt auto-fix** for common errors:
   - Missing `node_modules` → `npm ci`
   - TypeScript type error → Show fix suggestion
   - Missing env variable → List required variables
4. **Report to user** if auto-fix fails

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ BUILD FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Framework:  Next.js (React)
Error Type: TypeScript Compilation Error

Error Details:
  File:    src/components/Dashboard.tsx:42
  Message: Type 'string' is not assignable to type 'number'

Suggested Fix:
  Change line 42 from:
    const count: number = data.count;
  To:
    const count: number = Number(data.count);

Auto-fix? (Y/n)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Framework Quick Commands Reference

| Framework | Install Deps | Build (Dev) | Build (Prod) | Clean |
|-----------|-------------|------------|-------------|-------|
| **Next.js** | `npm ci` | `npm run dev` | `npm run build` | `rm -rf .next/` |
| **Vite/React** | `npm ci` | `npm run dev` | `npm run build` | `rm -rf dist/` |
| **Angular** | `npm ci` | `ng serve` | `ng build --configuration production` | `rm -rf dist/` |
| **Vue/Nuxt** | `npm ci` | `npm run dev` | `npm run build` | `rm -rf .nuxt/ .output/` |
| **Laravel** | `composer install` | `php artisan serve` | `php artisan optimize` | `php artisan optimize:clear` |
| **Django** | `pip install -r requirements.txt` | `python manage.py runserver` | `python manage.py collectstatic` | - |
| **Flask** | `pip install -r requirements.txt` | `flask run` | `gunicorn app:create_app()` | - |
| **Spring Boot** | `mvn dependency:resolve` | `mvn spring-boot:run` | `mvn clean package -DskipTests` | `mvn clean` |
| **Gradle** | `./gradlew dependencies` | `./gradlew bootRun` | `./gradlew build -x test` | `./gradlew clean` |
| **Flutter** | `flutter pub get` | `flutter run` | `flutter build apk/web/ios` | `flutter clean` |
| **Go** | `go mod download` | `go run .` | `go build -o bin/app` | `rm -rf bin/` |
| **.NET** | `dotnet restore` | `dotnet run` | `dotnet publish -c Release` | `dotnet clean` |
| **Rust** | `cargo fetch` | `cargo run` | `cargo build --release` | `cargo clean` |
