---
description: Ask anything about the codebase, application, brainstorm ideas, or research topics — get detailed, well-sourced answers with internet research.
---

# Context Ask — Intelligent Q&A & Research Agent

## Purpose
This workflow enables the user to **ask any question** about their codebase, application architecture, technology choices, brainstorming, debugging, best practices, or any development topic. The agent provides **detailed, comprehensive, and well-sourced answers** — leveraging both project context and internet research.

---

## Activation
The user triggers this workflow by:
- Using `/context-ask` followed by their question
- Asking any freeform question about the project or technology

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 1: Understand the Question

### Step 1.1 — Classify the Question Type

Determine the category of the user's question:

| Category | Description | Example |
|----------|-------------|---------|
| **Codebase** | About existing project code, structure, logic | "How does the authentication flow work in this project?" |
| **Architecture** | About design patterns, system design | "Should we use microservices or a monolith?" |
| **Debugging** | About errors, bugs, unexpected behavior | "Why does the /api/users endpoint return 500?" |
| **How-To** | How to implement something | "How do I add WebSocket to this project?" |
| **Brainstorm** | Exploring ideas, solution design | "What features could be added to improve UX?" |
| **Technology** | About specific tools, libraries, frameworks | "What's the difference between Redis and Memcached for caching?" |
| **Best Practice** | About industry standards, patterns | "What's the best practice for handling file uploads?" |
| **Performance** | About optimization, speed, scaling | "How can I optimize this slow query?" |
| **Security** | About vulnerabilities, hardening | "Is our auth implementation secure?" |
| **DevOps** | About deployment, CI/CD, infrastructure | "How do I set up zero-downtime deployment?" |
| **General** | Any other development question | Anything else |

### Step 1.2 — Assess Clarity

Before answering, evaluate:

1. **Is the question clear enough?**
   - If YES → Proceed to Phase 2
   - If NO → Ask clarifying questions (see Step 1.3)

2. **Does it require project context?**
   - If YES → Must read context files first (Phase 2)
   - If NO → Can answer directly with research (Phase 3)

3. **Does it require internet research?**
   - If YES → Include web research (Phase 3)
   - If NO → Answer from knowledge + project context

### Step 1.3 — Ask Clarifying Questions (When Needed)

If the question is **ambiguous, too broad, or missing critical details**, ask the user for clarification BEFORE answering. Frame clarifying questions specifically:

```
❓ Clarification Needed

I want to give you the most accurate answer. Could you clarify:

1. [Specific question about scope]
2. [Specific question about context]
3. [Specific question about expected outcome]

Or if you'd like me to answer broadly, I can cover all possible scenarios.
```

**Rules for asking clarification:**
- Maximum 3 clarifying questions per ask
- Questions must be specific, not generic
- Always offer the option to answer broadly
- Never ask clarifications for simple/obvious questions
- If 80%+ confident about intent, answer and note assumptions

---

## Phase 2: Gather Project Context

### Step 2.1 — Read Context Documentation
// turbo
If the question relates to the project, read the relevant context files:

```
Priority reading order:
1. .agent/context/CONTEXT_INDEX.md          ← Always first
2. Based on question category:
   - Codebase/Architecture → ARCHITECTURE.md
   - Database questions    → DATABASE_SCHEMA.md
   - API questions         → API_REFERENCE.md
   - Dependency questions  → DEPENDENCIES.md
   - Setup/Config         → DEVELOPMENT_GUIDE.md
   - Feature/Domain       → BUSINESS_DOMAINS.md
   - General overview     → PROJECT_OVERVIEW.md
```

If `.agent/context/` does not exist, inform the user:
```
⚠️ Project context has not been initialized yet.
I recommend running /context-init first for the most accurate answers.
I'll answer based on direct code analysis instead.
```

### Step 2.2 — Analyze Relevant Source Code
// turbo
If the question is about specific code, read the relevant files:

1. **Identify relevant files** using:
   ```bash
   # Search for related code
   grep -rn "<keyword>" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.go" --include="*.java" --include="*.cs" --include="*.dart" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/dist/*' | head -30
   ```

2. **Read the files** thoroughly — understand the full context, not just the matching lines

