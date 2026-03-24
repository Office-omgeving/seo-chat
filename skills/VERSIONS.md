# SEO & GEO Skills Library — Versions

Current versions of all skills. Agents can fetch this file from `https://raw.githubusercontent.com/aaron-he-zhu/seo-geo-claude-skills/main/VERSIONS.md` once per session to check for updates.

**Versioning**: Skill versions (`metadata.version` in SKILL.md) track skill content changes independently. Plugin version (in `plugin.json`) tracks manifest and infrastructure changes.

## Skills

| Skill | Category | Version | Last Updated |
|-------|----------|---------|--------------|
| keyword-research | research | 3.0.0 | 2026-03-04 |
| competitor-analysis | research | 3.0.0 | 2026-03-04 |
| serp-analysis | research | 3.0.0 | 2026-03-04 |
| content-gap-analysis | research | 3.0.0 | 2026-03-04 |
| seo-content-writer | build | 3.0.0 | 2026-03-04 |
| geo-content-optimizer | build | 3.0.0 | 2026-03-04 |
| meta-tags-optimizer | build | 3.0.0 | 2026-03-04 |
| schema-markup-generator | build | 3.0.0 | 2026-03-04 |
| on-page-seo-auditor | optimize | 3.0.0 | 2026-03-04 |
| technical-seo-checker | optimize | 3.0.0 | 2026-03-04 |
| internal-linking-optimizer | optimize | 3.0.0 | 2026-03-04 |
| content-refresher | optimize | 3.0.0 | 2026-03-04 |
| rank-tracker | monitor | 3.0.0 | 2026-03-04 |
| backlink-analyzer | monitor | 3.0.0 | 2026-03-04 |
| performance-reporter | monitor | 3.0.0 | 2026-03-04 |
| alert-manager | monitor | 3.0.0 | 2026-03-04 |
| content-quality-auditor | cross-cutting | 3.0.0 | 2026-03-04 |
| domain-authority-auditor | cross-cutting | 3.0.0 | 2026-03-04 |
| entity-optimizer | cross-cutting | 3.0.0 | 2026-03-04 |
| memory-management | cross-cutting | 3.0.0 | 2026-03-04 |

## Changelog

### v3.0.0 (2026-03-04)

Consolidates all post-2.0.0 changes into a single major release aligned with plugin-dev, skill-creator, and financial-services-plugins standards.

**Plugin manifest (plugin-dev spec)**:
- Added `schemaVersion: "1.0.0"` and `id` fields
- Added `description` to all 9 commands and 20 skills in plugin.json and marketplace.json
- Restructured `hooks` from object to array format `[{event, path}]`
- Restructured `mcpServers` from object to array format `[{id, path}]`
- Added `displayName`, `capabilities`, `metadata` blocks
- Added typed `parameters` to all 9 command files

**Skill format (skill-creator spec)**:
- Added top-level `version` field to all 20 SKILL.md frontmatters
- Added `compatibility` field to all 20 skills
- Added `allowed-tools: WebFetch` to 5 skills with live URL fetching
- Added `allowed-tools: ["WebFetch"]` to 3 commands (audit-page, check-technical, generate-schema)
- Trimmed 7 SKILL.md files to ≤350 lines (deduplicated tags, condensed verbose sections)

**Infrastructure (financial-services-plugins patterns)**:
- Added `CLAUDE.md` for Claude Code auto-loading context
- Added `hooks/hooks.json` scaffold
- Added `scripts/validate-skill.sh` CLI validation tool
- Added disclaimer section to README.md
- Moved `marketplace.json` from `.claude-plugin/` to repo root
- Extracted reference data from 5 oversized skills into `references/` subdirectories

**Fixes**:
- Fixed `marketplace.json` name mismatch
- Fixed step numbering bug in `geo-content-optimizer`
- Updated CONTRIBUTING.md with 5-file sync requirement

### v2.0.0 (2026-02-08)
- CORE-EEAT content quality benchmark (80 items, 8 dimensions, veto system)
- CITE domain authority rating (40 items, 4 dimensions, veto system)
- Content-type weighted scoring and domain-type weighted scoring
- Entity optimizer with Knowledge Graph + Wikidata + AI resolution
- Memory management with two-layer hot/cold storage
- Tool-agnostic ~~placeholder connector system with progressive enhancement tiers
- 9 one-shot commands (`/seo:audit-page`, `/seo:audit-domain`, etc.)
- Inter-skill handoff protocol with score passthrough
- skills.sh marketplace and Claude Code plugin distribution

### v1.0.0 (2026-01-28)
- 20 skills across 5 categories (research, build, optimize, monitor, cross-cutting)
- Basic SEO and GEO content optimization workflows
