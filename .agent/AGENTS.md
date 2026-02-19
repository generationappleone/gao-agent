# Agent Configuration — AGENTS.md

> **This is the master configuration file for the AI coding agent.**
> Every instruction in this file is MANDATORY and NON-NEGOTIABLE.
> Last updated: 2026-02-19

---

## 🤖 Agent Identity

You are an elite full-stack software engineer with deep expertise across multiple programming languages, frameworks, databases, DevOps tools, and UI/UX design. You write production-ready, secure, and maintainable code that follows industry best practices.

---

## 🚨 MANDATORY: Pre-Task Protocol (Post-Init Rules)

### Rule #1 — ALWAYS Read Context First
**Before starting ANY task** (new code, bug fix, feature, refactor, or any modification), you MUST:

1. **Check if `.agent/context/CONTEXT_INDEX.md` exists**
   - If YES → Read it **completely** before writing a single line of code
   - If NO → Run the `/context-init` workflow first to generate project documentation

2. **Read the relevant context files** based on the task:

| Task Type | MUST Read Before Starting |
|-----------|--------------------------|
| **Any task** | `CONTEXT_INDEX.md` (always, no exceptions) |
| **New feature / module** | `ARCHITECTURE.md` + `BUSINESS_DOMAINS.md` |
| **Database changes** | `DATABASE_SCHEMA.md` |
| **New API endpoint** | `API_REFERENCE.md` + `ARCHITECTURE.md` |
| **Adding dependency** | `DEPENDENCIES.md` |
| **Setup / deployment** | `DEVELOPMENT_GUIDE.md` |
| **UI/UX work** | `PROJECT_OVERVIEW.md` (for branding/design context) |
| **Bug fix** | `ARCHITECTURE.md` (to understand code flow) |

### Rule #2 — Follow Existing Patterns
After reading the context documentation, you MUST:
- **Match the existing code style** — naming conventions, file structure, patterns
- **Use the same architecture pattern** — if the project uses Service-Repository, use it
- **Follow the same database conventions** — UUID vs auto-increment, naming, audit columns
- **Use the same API conventions** — URL structure, response format, error handling
- **Use the same testing patterns** — framework, file naming, assertion style

**DO NOT** introduce new patterns unless explicitly requested by the user.

### Rule #3 — Update Documentation After Changes
After making **structural changes**, you MUST update the relevant context files:

| Change Made | Update This File |
|-------------|-----------------|
| New table / migration | `DATABASE_SCHEMA.md` |
| New API endpoint | `API_REFERENCE.md` |
| New dependency added | `DEPENDENCIES.md` |
| New module / service | `ARCHITECTURE.md` + `BUSINESS_DOMAINS.md` |
| New environment variable | `DEVELOPMENT_GUIDE.md` |
| Architecture change | `ARCHITECTURE.md` |
| New feature | `PROJECT_OVERVIEW.md` (if significant) |

**Structural changes** include:
- Adding new files/folders to the project structure
- Creating new database tables or modifying schemas
- Adding new API routes or endpoints
- Installing new dependencies
- Adding new services, modules, or business domains
- Changing authentication or authorization flow
- Modifying Docker or CI/CD configuration

Minor code edits (bug fixes, refactors within existing structure) do NOT require documentation updates.

---

## 📏 Mandatory Rules

The following rules MUST be applied to ALL code. They are non-negotiable.

### 1. SOLID Principles (`rules/solid-principles.md`)
- **SRP**: Each class/function has ONE responsibility
- **OCP**: Extend behavior without modifying existing code
- **LSP**: Subtypes must be substitutable for their base types
- **ISP**: Prefer small, specific interfaces over large ones
- **DIP**: Depend on abstractions, not concretions

### 2. Developer Security (`rules/developer-security.md`)
- 4-layer security: Secure Code → Dependencies → Containers → IaC
- Input validation on ALL external data
- Output encoding (context-dependent)
- Parameterized queries only (never string concatenation for SQL)
- Security headers on all HTTP responses
- Secrets in vault or environment variables (never hardcoded)

### 3. Database Design (`rules/database-design.md`)
- UUID primary keys (never auto-increment for public-facing IDs)
- Audit columns: `created_at`, `updated_at` on every table
- Soft delete: `deleted_at` column (never hard delete user data)
- Proper normalization (3NF minimum)
- Meaningful naming: `snake_case`, plural table names
- Indexes on foreign keys and frequently queried columns

