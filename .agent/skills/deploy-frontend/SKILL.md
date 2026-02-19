---
name: Deploy Frontend
description: Skill for deploying frontend applications (React, Next.js, Vue, Angular) — covering Vercel, Netlify, Cloudflare Pages, Nginx, Docker, CDN, and CI/CD pipelines.
---

# Deploy Frontend Skill

## Overview
Deploy strategies for modern frontend frameworks (React, Next.js, Vue, Angular, SvelteKit). Covers static hosting, SSR deployment, containerization, and CI/CD.

---

## Deployment Options

| Platform | Best For | SSR | Free Tier | Custom Domain |
|----------|----------|-----|-----------|---------------|
| **Vercel** | Next.js, React | ✅ | ✅ Generous | ✅ |
| **Netlify** | Static, Jamstack | ✅ (Edge) | ✅ Generous | ✅ |
| **Cloudflare Pages** | Static + Workers | ✅ (Workers) | ✅ Generous | ✅ |
| **AWS S3 + CloudFront** | Static at scale | ❌ | ⚠️ Pay-per-use | ✅ |
| **Docker + Nginx** | Self-hosted, full control | ✅ | N/A | ✅ |
| **Firebase Hosting** | Google ecosystem | ✅ (Functions) | ✅ | ✅ |

---

## Vercel (Recommended for Next.js)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy (auto-detects framework)
vercel

# Deploy to production
vercel --prod

# Environment variables
vercel env add NEXT_PUBLIC_API_URL production
vercel env add DATABASE_URL production
```

### vercel.json
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "regions": ["sin1"],
  "env": {
    "NEXT_PUBLIC_API_URL": "https://api.example.com"
  },
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ]
}
```

---

## Docker + Nginx (Self-Hosted)

### Multi-stage Dockerfile (React/Vite)
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Nginx Configuration (SPA)
```nginx
server {
    listen 80;
    server_name example.com;
    root /usr/share/nginx/html;
    index index.html;

    # SPA routing — serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets (JS, CSS, images)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
    gzip_min_length 1000;
}
```

### Multi-stage Dockerfile (Next.js SSR)
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy only necessary files
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["node", "server.js"]
```

---

## CI/CD Pipeline (GitHub Actions)

```yaml
name: Deploy Frontend
on:
  push:
    branches: [main]
    paths:
      - 'frontend/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install & Build
        working-directory: frontend
        run: |
          npm ci
          npm run build
        env:
          NEXT_PUBLIC_API_URL: ${{ vars.API_URL }}
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

## Best Practices
1. **Environment variables** — `NEXT_PUBLIC_` prefix for client-side vars in Next.js
2. **CDN for static assets** — enable caching with immutable headers
3. **Security headers** — CSP, X-Frame-Options, HSTS
4. **Preview deployments** — Vercel/Netlify auto-deploy PRs for review
5. **Output standalone** — Next.js `output: 'standalone'` for Docker
6. **Gzip/Brotli** — enable compression on Nginx/CDN
