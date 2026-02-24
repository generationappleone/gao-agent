---
description: Deploy application to target environment. Auto-detects framework and routes to the correct deployment skill with pre-deployment checks.
---

# Context Deploy — Safe Application Deployment

## Purpose
This workflow orchestrates deployment by detecting the project's framework and routing to the appropriate deployment skill. It includes comprehensive pre-deployment validation, security hardening, environment verification, rollback planning, and post-deployment health checks.

> **This workflow coordinates the 7 deploy skills.** It NEVER deploys without explicit user approval.

---

## Activation
The user triggers this workflow by:
- Using `/context-deploy` to start guided deployment
- Using `/context-deploy docker` to deploy via Docker
- Using `/context-deploy [cloud]` to deploy to a cloud provider
- Using `/context-deploy --dry-run` to preview deployment without executing

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 0.5: Agent Lock Check (Race Condition Prevention)
// turbo
1. Check if `.agent/context/AGENT_LOCK` exists.
2. If it exists, STOP! Another agent is currently executing. Inform the user and abort.
3. If it does not exist, immediately create `.agent/context/AGENT_LOCK` with the current timestamp.
4. IMPORTANT: Meticulously delete `.agent/context/AGENT_LOCK` at the very end of this workflow OR whenever you pause to ask the user a question.

## Phase 1: Context & Detection

### Step 1.1 — Read Project Context
// turbo
```
1. .agent/context/CONTEXT_INDEX.md    ← Project overview
2. .agent/context/ARCHITECTURE.md     ← System architecture
3. .agent/context/DEVELOPMENT_GUIDE.md ← Build/run commands
4. .agent/context/DEPENDENCIES.md     ← Tech stack & versions
5. .agent/rules/deep-thinking.md      ← Quality standards (MANDATORY)
6. .agent/rules/developer-security.md ← Security requirements (MANDATORY)
```

### Step 1.2 — Detect Framework
// turbo
```bash
# Check for manifest files
ls package.json composer.json pom.xml build.gradle go.mod pyproject.toml requirements.txt *.csproj pubspec.yaml Cargo.toml Gemfile 2>/dev/null
# Check package.json for framework
cat package.json 2>/dev/null | head -30
# Check composer.json for framework
cat composer.json 2>/dev/null | head -20
```

### Step 1.3 — Load Deploy Skill
// turbo

| Detected Stack | Deploy Skill | Also Read |
|----------------|-------------|-----------|
| React / Next.js / Vue / Angular / Svelte | `skills/deploy-frontend/SKILL.md` | `skills/nginx/SKILL.md` |
| Laravel / PHP | `skills/deploy-laravel/SKILL.md` | `skills/nginx/SKILL.md`, `skills/php/SKILL.md` |
| Spring Boot / Java | `skills/deploy-java/SKILL.md` | `skills/java/SKILL.md` |
| Flutter / Dart | `skills/deploy-flutter/SKILL.md` | `skills/flutter/SKILL.md` |
| Django / Flask / FastAPI | `skills/deploy-python/SKILL.md` | `skills/nginx/SKILL.md`, `skills/python/SKILL.md` |
| Go | `skills/deploy-go/SKILL.md` | `skills/golang/SKILL.md` |
| .NET / ASP.NET | `skills/deploy-dotnet/SKILL.md` | `skills/aspnet/SKILL.md` |

Additionally, always read based on target:
- **Docker**: Read `skills/docker/SKILL.md`
- **Kubernetes**: Read `skills/kubernetes/SKILL.md`
- **AWS**: Read `skills/aws/SKILL.md`
- **GCP**: Read `skills/gcp/SKILL.md`
- **Azure**: Read `skills/azure/SKILL.md`
- **VPS/Nginx**: Read `skills/nginx/SKILL.md`, `skills/load-balancing/SKILL.md`

---

## Phase 2: Deployment Configuration

### Step 2.1 — Ask Deployment Target