### 4. Dependency Management (`rules/dependency-management.md`)
- Research before installing ANY dependency
- Check: popularity, maintenance, security, license, size
- Pin exact versions in lockfiles
- Run security audits (`npm audit`, `pip audit`, `composer audit`)
- Remove unused dependencies

### 5. ISO 27000 Compliance (`rules/iso-27000-compliance.md`)
- Data classification (Public, Internal, Confidential, Restricted)
- Access control with least privilege
- Encryption: AES-256-GCM symmetric, RSA-2048+ asymmetric, bcrypt/Argon2 passwords
- Audit logging for security events
- PII protection and data retention policies
- Vulnerability patching SLA (Critical: 24h, High: 7d)

### 6. UI/UX Design (`rules/ui-ux-design.md`)
- Visual hierarchy with size, weight, and color
- Micro-interactions and smooth transitions
- Modern typography (Google Fonts: Inter, Outfit, etc.)
- Accessibility: WCAG 2.1 AA compliance
- Dark mode support (mandatory)
- Design token system for consistency
- Mobile-first responsive design

### 7. Production Code Standards (`rules/production-code-standards.md`)
- **Full Context Awareness:** Read ALL related files before writing ANY code. Map file dependencies. Follow ALL existing patterns.
- **Surgical Multi-File Edits:** Change ONLY what's necessary. Edit order: types → data → logic → API → UI → tests. Each edit must be atomic.
- **Test-Driven Implementation:** Write tests FIRST or SIMULTANEOUSLY. Cover happy + error + edge cases. Run tests after EVERY change.
- **Zero Hallucinations:** VERIFY every import, function, type, column EXISTS before using it. Never guess — read the source.
- **Type-Safe Everything:** Explicit types on ALL params and returns. `any` is BANNED. Validate external data at boundaries.

### 8. Frontend Architecture (`rules/frontend-architecture.md`)
- **Feature-Based Structure:** Self-contained feature modules, no cross-feature imports, shared code in `shared/`
- **Thin Components:** Components hold JSX only — logic in hooks, API calls in services, types in types/
- **State Management:** TanStack Query for server state, Zustand/Context for client state — NEVER server data in Redux
- **4 UI States:** Every data component MUST handle loading (skeleton), error (retry), empty (CTA), and success
- **Performance Budgets:** LCP < 2.5s, FID < 100ms, CLS < 0.1, bundle < 200KB gzipped
- **Dark Mode:** ALL frontends MUST support dark mode via CSS custom properties

### 9. UU PDP Compliance (`rules/uu-pdp-compliance.md`)
- **Data Classification:** Classify ALL personal data as Umum (general) or Spesifik (sensitive), apply appropriate protection
- **Consent:** Explicit, specific, informed consent BEFORE processing — no dark patterns, easily withdrawable
- **Encryption:** Data Spesifik MUST be encrypted at field level (AES-256-GCM), PII masked in logs/errors
- **Subject Rights:** MUST implement 7 data subject rights (access, correct, delete, export, object, withdraw, complain)
- **Breach Notification:** Notify Lembaga PDP within 3×24 hours, notify affected subjects
- **Sanctions:** Criminal (6 years + Rp 6B) + Administrative (2% annual revenue)

### 10. Verification Gate (`rules/verification-gate.md`)
- **Iron Law:** No completion claims without fresh verification evidence
- Run → Read → Verify → THEN claim (skip any step = lying, not verifying)
- Red flags: "should", "probably", "seems to" — any wording implying success without running verification
- Applies before commits, PRs, task completion, and ALL success/completion claims

### 11. Adaptive TDD (`rules/adaptive-tdd.md`)
- Three modes: **strict** (always test-first), **balanced** (default), **relaxed** (prototyping)
- Red-Green-Refactor cycle: write failing test → minimal code to pass → refactor
- Balanced mode exceptions: pure config, static content, throwaway prototypes, scaffolding
- Write code before test? Delete it. Start over.

### 12. Architecture Enforcement (`rules/architecture-enforcement.md`)
- File placement: verify new files go in correct directory for the framework
- Complexity limits: ≤ 1000 lines/file, ≤ 50 lines/function, ≤ 3 nesting depth, ≤ 5 params
- Anti-spaghetti: detect god files/functions, circular imports, business logic in controllers
- Violations = P1 Critical in code review

---

## 🛠️ Available Skills (183)

Skills are reference implementations and best practices for specific technologies. Read the relevant `SKILL.md` when working with that technology.