3. **Trace the code flow** — follow imports, function calls, and data flow to build complete understanding

### Step 2.3 — Check Related Skills & Rules
// turbo
If the question involves a technology covered by a skill or rule:

1. **MANDATORY:** Read `.agent/rules/deep-thinking.md` — apply anti-hallucination protocol
2. Check `.agent/skills/` for relevant technology skill
3. Check `.agent/rules/` for applicable rules
4. Reference these in the answer to ensure advice aligns with project standards

**Anti-hallucination mandate:** Before answering, verify:
- Do NOT invent API methods, file paths, or configurations that may not exist
- If unsure, state uncertainty explicitly and suggest verification steps
- Cross-reference your answer with actual project code when applicable

---

## Phase 3: Internet Research (When Needed)

### Step 3.1 — Determine If Research Is Needed

Internet research is REQUIRED when:
- Question involves latest versions, updates, or releases
- Question requires comparing technologies
- Question asks about best practices that evolve over time
- User explicitly asks for external sources
- Question involves security vulnerabilities or advisories
- Answer confidence is below 90%

### Step 3.2 — Conduct Research

When searching the web:

1. **Use specific, targeted queries** — not vague searches
2. **Prioritize credible sources:**

| Priority | Source Type | Examples |
|----------|-----------|---------|
| ⭐⭐⭐⭐⭐ | Official Documentation | docs.laravel.com, react.dev, nodejs.org |
| ⭐⭐⭐⭐ | Official GitHub Repos | github.com/laravel, github.com/vercel |
| ⭐⭐⭐⭐ | RFC / Standards | RFC documents, W3C specs, OWASP |
| ⭐⭐⭐ | Reputable Tech Blogs | web.dev, engineering blogs (Netflix, Uber, Meta) |
| ⭐⭐⭐ | Stack Overflow | High-voted answers (50+ votes) |
| ⭐⭐ | Tutorial Sites | DigitalOcean, Baeldung, Real Python |
| ⭐ | Community Blogs | Dev.to, Medium (verify independently) |

3. **Cross-reference** — never rely on a single source
4. **Note the date** — check if information is current
5. **Verify against official docs** — community content may be outdated

### Step 3.3 — Read & Synthesize Sources
For each source found:

1. Read the content using `read_url_content`
2. Extract relevant information
3. Note the URL for citation
4. Cross-reference with other sources
5. Identify conflicts between sources and resolve them

---

## Phase 4: Compose the Answer

### Step 4.1 — Answer Structure

EVERY answer must follow this structure:

```markdown
## 📋 Answer: [Concise Title]

### Context
[Why this question matters, what problem it solves]

### Detailed Answer
[Comprehensive, well-organized answer with sections as needed]

### Code Examples (if applicable)
[Working code examples with comments explaining each part]

### Project-Specific Notes (if applicable)
[How this applies to the user's specific project based on context]

### Trade-offs & Considerations
[Pros/cons, edge cases, things to watch out for]

### Sources & References
- 📖 [Source Name](URL) — [What was referenced]
- 📖 [Source Name](URL) — [What was referenced]

### Related Topics
- [Related question 1 the user might want to explore]
- [Related question 2 the user might want to explore]
```

### Step 4.2 — Answer Quality Rules

**MANDATORY for every answer:**

1. **Be thorough** — Cover ALL aspects of the question. If the answer has multiple angles, cover each one.

2. **Be specific** — Use concrete examples, exact code, specific numbers. Never give vague advice.

3. **Be accurate** — If unsure, say so explicitly. Never fabricate information.

4. **Be structured** — Use headers, lists, tables, code blocks for readability.

5. **Be practical** — Include working code examples whenever possible.

6. **Be contextual** — Reference the user's specific project when applicable.

7. **Be current** — Ensure information is up-to-date. Note if something is version-specific.

8. **Cite sources** — Always provide URLs for external information.

9. **Show trade-offs** — Never present one option as the only solution. Show alternatives with pros/cons.

10. **Anticipate follow-ups** — Address likely follow-up questions proactively.

### Step 4.3 — Answer Depth Guidelines