```markdown
🚀 Deploy Configuration

Detected stack: **[framework]** ([version])

Where would you like to deploy?
1. 🐳 **Docker** — Build optimized container image (Dockerfile + docker-compose)
2. ☁️  **Cloud Platform** — Vercel / Netlify / AWS / GCP / Azure / Railway
3. 🖥️  **VPS/Server** — Nginx + systemd / PM2 + reverse proxy
4. 📦 **Build Only** — Generate production bundle without deployment
5. ☸️  **Kubernetes** — Generate K8s manifests (Deployment, Service, Ingress)

Environment:
- [ ] Development
- [ ] Staging
- [ ] Production

Additional options:
- Zero-downtime deployment? [yes / no]
- Custom domain + SSL? [yes / no]
- Health check endpoint? [specify URL or auto-detect]
- Database migration needed? [yes / no]
```

---

## Phase 3: Pre-Deployment Checks (MANDATORY)

### Step 3.1 — Build Verification
// turbo
```bash
# Production build — MUST succeed
npm run build 2>&1 | tail -30
# OR
composer install --no-dev --optimize-autoloader 2>&1 | tail -20
# OR framework-specific build command
```

### Step 3.2 — Test Verification
// turbo
```bash
# All tests MUST pass
npm test -- --watchAll=false 2>&1 | tail -30
# OR
php artisan test 2>&1 | tail -20
# OR framework-specific test command
```

### Step 3.3 — Security Audit
// turbo
```bash
# Dependency vulnerability scan
npm audit --production 2>&1 | tail -20
# OR
composer audit 2>&1 | tail -20

# Check for hardcoded secrets
grep -rn "password\|secret\|api_key\|private_key" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.env" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.env.example' 2>/dev/null | head -20

# Check .env.example is up to date
diff <(grep -oP '^[A-Z_]+=' .env | sort) <(grep -oP '^[A-Z_]+=' .env.example | sort) 2>/dev/null
```

### Step 3.4 — Environment Validation
// turbo
```bash
# List all required env vars
grep -rn "process.env\.\|env(\|getenv\|os.environ" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' 2>/dev/null | grep -oP "(process\.env\.|env\(|getenv\(|os\.environ\[)['\"]?\K[A-Z_]+" | sort -u

# Verify debug mode is OFF
grep -rn "APP_DEBUG\|DEBUG=true\|NODE_ENV=development" .env 2>/dev/null
```

### Step 3.5 — Pre-Deployment Checklist

| Check | Status | Required |
|-------|--------|----------|
| Production build succeeds | ✅/❌ | YES |
| All tests pass | ✅/❌ | YES |
| No critical security vulnerabilities | ✅/❌ | YES |
| No hardcoded secrets in code | ✅/❌ | YES |
| `.env.example` is up-to-date | ✅/❌ | YES |
| Debug mode disabled | ✅/❌ | YES |
| Database migrations ready | ✅/❌ | If applicable |
| CORS configured for production domain | ✅/❌ | If API |
| SSL/TLS certificate ready | ✅/❌ | If custom domain |
| Rate limiting configured | ✅/❌ | RECOMMENDED |
| Error logging configured (not console.log) | ✅/❌ | RECOMMENDED |
| Health check endpoint exists | ✅/❌ | RECOMMENDED |

**If ANY required check fails → STOP. Fix before proceeding.**

---

## Phase 4: Deployment Artifact Generation

### Step 4.1 — Docker
If Docker deployment:
- Generate multi-stage `Dockerfile` (build + runtime)
- Generate `docker-compose.prod.yml`
- Generate `.dockerignore`
- Optimize image size (Alpine/distroless base, minimize layers)
- Set non-root user
- Add health check instruction
- Follow `skills/docker/SKILL.md` patterns

### Step 4.2 — Cloud Platform
If cloud deployment:
- Generate platform-specific config (`vercel.json`, `netlify.toml`, `app.yaml`, etc.)
- Configure environment variables
- Set up custom domain if requested
- Configure CDN/caching rules
- Follow platform-specific skill patterns