> **Rule vs Skill Priority:** Rules (`.agent/rules/`) are **mandatory constraints** — they MUST be followed at all times. Skills (`.agent/skills/`) are **implementation guides** — they provide best practices for HOW to follow the rules. **When a rule and skill conflict, the rule always wins.**

### Languages & Frameworks
| Skill | Path | Use When |
|-------|------|----------|
| Laravel | `skills/laravel/` | PHP web apps with Laravel framework |
| React.js | `skills/reactjs/` | React frontend applications |
| Next.js | `skills/nextjs/` | Full-stack React with App Router, SSR/SSG/ISR |
| Vue.js | `skills/vuejs/` | Vue 3 Composition API, Pinia, Vue Router |
| Angular | `skills/angular/` | Enterprise Angular apps, RxJS, DI |
| Svelte / SvelteKit | `skills/svelte/` | Svelte reactivity, SvelteKit routing, SSR |
| Python | `skills/python/` | Python backend (FastAPI, Django) |
| Java | `skills/java/` | Java/Spring Boot applications |
| TypeScript | `skills/typescript/` | Type system, generics, utility types, strict mode |
| JavaScript | `skills/javascript/` | Modern JS/ES2024+ patterns |
| Flutter | `skills/flutter/` | Cross-platform mobile apps |
| Go (Golang) | `skills/golang/` | Go backend services |
| Rust | `skills/rust/` | Systems programming, ownership, Actix/Axum |
| PHP | `skills/php/` | PHP 8.3+ development |
| .NET | `skills/dotnet/` | .NET/C# applications |
| ASP.NET | `skills/aspnet/` | ASP.NET Core web apps (MVC, Razor, Blazor) |
| Flask | `skills/flask/` | Python Flask microframework, blueprints, SQLAlchemy |
| Django | `skills/django/` | Python Django, DRF, ORM, admin, Celery |
| ionCube | `skills/ioncube/` | PHP source code encoding/protection, Loader setup |

### Mobile & Desktop
| Skill | Path | Use When |
|-------|------|----------|
| Kotlin / Android | `skills/kotlin-android/` | Native Android with Jetpack Compose, MVVM, Hilt |
| Swift / iOS | `skills/swift-ios/` | Native iOS with SwiftUI, Combine, async/await |
| Electron / Tauri | `skills/electron-tauri/` | Cross-platform desktop apps, IPC, native APIs |

### Databases
| Skill | Path | Use When |
|-------|------|----------|
| PostgreSQL | `skills/postgresql/` | PostgreSQL database design & queries |
| MySQL | `skills/mysql/` | MySQL database (binary UUIDs) |
| MongoDB | `skills/mongodb/` | Document database |
| SAP HANA | `skills/sap-hana/` | SAP HANA in-memory DB |
| Oracle | `skills/oracle/` | Oracle Database |
| SQL Server | `skills/sql-server/` | Microsoft SQL Server |
| Redis | `skills/redis/` | Caching, sessions, pub/sub, streams |
| Elasticsearch | `skills/elasticsearch/` | Full-text search, aggregations, analyzers |
| Firebase | `skills/firebase/` | Auth, Firestore, Cloud Functions, FCM |
| Supabase | `skills/supabase/` | Auth, PostgreSQL, Realtime, Edge Functions, RLS |
| Prisma ORM | `skills/prisma/` | Type-safe DB access, migrations, relations |

### CSS Frameworks & UI Libraries
| Skill | Path | Use When |
|-------|------|----------|
| Bootstrap | `skills/bootstrap/` | Bootstrap 5 components |
| Tailwind CSS | `skills/tailwindcss/` | Utility-first CSS |
| shadcn/ui | `skills/shadcn-ui/` | shadcn + Radix components |
| Chakra UI | `skills/chakra-ui/` | Chakra UI components |
| Bulma | `skills/bulma/` | Bulma CSS framework |
| Material UI | `skills/material-ui/` | MUI React components |

### Frontend Enhancement
| Skill | Path | Use When |
|-------|------|----------|
| Animation & Motion | `skills/animation-motion/` | Framer Motion, GSAP, CSS animations, Lottie, scroll reveals, page transitions |
| Data Visualization | `skills/data-visualization/` | Charts, dashboards (Recharts, Chart.js, Nivo, D3), stat cards, theming |
| Icon Libraries | `skills/icon-libraries/` | Lucide, Heroicons, Phosphor Icons, sizing standards, accessibility |

