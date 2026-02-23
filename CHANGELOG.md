# Changelog

All notable changes to the GAO Agent project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-02-23

### Added
- Architecture Decision Records (ADR) — 3 formal ADRs in `docs/adr/`
- CHANGELOG.md — version history tracking
- Versioning system — version field in AGENTS.md header
- Memory auto-pruning rule in `rules/memory-pruning.md`
- MCP health check workflow in `workflows/context-mcp-check.md`
- ServiceNow `SKILL.md` — previously missing skill file
- 181 missing skills registered in AGENTS.md (total: 364)
- Deep Thinking rule (#13) added to AGENTS.md Mandatory Rules section

### Changed
- AGENTS.md — updated Available Skills count from 183 to 364
- AGENTS.md — added 5 missing rules (#13–#17) to Mandatory Rules section
- README.md — corrected skill count from 360 to 364 across all references
- All Indonesian language remnants translated to English

### Fixed
- AGENTS.md skill registry gap — 49.7% of skills were not registered
- README.md statistics inaccuracy — skill count was understated by 4
- Missing `SKILL.md` in `servicenow/` directory

## [1.0.0] — 2026-02-19

### Added
- Initial GAO Agent framework release
- 17 mandatory rules covering security, architecture, testing, and compliance
- 18 automated workflows for full development lifecycle
- 360 skill directories covering languages, frameworks, databases, cloud, security, and more
- Self-learning memory system (ERROR_LOG.md + LEARNED_KNOWLEDGE.md)
- Hybrid architecture combining GSD state management with Super Compound skill library
- AGENTS.md master configuration file
- README.md comprehensive project documentation
- Pre-task protocol with context-first approach
- Deep thinking and anti-hallucination protocol
- Verification gate for quality assurance

### Security
- ISO 27001:2022 compliance rules
- NIST CSF 2.0 framework integration
- CIS Controls v8 implementation
- UU PDP (Indonesia Personal Data Protection) compliance
- OWASP Top 10 coverage in security audit workflow

[1.1.0]: https://github.com/generationappleone/gao-agent/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/generationappleone/gao-agent/releases/tag/v1.0.0