### Step 4.3 — VPS/Server
If VPS deployment:
- Generate Nginx reverse proxy config with security headers
- Generate systemd service / PM2 ecosystem file
- Generate deployment script (`deploy.sh`) with rollback support
- Configure SSL with Let's Encrypt (reference `skills/letsencrypt-acme/SKILL.md`)
- Set up log rotation
- Follow `skills/nginx/SKILL.md` patterns

### Step 4.4 — Kubernetes
If K8s deployment:
- Generate Deployment, Service, Ingress manifests
- Generate ConfigMap and Secret manifests
- Set resource limits (CPU/memory)
- Configure liveness/readiness probes
- Set pod disruption budget
- Follow `skills/kubernetes/SKILL.md` patterns

---

## Phase 5: Approval Gate

### Step 5.1 — ⛔ STOP — Present Deployment Plan

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 DEPLOYMENT PLAN — REQUIRES APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stack:          [Framework] [version]
Target:         [Docker / Cloud / VPS / K8s]
Environment:    [staging / production]

Pre-deployment:
  🔨 Build:     ✅ Passed
  🧪 Tests:     ✅ [N] passing
  🔒 Security:  ✅ No critical issues
  ⚙️ Config:    ✅ Env vars documented

Files to create/modify:
  [list of files with brief description]

Environment variables needed:
  [list of required env vars]

Rollback plan:
  [how to revert if deployment fails]

Estimated downtime: [none / X minutes]

⚠️ Shall I proceed with deployment?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**DO NOT proceed without explicit user approval.**

---

## Phase 6: Execution

### Step 6.1 — Execute Deployment
After user approval, execute the deployment steps following the specific skill's guidance.

### Step 6.2 — Run Database Migrations (if applicable)
```bash
# ALWAYS backup before migration in production
# Run migration
# Verify migration succeeded
```

---

## Phase 7: Post-Deployment Verification

### Step 7.1 — Health Checks
// turbo
```bash
# Health check endpoint
curl -s -o /dev/null -w "%{http_code}" https://[deployment-url]/health 2>&1

# Key pages respond
curl -s -o /dev/null -w "%{http_code}" https://[deployment-url]/ 2>&1

# API endpoint test
curl -s -o /dev/null -w "%{http_code}" https://[deployment-url]/api/health 2>&1

# SSL certificate validity
echo | openssl s_client -connect [domain]:443 2>/dev/null | openssl x509 -noout -dates 2>&1
```

### Step 7.2 — Smoke Test Checklist
| Check | Status |
|-------|--------|
| Homepage loads (HTTP 200) | ✅/❌ |
| API health endpoint responds | ✅/❌ |
| Authentication flow works | ✅/❌ |
| Database queries succeed | ✅/❌ |
| Static assets load (CSS/JS/images) | ✅/❌ |
| SSL certificate valid | ✅/❌ |
| Security headers present | ✅/❌ |
| Error pages display correctly | ✅/❌ |

---

## Phase 8: Final Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ DEPLOYMENT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stack:       [framework]
Target:      [Docker / Cloud / VPS / K8s]
Environment: [staging / production]
URL:         [deployment URL]
Status:      ✅ Healthy
Build Time:  [X seconds]

Verification:
  🌐 Homepage:    ✅ HTTP 200
  🔌 API Health:  ✅ Responding
  🔒 SSL:         ✅ Valid until [date]
  📊 Headers:     ✅ Security headers present

Rollback Command:
  [command to rollback if issues arise]

Next Steps:
  📊 Monitor application logs
  🔍 Check error rates in first 30 minutes
  📈 Verify performance metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## When to Use
- Deploying to production, staging, or any environment
- Creating Docker images for distribution
- Setting up server configuration (Nginx, PM2, systemd)
- Building production bundles
- Deploying to Kubernetes clusters

## When to Skip
- Local development (use `npm run dev` or equivalent)
- Prototyping or sandbox mode
- Running dev servers locally