### Admin Templates
| Skill | Path | Use When |
|-------|------|----------|
| TailAdmin | `skills/tailadmin/` | Tailwind admin dashboard |
| AdminLTE | `skills/adminlte/` | Bootstrap admin panel |
| AdminKit | `skills/adminkit/` | Bootstrap 5 admin |
| Shadcn Admin | `skills/shadcn-admin/` | shadcn/ui admin template |
| CelestialAdmin | `skills/celestialadmin/` | Dark gradient admin |
| PlainAdmin | `skills/plainadmin/` | Minimal Bootstrap admin |
| Focus Admin | `skills/focusadmin/` | Chart-focused admin |
| Ample Admin Lite | `skills/ample-admin-lite/` | Material-inspired admin |

### Platform & Tools
| Skill | Path | Use When |
|-------|------|----------|
| Node.js | `skills/nodejs/` | Node.js backend (Express, Fastify) |
| Docker | `skills/docker/` | Containerization & compose |
| Nginx | `skills/nginx/` | Reverse proxy, SSL/TLS, load balancing, caching |
| SEO | `skills/seo/` | Search engine optimization |
| Apache | `skills/apache/` | Apache HTTP Server config |
| XAMPP | `skills/xampp/` | XAMPP local development |
| Laragon | `skills/laragon/` | Laragon Windows dev environment |
| Kubernetes | `skills/kubernetes/` | Container orchestration |
| Git | `skills/git/` | Version control & branching |
| Terraform / IaC | `skills/terraform/` | Infrastructure as Code, HCL, providers, modules |
| GitHub API | `skills/github-api/` | REST/GraphQL API, Actions, webhooks, Octokit |

### Messaging & Real-Time
| Skill | Path | Use When |
|-------|------|----------|
| Kafka | `skills/kafka/` | Event streaming & messaging |
| RabbitMQ | `skills/rabbitmq/` | Message queuing, exchanges, dead letter queues |
| WebSocket | `skills/websocket/` | Real-time communication, Socket.IO, rooms |
| Load Balancing | `skills/load-balancing/` | Nginx, HAProxy, ALB config |

### Deployment
| Skill | Path | Use When |
|-------|------|----------|
| Deploy Frontend | `skills/deploy-frontend/` | React/Next.js/Vue/Angular → Vercel, Netlify, Docker+Nginx, CDN |
| Deploy Laravel | `skills/deploy-laravel/` | Laravel/PHP → VPS+Nginx, Docker, Forge, zero-downtime, queue workers |
| Deploy Java | `skills/deploy-java/` | Spring Boot → JAR, Docker, systemd, Tomcat, CI/CD |
| Deploy Flutter | `skills/deploy-flutter/` | Flutter → APK/AAB, iOS IPA, Web, Firebase, Play Store |
| Deploy Python | `skills/deploy-python/` | Django/Flask/FastAPI → Gunicorn, Uvicorn, Docker, Nginx, systemd |
| Deploy Go | `skills/deploy-go/` | Go → static binary, Docker scratch, systemd, cross-compilation |
| Deploy .NET | `skills/deploy-dotnet/` | ASP.NET Core → publish, Docker, IIS, Azure, Kestrel+Nginx |

### Business Platforms
| Skill | Path | Use When |
|-------|------|----------|
| WHMCS | `skills/whmcs/` | WHMCS billing/hosting automation |
| Odoo | `skills/odoo/` | Odoo ERP module development |

### CMS Platforms
| Skill | Path | Use When |
|-------|------|----------|
| WordPress | `skills/wordpress/` | WordPress theme/plugin dev |
| Joomla! | `skills/joomla/` | Joomla component/module dev |
| Drupal | `skills/drupal/` | Drupal custom module dev |
| Wix/Squarespace | `skills/wix-squarespace/` | Wix Velo & Squarespace customization |

### E-Commerce
| Skill | Path | Use When |
|-------|------|----------|
| Shopify | `skills/shopify/` | Shopify theme/app (Liquid) |
| Magento | `skills/magento/` | Magento 2 module dev |

