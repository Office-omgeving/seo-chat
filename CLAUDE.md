# SEO-CHAT — Claude Code Context

Dit is de gedeelde repo voor SEO- en GEO-klantanalyses van Red Pepper. Alle regels in `AGENTS.md` blijven leidend voor workflow, naamgeving, exports en het 3-regelige antwoordformaat.

## Repo-structuur

```
SEO-CHAT/
├── prompts/                 Masterprompt en audit-frameworks
├── templates/               Klantintake en audit-request templates
├── scripts/                 Python utilities (export, keyword data, Search Console)
├── config/                  Google Docs config en service account
├── assets/                  Fonts (Poppins) voor branded exports
├── seo-geo-delivery/        Klantdeliverables (audits, klantanalyses, strategie)
├── skills/                  SEO & GEO Skills Library (v3.0.0) — zie onder
│   ├── research/            Fase 1: marktonderzoek (4 skills)
│   ├── build/               Fase 2: content creatie (4 skills)
│   ├── optimize/            Fase 3: verbetering (4 skills)
│   ├── monitor/             Fase 4: tracking (4 skills)
│   ├── cross-cutting/       Doorsnijdend: kwaliteit, autoriteit, entiteiten (4 skills)
│   ├── commands/            9 one-shot commands (/seo:...)
│   └── references/          CORE-EEAT en CITE kwaliteitsframeworks
├── output/                  Gegenereerde exports (gitignored)
└── tmp/                     Scratch en tijdelijke bestanden (gitignored)
```

## Bestaande workflow (ongewijzigd)

- **Masterprompt**: `prompts/masterprompt-seo-geo.md`
- **Klantintake**: `templates/customer-intake.md`, `templates/codex-audit-request.md`
- **Google Docs export**: `scripts/publish_markdown_to_google_docs.py` (Markdown → DOCX → Google Doc)
- **Keyword data**: `scripts/fetch_google_ads_keyword_data.py`, `scripts/build_keyword_snapshot.py`
- **Search Console**: `scripts/fetch_search_console.py`
- **Shortcut "SEO"**: vraag 7 velden → audit → publiceer → `Staat in de drive, succes!`

## Skills Library (v3.0.0)

20 skills en 9 commands uit [seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) voor diepere, nauwkeurigere analyses.

### Skills per fase

| Fase | Skills | Directory |
|------|--------|-----------|
| **Research** | `keyword-research`, `competitor-analysis`, `serp-analysis`, `content-gap-analysis` | `skills/research/` |
| **Build** | `seo-content-writer`, `geo-content-optimizer`, `meta-tags-optimizer`, `schema-markup-generator` | `skills/build/` |
| **Optimize** | `on-page-seo-auditor`, `technical-seo-checker`, `internal-linking-optimizer`, `content-refresher` | `skills/optimize/` |
| **Monitor** | `rank-tracker`, `backlink-analyzer`, `performance-reporter`, `alert-manager` | `skills/monitor/` |
| **Cross-cutting** | `content-quality-auditor`, `domain-authority-auditor`, `entity-optimizer`, `memory-management` | `skills/cross-cutting/` |

### One-shot commands

```
/seo:audit-page      — On-page SEO + CORE-EEAT audit
/seo:audit-domain    — CITE domain authority audit
/seo:check-technical — Technical SEO health check
/seo:write-content   — SEO + GEO optimized content
/seo:keyword-research — Keyword discovery and clustering
/seo:optimize-meta   — Title tags en meta descriptions
/seo:generate-schema — JSON-LD structured data
/seo:report          — Performance report
/seo:setup-alert     — Monitoring alert configuratie
```

### Kwaliteitsframeworks

- **CORE-EEAT** (`skills/references/core-eeat-benchmark.md`): 80-item content quality framework (8 dimensies). GEO Score = CORE avg; SEO Score = EEAT avg. Veto items: T04, C01, R10.
- **CITE** (`skills/references/cite-domain-rating.md`): 40-item domain authority framework (4 dimensies). Veto items: T03, T05, T09.

### Hoe skills te gebruiken tijdens audits

Bij het uitvoeren van een klantaudit via de masterprompt, gebruik de relevante skills als referentiekader:
- **Keyword research**: raadpleeg `skills/research/keyword-research/SKILL.md` en bijbehorende `references/` voor intent-taxonomie en prioriteringsframework
- **Concurrentieanalyse**: raadpleeg `skills/research/competitor-analysis/SKILL.md` voor gestructureerde vergelijking
- **Technische SEO**: raadpleeg `skills/optimize/technical-seo-checker/SKILL.md` voor complete checklist
- **GEO-optimalisatie**: raadpleeg `skills/build/geo-content-optimizer/SKILL.md` voor AI-citatie-optimalisatie
- **Content kwaliteit**: gebruik `skills/references/core-eeat-benchmark.md` als scoringskader
- **Schema markup**: raadpleeg `skills/build/schema-markup-generator/SKILL.md` voor JSON-LD templates

### Tool connector pattern

Skills gebruiken `~~category` placeholders (zie `skills/CONNECTORS.md`). Onze repo heeft echte scripts die deze vervangen:
- `~~keyword tool` → `scripts/fetch_google_ads_keyword_data.py`
- `~~search console` → `scripts/fetch_search_console.py`
- `~~analytics` → Google Search Console data via scripts

### Inter-skill handoff

Bij doorverwijzing tussen skills, geef mee: target keyword, content type, CORE-EEAT scores (bijv. `C:75 O:60 R:80 E:45`), CITE scores, priority item IDs, content URL.

## Prioriteit bij conflict

Als de skills library en de bestaande AGENTS.md/masterprompt conflicteren:
1. **AGENTS.md** wint altijd voor workflow, naamgeving, exports en antwoordformaat
2. **Skills library** wint voor inhoudelijke diepte, scoringsframeworks en technische checklists
3. **Google Docs export flow** wijzigt nooit — altijd via bestaande scripts

> Volledige agent richtlijnen: [AGENTS.md](./AGENTS.md) · Skills documentatie: [skills/CONNECTORS.md](./skills/CONNECTORS.md) · Versies: [skills/VERSIONS.md](./skills/VERSIONS.md)