| Question Complexity | Expected Answer Length | Details |
|--------------------|-----------------------|---------|
| Simple factual | 5-15 lines | Direct answer + brief explanation |
| How-to | 20-50 lines | Step-by-step + code example |
| Architecture/Design | 50-100 lines | Analysis + diagrams + trade-offs |
| Brainstorming | 30-80 lines | Multiple options + pros/cons |
| Deep debugging | 30-100 lines | Root cause + fix + prevention |
| Technology comparison | 40-80 lines | Matrix + recommendations |
| Security review | 50-100 lines | Vulnerabilities + fixes + hardening |

### Step 4.4 — Code Example Standards

When providing code examples:

```
✅ DO:
- Use the same language/framework as the user's project
- Include imports and context
- Add inline comments explaining WHY, not just what
- Show both the problem and the solution
- Use realistic variable names and data
- Follow the project's existing coding style

❌ DON'T:
- Give pseudo-code when real code is possible
- Skip error handling in examples
- Use foo/bar/baz placeholder names
- Provide incomplete snippets without context
- Ignore the project's existing patterns
```

---

## Phase 5: Post-Answer Actions

### Step 5.1 — Offer Next Steps

After every answer, offer actionable next steps:

```markdown
### 🚀 Next Steps
1. [Concrete action the user can take]
2. [Another option or deeper dive]
3. [Related workflow to run, e.g., /context-init]
```

### Step 5.2 — Offer to Implement

If the answer involves code changes, offer:

```markdown
Would you like me to:
1. ✏️ Implement this change in the codebase?
2. 📝 Create a detailed implementation plan first?
3. 🔍 Analyze the current code further before making changes?
```

### Step 5.3 — Log Important Discoveries

If the research uncovered important information that should be preserved:
- Update relevant `.agent/context/` files
- Note critical findings that could affect future development
- Flag security issues for immediate attention

---

## Special Modes

### Brainstorming Mode
When the user is brainstorming, switch to exploration mode:

```
🧠 BRAINSTORM MODE

For brainstorming, I will:
1. Generate multiple creative solutions (minimum 3 options)
2. For each option, provide:
   - Brief description
   - Key advantages
   - Potential challenges
   - Rough implementation effort (hours/days)
   - Compatibility with current project
3. Rank by feasibility and impact
4. Recommend a starting point
5. Ask which direction interests you most
```

### Comparison Mode
When comparing technologies or approaches:

```
⚖️ COMPARISON MODE

| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| Performance | ... | ... | ... |
| Complexity | ... | ... | ... |
| Scalability | ... | ... | ... |
| Community | ... | ... | ... |
| Learning Curve | ... | ... | ... |
| Cost | ... | ... | ... |
| Security | ... | ... | ... |

🏆 Recommendation: [Option] because [reasoning]
```

### Debug Mode
When debugging an issue:

```
🐛 DEBUG MODE

1. Reproduce: [Understand the exact error/behavior]
2. Isolate: [Narrow down to the specific component]
3. Trace: [Follow the code flow step by step]
4. Root Cause: [Identify why it's happening]
5. Fix: [Provide the solution with code]
6. Prevent: [How to prevent this in the future]
7. Test: [How to verify the fix works]
```

### Security Audit Mode
When reviewing security:

```
🔒 SECURITY MODE

1. Threat Model: [What could go wrong?]
2. Vulnerability Scan: [Check for OWASP Top 10]
3. Code Review: [Line-by-line security analysis]
4. Risk Rating: [Critical / High / Medium / Low]
5. Remediation: [Step-by-step fix]
6. Hardening: [Additional security measures]
```

---

## Error Handling

### When Context Files Don't Exist
```
The project context hasn't been initialized. I'll analyze the code directly,
but for more accurate answers, consider running /context-init first.
```

### When User's Question Is Out of Scope
```
This question is outside the scope of the current project. However,
I can provide a general answer based on industry best practices and research.
```

### When Internet Research Fails
```
I wasn't able to find reliable sources for this specific topic.
Here's what I know based on my training, but please verify:
[answer with caveat]
```

### When Answer Confidence Is Low
```
⚠️ Confidence Level: Medium

I'm not 100% certain about this answer. Here's what I believe to be correct:
[answer]

I recommend verifying with:
- [Official documentation link]
- [Alternative source]
```