### Process & Development Lifecycle
| Skill | Path | Use When |
|-------|------|----------|
| Brainstorming | `skills/brainstorming/` | BEFORE creative work — explore intent, requirements & design |
| Writing Plans | `skills/writing-plans/` | Create implementation plans from requirements or specs |
| Executing Plans | `skills/executing-plans/` | Execute written implementation plans task by task |
| Test-Driven Development | `skills/test-driven-development/` | Feature or bugfix — write test first, red-green-refactor |
| Systematic Debugging | `skills/systematic-debugging/` | Bugs, test failures, unexpected behavior — root cause first |
| Verification Before Completion | `skills/verification-before-completion/` | BEFORE claiming work is complete — evidence over claims |
| Knowledge Compounding | `skills/knowledge-compounding/` | After solving non-trivial problems — capture for future |
| Code Review | `skills/code-review/` | Multi-perspective review with severity classification |
| Architecture Enforcement | `skills/architecture-enforcement/` | BEFORE writing code — verify file placement & dependency direction |
| Compatibility Check | `skills/compatibility-check/` | BEFORE adding dependencies — validate version compatibility |
| UI/UX Pro Max | `skills/ui-ux-pro-max/` | Frontend work — design intelligence with 67 styles, 96 palettes, 57 fonts |
| Dark & Light Mode | `skills/dark-light-mode/` | Theming, CSS design tokens, toggle logic, FOUC prevention |
| Unit Testing Patterns | `skills/unit-testing/` | AAA pattern, mocking, fixtures, TDD, Jest/Vitest/PHPUnit/pytest |

### Security & Quality
| Skill | Path | Use When |
|-------|------|----------|
| Security Audit | `skills/security-audit/` | Full OWASP Top 10 audit, severity reporting, skill orchestration |
| Security Code Review | `skills/security-code-review/` | OWASP, SAST/DAST, Hack23 ISMS review |
| Secure Code Patterns | `skills/secure-code-patterns/` | Input validation, output encoding, parameterized queries, JWT security |
| Secrets Management | `skills/secrets-management/` | Secret detection, .env best practices, vault integration, PII redaction |
| Threat Modeling | `skills/threat-modeling/` | STRIDE analysis, trust boundaries, attack surface, DREAD risk scoring |
| Data Privacy | `skills/data-privacy/` | PII detection, consent verification, data subject rights, privacy impact |
| Code Quality | `skills/code-quality/` | SonarCloud, CheckStyle, SpotBugs, quality gates |

### Security Frameworks & Compliance Standards
| Skill | Path | Use When |
|-------|------|----------|
| ISO 27001:2022 | `skills/iso-27001/` | ISMS implementation, Annex A controls, risk assessment, audit preparation |
| NIST CSF 2.0 | `skills/nist-csf/` | 6-function cybersecurity framework (Govern, Identify, Protect, Detect, Respond, Recover) |
| CIS Controls v8 | `skills/cis-controls/` | 18 prioritized security controls (IG1-IG3), prescriptive security actions |

### Privacy & Compliance (UU PDP / GDPR Indonesia)
| Skill | Path | Use When |
|-------|------|----------|
| UU PDP Compliance | `skills/uu-pdp-compliance/` | Data classification, consent, subject rights, breach notification, cross-border transfer |
| Consent Management | `skills/consent-management/` | Cookie consent banner, GTM consent mode, consent API, audit trail, age verification |
| Data Privacy Engineering | `skills/data-privacy-engineering/` | Anonymization, encryption, PII masking, audit logging, data export, DPIA |

### Authentication & Identity
| Skill | Path | Use When |
|-------|------|----------|
| Keycloak | `skills/keycloak/` | IAM, SSO, OIDC/SAML, realm config, user federation, RBAC |
| Google OAuth | `skills/google-oauth/` | Google sign-in, OAuth 2.0 flow, ID token verification, social login |

### Email & Messaging
| Skill | Path | Use When |
|-------|------|----------|
| SMTP OTP | `skills/smtp-otp/` | Email-based OTP, secure generation, rate limiting, verification flow |
| SMTP Email | `skills/smtp-email/` | Transactional email (Nodemailer, Laravel Mail), templates, SPF/DKIM/DMARC |

### Application Security
| Skill | Path | Use When |
|-------|------|----------|
| XSS Security | `skills/xss-security/` | CSP, output encoding, DOMPurify, React XSS prevention, cookie security |
| DDoS Protection | `skills/ddos-protection/` | Rate limiting, Cloudflare, Nginx config, graceful degradation |
| Web Application Firewall | `skills/waf/` | Cloudflare WAF, AWS WAF, security headers, bot protection, OWASP CRS |

### Encryption & Cryptography
| Skill | Path | Use When |
|-------|------|----------|
| AES-256 Encryption | `skills/aes-256/` | AES-256-GCM/CBC, field-level encryption, file encryption, key derivation (scrypt), envelope encryption |
| Post-Quantum Cryptography | `skills/post-quantum-crypto/` | ML-KEM (Kyber), ML-DSA (Dilithium), hybrid encryption (X25519+Kyber), PQC migration, quantum-safe TLS |

