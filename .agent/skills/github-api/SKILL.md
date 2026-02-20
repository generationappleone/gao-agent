---
name: GitHub API
description: Skill for GitHub API automation — covering REST API, GraphQL API, Octokit SDK, GitHub Actions, webhooks, repository management, issues, PRs, and GitHub Apps.
---

# GitHub API Skill

## Overview
GitHub API provides REST and GraphQL interfaces for repository management, issue tracking, pull requests, Actions, and webhooks. Octokit is the official SDK for JavaScript/TypeScript. Use for CI/CD automation, bot development, and workflow integration.

**References**:
- [GitHub REST API](https://docs.github.com/en/rest)
- [Octokit.js](https://github.com/octokit/octokit.js)

---

## Octokit Setup

```typescript
import { Octokit } from '@octokit/rest';

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

// List repos
const { data: repos } = await octokit.repos.listForAuthenticatedUser({ per_page: 100, sort: 'updated' });

// Create issue
await octokit.issues.create({ owner: 'myorg', repo: 'myapp', title: 'Bug: Login fails', body: 'Steps to reproduce...', labels: ['bug'] });

// Create PR
await octokit.pulls.create({ owner: 'myorg', repo: 'myapp', title: 'feat: add user profile', head: 'feat/user-profile', base: 'main', body: 'Adds user profile page' });

// Get PR reviews
const { data: reviews } = await octokit.pulls.listReviews({ owner: 'myorg', repo: 'myapp', pull_number: 42 });
```

---

## Webhook Handler

```typescript
import { Webhooks. } from '@octokit/webhooks';

const webhooks = new Webhooks({ secret: process.env.GITHUB_WEBHOOK_SECRET! });

webhooks.on('pull_request.opened', async ({ payload }) => {
  const { pull_request, repository } = payload;
  await notifySlack(`New PR: ${pull_request.title} in ${repository.full_name}`);
});

webhooks.on('push', async ({ payload }) => {
  if (payload.ref === 'refs/heads/main') await triggerDeploy(payload.repository.name);
});

// Express integration
app.post('/api/webhooks/github', async (req, res) => {
  await webhooks.verifyAndReceive({ id: req.headers['x-github-delivery'] as string, name: req.headers['x-github-event'] as string, signature: req.headers['x-hub-signature-256'] as string, payload: JSON.stringify(req.body) });
  res.json({ ok: true });
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Octokit** | Official SDK for REST/GraphQL |
| **Authentication** | Personal token or GitHub App |
| **Webhooks** | Verify signature with secret |
| **Rate limiting** | Respect 5000 req/hr limit |
| **GraphQL** | Use for complex queries |
| **Actions** | CI/CD workflows in .github/workflows |
| **Pagination** | Use per_page and page params |
| **GitHub Apps** | Scoped permissions per installation |
| **Branch protection** | Require reviews via API |
| **Releases** | Automate releases with tags |

---

## Rules Integration
- **SDK**: Octokit for REST/GraphQL operations
- **Webhooks**: Verified webhook handlers
- **Actions**: CI/CD workflow automation
- **Management**: Repos, issues, PRs, releases
