---
description: Deploy application to target environment. Auto-detects framework and routes to the correct deployment skill with pre-deployment checks.
---

# Context Deploy Workflow

This workflow orchestrates deployment by detect the project's framework and routing to the appropriate deployment skill. It includes pre-deployment validation, environment checks, and post-deployment verification.

> **This workflow coordinates the 7 deploy skills.** It never deploys without user approval.

## Steps

1. **Read project context** — Load `.agent/context/CONTEXT_INDEX.md` and `DEVELOPMENT_GUIDE.md` to understand the stack.
   // turbo

2. **Detect framework** — Auto-detect the project type:
   // turbo
   ```bash
   # Check for manifest files
   ls package.json composer.json pom.xml go.mod pyproject.toml requirements.txt *.csproj pubspec.yaml Cargo.toml 2>/dev/null
   ```

   | Detected | Deploy Skill |
   |----------|-------------|
   | React / Next.js / Vue / Angular | `skills/deploy-frontend/SKILL.md` |
   | Laravel / PHP | `skills/deploy-laravel/SKILL.md` |
   | Spring Boot / Java | `skills/deploy-java/SKILL.md` |
   | Flutter / Dart | `skills/deploy-flutter/SKILL.md` |
   | Django / Flask / FastAPI | `skills/deploy-python/SKILL.md` |
   | Go | `skills/deploy-go/SKILL.md` |
   | .NET / ASP.NET | `skills/deploy-dotnet/SKILL.md` |

3. **Load the deploy skill** — Read the matched `SKILL.md` for deployment patterns.
   // turbo

4. **Ask deployment target** — Clarify with user:
   ```markdown
   🚀 Deploy Configuration

   Detected stack: **[framework]**

   Where would you like to deploy?
   1. 🐳 Docker (build container image)
   2. ☁️ Cloud (Vercel / Netlify / AWS / GCP / Azure)
   3. 🖥️ VPS (Nginx + systemd / PM2)
   4. 📦 Build only (production bundle)

   Additional options:
   - Target environment: [development / staging / production]
   - Zero-downtime deployment? [yes / no]
   ```

5. **Pre-deployment checks** — MUST pass before deploying:
   // turbo
   - Build passes with zero errors
   - All tests pass
   - No critical security vulnerabilities (`npm audit` / `composer audit`)
   - Environment variables documented
   - `.env.example` is up-to-date
   - Debug mode disabled in production config

6. **Generate deployment artifacts** — Based on target:
   - **Docker:** Generate optimized `Dockerfile` and `docker-compose.prod.yml`
   - **Cloud:** Generate platform-specific config (vercel.json, netlify.toml, etc.)
   - **VPS:** Generate Nginx config, systemd service, deployment script
   - **Build:** Run production build command

7. **⛔ STOP — Ask for approval** — Present the deployment plan:
   ```markdown
   ## Deployment Plan

   - **Target:** [Docker / Cloud / VPS]
   - **Files to create/modify:** [list]
   - **Environment variables needed:** [list]
   - **Estimated downtime:** [none / X minutes]

   Shall I proceed with deployment?
   ```

8. **Execute deployment** — After user approval, execute the deployment steps.

9. **Post-deployment verification** — Verify the deployment:
   // turbo
   - Health check endpoint responds
   - Key pages load correctly
   - API endpoints return expected responses
   - SSL certificate valid (if HTTPS)

10. **Report** — Final deployment summary:
    ```markdown
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✅ DEPLOYMENT COMPLETE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Target:     [Docker / Cloud / VPS]
    URL:        [deployment URL]
    Status:     ✅ Healthy
    Build Time: [X seconds]
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ```

## When to Use
- Deploying to production, staging, or any environment
- Creating Docker images for distribution
- Setting up server configuration (Nginx, PM2, systemd)
- Building production bundles

## When to Skip
- Local development (use `npm run dev`)
- Prototyping or sandbox mode