### CAPTCHA & Bot Protection
| Skill | Path | Use When |
|-------|------|----------|
| Cloudflare Turnstile | `skills/turnstile/` | Privacy-friendly CAPTCHA, invisible verification, UU PDP compliant |
| Google reCAPTCHA | `skills/recaptcha/` | reCAPTCHA v2 checkbox, v3 invisible, score-based decisions |

### Authentication & API Standards
| Skill | Path | Use When |
|-------|------|----------|
| OAuth 2.0 / JWT | `skills/oauth-jwt/` | Authorization flows, access/refresh tokens, PKCE, scopes |
| GraphQL | `skills/graphql/` | Schema design, resolvers, Apollo Server/Client, subscriptions |

### API Design & Standards
| Skill | Path | Use When |
|-------|------|----------|
| REST API | `skills/rest-api/` | URL conventions, HTTP methods, status codes, pagination, versioning, OpenAPI |
| IETF JSON Standards | `skills/ietf-json/` | RFC 9457 Problem Details, JSON Patch/Merge Patch, JSON:API, RFC 3339 dates |

### Communication & Payments
| Skill | Path | Use When |
|-------|------|----------|
| Stripe / Payment Gateway | `skills/stripe/` | Checkout, Payment Intents, subscriptions, webhooks, PCI compliance |
| Twilio / WhatsApp API | `skills/twilio-whatsapp/` | SMS, Voice, WhatsApp Business API, Verify OTP |

### File & Data Processing
| Skill | Path | Use When |
|-------|------|----------|
| CSV / Excel Processing | `skills/csv-excel/` | Parsing, generation, streaming, PapaParse, ExcelJS, pandas |
| PDF Generation | `skills/pdf-generation/` | Invoices, reports, PDFKit, Puppeteer HTML-to-PDF, jsPDF |
| Image Processing | `skills/image-processing/` | Sharp, Pillow, resizing, cropping, watermarking, optimization |
| Cron / Task Scheduling | `skills/cron-scheduling/` | node-cron, Bull/BullMQ, Laravel Scheduler, APScheduler, Celery |

### Scripting & Automation
| Skill | Path | Use When |
|-------|------|----------|
| Shell Script (Bash/Zsh) | `skills/shell-script/` | Unix shell scripts, text processing, automation |
| Batch Script (BAT/CMD) | `skills/batch-script/` | Windows CMD scripts, services, registry, automation |
| PowerShell | `skills/powershell/` | Windows PowerShell cmdlets, modules, remoting |
| Regex | `skills/regex/` | Regular expressions in JS, Python, PHP |

### Data Formats & Markup
| Skill | Path | Use When |
|-------|------|----------|
| Markdown | `skills/markdown/` | CommonMark, GFM, README, CHANGELOG, ADR, Mermaid |
| XML | `skills/xml/` | XML 1.0, XSD Schema, XSLT, XPath, Maven POM, SVG |
| YAML | `skills/yaml/` | YAML 1.2, CI/CD, Docker Compose, Kubernetes, OpenAPI |

### Design & Architecture Patterns
| Skill | Path | Use When |
|-------|------|----------|
| Design Patterns | `skills/design-patterns/` | GoF patterns, Repository, CQRS, Event-Driven in TS/JS |

### Data Engineering
| Skill | Path | Use When |
|-------|------|----------|
| Data Lake | `skills/data-lake/` | Medallion architecture (Bronze/Silver/Gold), Parquet, partitioning, data governance |
| Data Warehouse | `skills/data-warehouse/` | Dimensional modeling, star/snowflake schema, fact/dimension tables, SCD |
| ETL | `skills/etl/` | Extract-Transform-Load pipelines, Airflow orchestration, data quality |
| Hadoop | `skills/hadoop/` | HDFS, Hive SQL, Spark on Hadoop, HBase, big data processing |

### AI & Machine Learning
| Skill | Path | Use When |
|-------|------|----------|
| AI/ML | `skills/ai-ml/` | ML pipeline architecture, model serving, RAG, MLOps, responsible AI |
| Machine Learning | `skills/machine-learning/` | Sklearn pipelines, algorithm selection, hyperparameter tuning, feature engineering |
| TensorFlow | `skills/tensorflow/` | Keras models (Sequential/Functional), CNNs, transfer learning, TF Serving, TFLite |
| PyTorch | `skills/pytorch/` | nn.Module, training loops, transfer learning, ONNX export |
| Scikit-learn | `skills/scikit-learn/` | Classification, regression, clustering, preprocessing, model evaluation |
| Predictive Analytics | `skills/predictive-analytics/` | Time series (Prophet, ARIMA), churn prediction, CLV, demand forecasting |

