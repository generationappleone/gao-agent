---
name: GitHub API
description: Skill for GitHub API automation — covering REST API, GraphQL API, Octokit SDK, GitHub Actions, webhooks, repository management, issues, PRs, and GitHub Apps.
---

# GitHub API Skill

## Overview
GitHub provides REST and GraphQL APIs for automating repository management, CI/CD, and collaboration workflows.

**Reference**: [GitHub API Documentation](https://docs.github.com/en/rest)

## Setup (Octokit)
```typescript
import { Octokit } from "@octokit/rest";
const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
```

## REST API
```typescript
// List repos
const { data: repos } = await octokit.repos.listForAuthenticatedUser({ sort: "updated", per_page: 30 });

// Create issue
await octokit.issues.create({
  owner: "user", repo: "my-repo",
  title: "Bug: Login not working",
  body: "Steps to reproduce:\n1. ...",
  labels: ["bug", "priority:high"],
  assignees: ["developer1"],
});

// Create PR
await octokit.pulls.create({
  owner: "user", repo: "my-repo",
  title: "feat: add user authentication",
  head: "feature/auth", base: "main",
  body: "## Changes\n- Added JWT auth\n- Added login/register endpoints",
});

// Get file content
const { data } = await octokit.repos.getContent({ owner: "user", repo: "my-repo", path: "README.md" });

// Create/update file
await octokit.repos.createOrUpdateFileContents({
  owner: "user", repo: "my-repo", path: "config.json",
  message: "chore: update config",
  content: Buffer.from(JSON.stringify(config)).toString("base64"),
  sha: existingFile.sha, // required for update
});

// Create release
await octokit.repos.createRelease({
  owner: "user", repo: "my-repo",
  tag_name: "v1.0.0", name: "Release v1.0.0",
  body: "## What's Changed\n- Feature A\n- Bug fix B",
  draft: false, prerelease: false,
});
```

## Webhooks
```typescript
import { createNodeMiddleware, Webhooks } from "@octokit/webhooks";

const webhooks = new Webhooks({ secret: process.env.WEBHOOK_SECRET! });

webhooks.on("push", ({ payload }) => {
  console.log(`Push to ${payload.repository.full_name} by ${payload.pusher.name}`);
});

webhooks.on("pull_request.opened", ({ payload }) => {
  console.log(`PR opened: ${payload.pull_request.title}`);
});

webhooks.on("issues.opened", ({ payload }) => {
  console.log(`Issue: ${payload.issue.title}`);
});

app.use("/webhook", createNodeMiddleware(webhooks));
```

## GitHub Actions API
```typescript
// Trigger workflow
await octokit.actions.createWorkflowDispatch({
  owner: "user", repo: "my-repo",
  workflow_id: "deploy.yml",
  ref: "main",
  inputs: { environment: "production" },
});

// List workflow runs
const { data: runs } = await octokit.actions.listWorkflowRuns({
  owner: "user", repo: "my-repo", workflow_id: "ci.yml", status: "completed", per_page: 5,
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Fine-grained tokens** | Use fine-grained PATs with minimal scopes |
| **GitHub Apps** | Preferred over PATs for production |
| **Rate limiting** | Check `x-ratelimit-remaining` header |
| **Pagination** | Use `per_page` and `page` params |
| **Webhook secrets** | Always verify webhook signatures |
| **GraphQL for complex** | Use GraphQL API for nested data queries |
| **Conditional requests** | Use ETags to reduce API calls |
| **Error handling** | Handle 403 (rate limit), 404, 422 errors |