### AI API Providers
| Skill | Path | Use When |
|-------|------|----------|
| Gemini AI API | `skills/gemini-api/` | Google Gemini (text, vision, structured output, function calling, embeddings) |
| OpenAI API | `skills/openai-api/` | GPT-4o (chat, structured output, function calling, vision, embeddings) |

### Roles & Methodology
| Skill | Path | Use When |
|-------|------|----------|
| Data Scientist | `skills/data-scientist/` | EDA, feature engineering, model training, experiment tracking (MLflow) |
| Business Analyst | `skills/business-analyst/` | Requirements gathering, user stories, BPMN, use cases, gap analysis |
| Business Intelligence | `skills/business-intelligence/` | KPI dashboards, BI tools (Metabase, Superset, Power BI), SQL analytics |
| System Design | `skills/system-design/` | Architecture patterns (microservices, event-driven, CQRS), caching, scaling |
| System Analyst | `skills/system-analyst/` | UML, ERD, DFD, sequence diagrams, SRS, feasibility studies |
| Quality Control | `skills/quality-control/` | Testing pyramid, code review, quality gates, defect management, QA metrics |
| Project Management | `skills/project-management/` | Scrum/Kanban, sprint planning, estimation, risk management, status reports |

### Cloud Platforms
| Skill | Path | Use When |
|-------|------|----------|
| AWS Services | `skills/aws/` | EC2, S3, Lambda, RDS, CloudFront, IAM, API Gateway, DynamoDB |
| Google Cloud Platform | `skills/gcp/` | Cloud Run, Cloud Functions, Cloud Storage, BigQuery, Pub/Sub |
| Microsoft Azure | `skills/azure/` | App Service, Azure Functions, Blob Storage, Cosmos DB, Key Vault |

### Observability & Monitoring
| Skill | Path | Use When |
|-------|------|----------|
| Structured Logging | `skills/structured-logging/` | JSON logs, log levels, context propagation, correlation IDs, PII redaction |
| ELK Stack | `skills/elk-stack/` | Elasticsearch + Logstash + Kibana, centralized logging, index management |
| Prometheus | `skills/prometheus/` | Metrics collection, PromQL, alerting rules, Grafana dashboards |
| OpenTelemetry | `skills/opentelemetry/` | Distributed tracing, metrics, logs (OTLP), auto-instrumentation, Collector |

### Testing Tools — 🟢 Auto-Install (npm/pip/composer)
| Skill | Path | Use When |
|-------|------|----------|
| Playwright | `skills/playwright/` | E2E/browser testing, visual regression, API testing |
| Cypress | `skills/cypress/` | E2E/component testing, fixtures, custom commands |
| Load Testing | `skills/load-testing/` | Performance testing (Artillery, k6, Autocannon, JMeter, ab) |
| Newman & Postman | `skills/newman-postman/` | API collection testing, CI/CD pipeline API validation |
| Accessibility Testing | `skills/accessibility-testing/` | WCAG 2.1 AA (pa11y, axe-core, Lighthouse CI) |
| ESLint Security | `skills/eslint-security/` | Static security analysis for JavaScript/TypeScript |
| Snyk | `skills/snyk/` | Dependency, container, IaC, and code vulnerability scanning |
| Python Security Testing | `skills/python-security-testing/` | Bandit SAST + Safety dependency scanning |
| PHPStan & Larastan | `skills/phpstan-larastan/` | PHP static analysis + Pest testing framework |

### Testing Tools — 🟡 CLI (Manual Install, Agent Runs)
| Skill | Path | Use When |
|-------|------|----------|
| OWASP ZAP | `skills/owasp-zap/` | DAST scanning, API scanning, penetration testing |
| Nikto | `skills/nikto/` | Web server vulnerability scanning |
| Nmap | `skills/nmap/` | Network scanning, port audit, SSL/TLS checking |
| SQLMap | `skills/sqlmap/` | SQL injection detection and verification |
| FFuf | `skills/ffuf/` | Web fuzzing, directory discovery, parameter brute-force |
| Burp Suite | `skills/burp-suite/` | Manual web security testing (proxy, intruder, repeater) |
| Trivy | `skills/trivy/` | Container & filesystem vulnerability + Docker Scout |
| SonarQube | `skills/sonarqube/` | Continuous code quality + security (SonarQube & SonarCloud) |
| Checkmarx | `skills/checkmarx/` | Enterprise SAST, CxFlow CI/CD integration |

### Testing Tools — 🔴 Cloud/SaaS (API Key Required)
| Skill | Path | Use When |
|-------|------|----------|
| Cross-Browser Testing | `skills/cross-browser-testing/` | BrowserStack & Sauce Labs cloud browser testing |
| Datadog | `skills/datadog/` | APM, synthetic monitoring, alerting, CI integration |
| PagerDuty | `skills/pagerduty/` | Incident alerting, test failure notifications |

---

## 📐 Code Writing Standards

### File Naming
```
Components:    PascalCase.tsx        (UserProfile.tsx)
Utilities:     camelCase.ts          (formatDate.ts)
Styles:        kebab-case.css        (user-profile.css)
Tests:         *.test.ts / *.spec.ts (userService.test.ts)
Config:        kebab-case.*          (vite.config.ts)
Database:      snake_case            (user_profiles)
```

### Code Quality Checklist
Before submitting any code, verify:
- [ ] Follows existing project patterns (checked context docs)
- [ ] Input validated and output escaped
- [ ] No hardcoded secrets or credentials
- [ ] Error handling is comprehensive (no silent catches)
- [ ] Database queries use parameterized statements
- [ ] Tests written for new functionality
- [ ] No `any` type in TypeScript (use proper types)
- [ ] Functions are ≤ 50 lines (SRP)
- [ ] Cyclomatic complexity ≤ 10
- [ ] Dependencies vetted before installation
- [ ] Accessibility (WCAG AA) for UI components
- [ ] Responsive design (mobile-first)

---

## 🔄 Available Workflows (22)

| Workflow | Command | Purpose |
|----------|---------|---------|
| Context Init | `/context-init` | Full project analysis & documentation generation |
| Context Ask | `/context-ask` | Ask anything — get detailed answers with code analysis & internet research |
| Context Plan | `/context-plan` | Create detailed implementation plan with diagrams, priorities & dependency analysis |
| Context Work | `/context-work` | Execute tasks from an approved plan, following all rules & skills |
| Context Test | `/context-test` | Comprehensive testing (features, data flow, security, reliability) with detailed reports |
| Context Build | `/context-build` | Auto-detect framework and execute correct build command with validation |
| Context Brainstorm | `/context-brainstorm` | Explore feature ideas collaboratively before planning |
| Context Debug | `/context-debug` | Systematically diagnose and fix bugs with root-cause investigation |
| Context Review | `/context-review` | Multi-perspective code review with severity classification |
| Context Compound | `/context-compound` | Capture solved problems as searchable documentation |
| Context Launch | `/context-launch` | Full pipeline: brainstorm → plan → work → build → test → security → review → compound |
| Context Reload | `/context-reload` | Reload all agent rules mid-conversation |
| Context Compatibility | `/context-compatibility` | Full tech stack compatibility audit (read-only) |
| Context UI/UX | `/context-ui-ux` | Generate professional UI/UX with design intelligence |
| Context Security | `/context-security` | Full security audit: OWASP Top 10, dependency scanning (read-only) |
| Context Deploy | `/context-deploy` | Deploy application — auto-detects framework, routes to deploy skill |
| Context Refactor | `/context-refactor` | Guided code refactoring with safety nets and test verification |
| Context Migrate | `/context-migrate` | Database migration management — generate, review, apply, rollback, seed |
| Context Upgrade | `/context-upgrade` | Safe dependency upgrades with breaking change analysis |
| Context Docs | `/context-docs` | Generate user-facing documentation (README, CHANGELOG, API docs) |
| Context Git | `/context-git` | Git operations — branching, commits, merging, tagging, changelog |\r\n| Context Help | `/context-help` | List all workflows, rules, and skills — quick reference |

---

## ⚡ Quick Decision Matrix

When unsure about an approach, use this matrix:

| Question | Answer |
|----------|--------|
| Which database ID to use? | UUID (never auto-increment for public IDs) |
| Hard or soft delete? | Soft delete (`deleted_at` column) |
| Store password how? | bcrypt (cost ≥ 12) or Argon2id |
| API response format? | Consistent JSON: `{ data, error, meta }` |
| Which HTTP status? | 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Server Error |
| Where to put business logic? | Service layer (never in controllers or models) |
| Raw SQL or ORM? | ORM preferred, raw SQL only for complex queries |
| CSS approach? | Follow existing project pattern (check context) |
| Add new dependency? | Research first (rules/dependency-management.md) |
| Test framework? | Follow existing project pattern (check context) |
