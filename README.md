# SEO-CHAT

Gedeelde werkrepo voor SEO- en GEO-klantanalyses. Dit project is bedoeld als vaste GitHub-bron die we in Codex Cloud kunnen openen, zodat iedereen dezelfde context, structuur en werkwijze gebruikt.

## Doel
- klantanalyses centraal bewaren in een vast GitHub-project
- Codex Cloud altijd tegen dezelfde repo laten werken
- analyses, plannen en klantanalyses reproduceerbaar maken
- scripts en bronbestanden delen zonder lokale machine-afhankelijkheid

## Structuur

```
SEO-CHAT/
│
├── prompts/                 Masterprompt en audit-frameworks
│   └── masterprompt-seo-geo.md
│
├── templates/               Klantintake en copy-paste templates voor AM's
│   ├── customer-intake.md
│   └── codex-audit-request.md
│
├── scripts/                 Python utilities
│   ├── publish_markdown_to_google_docs.py   Markdown → DOCX → Google Doc
│   ├── export_to_google_docs.py             DOCX → Google Drive
│   ├── setup_google_docs_local.py           Eenmalige lokale setup
│   ├── fetch_google_ads_keyword_data.py     Google Ads keyword volumes
│   ├── build_keyword_snapshot.py            Automatische keyword discovery
│   ├── fetch_search_console.py              Search Console data
│   ├── telegram_group_bridge.py             Telegram intake bridge
│   └── build_favorcool_client_pack.py       Klantspecifiek DOCX-voorbeeld
│
├── config/                  Gedeelde teamconfig
│   ├── google-docs.env
│   └── google-service-account.json
│
├── assets/                  Fonts en visuele assets
│   └── fonts/               Poppins (Bold, Light, Regular, SemiBold)
│
├── seo-geo-delivery/        Klantdeliverables (bronbestanden)
│   ├── <klant>-seo-audit-YYYY-MM-DD.md     Bronaudit (gedateerd)
│   ├── <klant>-seo-geo-analyse-YYYY-MM-DD.md Klantanalyse
│   ├── strategy/            Sitestructuur en IA
│   ├── page-copy/           Paginateksten (core, local, blogs)
│   ├── operations/          Playbooks, measurement, schema
│   └── presentation/        Presentatie-artefacten
│
├── skills/                  SEO & GEO Skills Library (v3.0.0)
│   ├── research/            Fase 1 — Marktonderzoek (4 skills)
│   │   ├── keyword-research/
│   │   ├── competitor-analysis/
│   │   ├── serp-analysis/
│   │   └── content-gap-analysis/
│   ├── build/               Fase 2 — Content creatie (4 skills)
│   │   ├── seo-content-writer/
│   │   ├── geo-content-optimizer/
│   │   ├── meta-tags-optimizer/
│   │   └── schema-markup-generator/
│   ├── optimize/            Fase 3 — Verbetering (4 skills)
│   │   ├── on-page-seo-auditor/
│   │   ├── technical-seo-checker/
│   │   ├── internal-linking-optimizer/
│   │   └── content-refresher/
│   ├── monitor/             Fase 4 — Tracking (4 skills)
│   │   ├── rank-tracker/
│   │   ├── backlink-analyzer/
│   │   ├── performance-reporter/
│   │   └── alert-manager/
│   ├── cross-cutting/       Doorsnijdend (4 skills)
│   │   ├── content-quality-auditor/
│   │   ├── domain-authority-auditor/
│   │   ├── entity-optimizer/
│   │   └── memory-management/
│   ├── commands/            9 one-shot commands
│   ├── references/          Kwaliteitsframeworks (CORE-EEAT, CITE)
│   ├── CONNECTORS.md        Tool placeholder mappings
│   └── VERSIONS.md          Versiebeheer skills
│
├── output/                  Gegenereerde exports (gitignored)
└── tmp/                     Tijdelijke werkbestanden (gitignored)
```

### Directories in het kort

| Directory | Doel | Bewerken? |
|-----------|------|-----------|
| `prompts/` | Masterprompt voor nieuwe audits | Ja, bij framework-wijzigingen |
| `templates/` | Intake-templates voor AM's | Ja, bij workflow-wijzigingen |
| `scripts/` | Python utilities (export, data, bridge) | Ja, houd reusable |
| `config/` | Gedeelde Google Docs config | Alleen bij teamwijzigingen |
| `assets/` | Fonts voor branded output | Alleen bij branding-updates |
| `seo-geo-delivery/` | Klantwerk (audits, analyses, copy) | Ja, per klant |
| `skills/` | SEO/GEO skills library (referentie) | Nee, read-only |
| `output/` | Gegenereerde bestanden | Nee, gitignored |
| `tmp/` | Scratch en credentials | Nee, gitignored |

## Werken Met Codex Cloud
1. Open deze repo in Codex Cloud.
2. Geef minimaal klantnaam, website, auditdatum, hoofddiensten, doelregio's, concurrenten en extra context mee.
3. Laat Codex werken vanuit `prompts/masterprompt-seo-geo.md` en binnen de conventies uit `AGENTS.md`.
4. Laat de bronanalyse eerst als Markdown opbouwen in `seo-geo-delivery/`.
5. Review daarna de audit en maak indien nodig een klantanalyse of export via de scripts.
6. Commit de bronwijzigingen terug naar GitHub.

## Standaard masterprompt
De vaste basisprompt voor nieuwe audits staat in `prompts/masterprompt-seo-geo.md`.

Aanbevolen minimuminput voor accountmanagers:
- klantnaam
- website
- auditdatum
- hoofddiensten
- doelregio's
- 2 tot 3 concurrenten
- brandkleur primair
- brandkleur accent
- extra context of commerciële aandachtspunten

Handige templates:
- `templates/customer-intake.md`
- `templates/codex-audit-request.md`

Elke nieuwe analyse moet standaard altijd deze blokken bevatten:
- GEO
- Concurrentie
- Zoekwoordpotentie en huidige score

Voor keywordvolumes en keywordideeën zonder per-klant Search Console-setup is de aanbevolen shared bron voortaan Google Ads Keyword Planner via `scripts/fetch_google_ads_keyword_data.py`.

## Accountmanager flow
Voor een zo eenvoudig mogelijke flow:
1. Vul `templates/customer-intake.md` in of gebruik `templates/codex-audit-request.md` als copy-paste prompt.
2. Geef die input in Codex.
3. Laat Codex de audit opbouwen in `seo-geo-delivery/`.
4. Laat Codex de eindversie standaard publiceren naar de ingestelde Google Docs map.
5. Gebruik de teruggegeven Google Doc-link om het klantdocument te openen.

Shortcut flow voor accountmanagers:
1. Typ enkel `SEO`.
2. Codex vraagt dan automatisch alleen deze 7 zaken:
   - klantnaam
   - website URL
   - hoofddiensten
   - doelregio's
   - 2 tot 3 concurrenten
   - brandkleur primair
   - brandkleur accent
3. Na dat antwoord werkt Codex de analyse af via de standaardflow.
4. Bij een succesvolle publicatie in Google Drive houdt Codex de eindreactie bewust kort: `Staat in de drive, succes!`

## Google Docs export
De repo ondersteunt nu ook een uploadflow naar Google Drive als native Google Doc via `scripts/export_to_google_docs.py`.
Er is ook een one-step flow via `scripts/publish_markdown_to_google_docs.py` die eerst een `.docx` maakt van een Markdown-analyse en die daarna meteen publiceert.
Voor een nieuwe machine of nieuwe Codex omgeving is er ook een lokale setupstap via `scripts/setup_google_docs_local.py`.
De gedeelde teamconfig staat in `config/google-docs.env`.

Aanpak:
1. Genereer eerst een nette `.docx` van de analyse.
2. Upload die `.docx` naar de juiste Drive-map.
3. Laat Google Drive het bestand converteren naar een Google Doc.

Installatie:
```bash
python3 -m pip install -r requirements.txt
```

Team setup per AM of per nieuwe Codex omgeving:
```bash
python3 scripts/setup_google_docs_local.py /absolute/path/to/service-account.json
```

Dit script:
- kopieert de service-account key lokaal naar `tmp/credentials/google-service-account.json`
- maakt lokaal een `.env` aan met de juiste Drive-map en credentials
- zet alles klaar zodat de publish-flow meteen werkt

Voor jullie huidige private teamrepo is daarnaast ook een gedeelde repo-config voorzien:
- `config/google-docs.env`
- `config/google-service-account.json`

Daardoor kan de standaard publish-flow werken zonder extra lokale setup, zolang de repo volledig beschikbaar is.

Benodigde configuratie:
- de standaardfolder staat al ingesteld op `1kIrKfCzU9oFgZJYSUOZxlUvSPZFUMGgf`
- gebruik ofwel een service account JSON via `GOOGLE_SERVICE_ACCOUNT_FILE`
- ofwel een OAuth desktop client JSON via `GOOGLE_OAUTH_CLIENT_SECRET_FILE`

Voorbeeld:
```bash
export GOOGLE_OAUTH_CLIENT_SECRET_FILE="/absolute/path/to/client-secret.json"
python3 scripts/export_to_google_docs.py /absolute/path/to/analyse.docx --name "klant-seo-audit-2026-03-14"
```

Als je liever met een service account werkt:
```bash
export GOOGLE_SERVICE_ACCOUNT_FILE="/absolute/path/to/service-account.json"
python3 scripts/export_to_google_docs.py /absolute/path/to/analyse.docx --name "klant-seo-audit-2026-03-14"
```

One-step publish vanuit Markdown:
```bash
export GOOGLE_OAUTH_CLIENT_SECRET_FILE="/absolute/path/to/client-secret.json"
python3 scripts/publish_markdown_to_google_docs.py /absolute/path/to/klant-seo-audit-2026-03-14.md --name "klant-seo-audit-2026-03-14"
```

## Google Search Console koppeling
Voor SEO-audits kan de repo nu ook rechtstreeks Search Console-data ophalen via `scripts/fetch_search_console.py`.

Dit is een optionele bonuslaag, geen vereiste standaardstap voor nieuwe klanten.

Belangrijk:
- gebruik een service account dat als gebruiker aan de Search Console property is toegevoegd, of OAuth met een gebruiker die al toegang heeft
- zet de property in de vorm `https://example.com/` of `sc-domain:example.com`
- voor OAuth gebruikt dit script standaard een aparte tokenfile zodat de Drive-flow en Search Console-flow elkaar niet overschrijven

Voorbeelden:
```bash
python3 scripts/fetch_search_console.py --list-properties
```

```bash
python3 scripts/fetch_search_console.py sc-domain:tectura-groep.be --dimensions query,page --row-limit 100
```

```bash
python3 scripts/fetch_search_console.py sc-domain:tectura-groep.be \
  --start-date 2026-02-19 \
  --end-date 2026-03-18 \
  --dimensions query \
  --query-contains dak \
  --output output/search-console/tectura-queries.csv
```

## Google Ads Keyword Planner koppeling
Voor toekomstige analyses zonder per-klant propertytoegang is dit de snelste route naar bruikbare zoekvolume-data.
Je koppelt één gedeelde Google Ads-config, en gebruikt die daarna voor alle klanten.

Benodigde variabelen:
- `GOOGLE_ADS_CUSTOMER_ID`
- `GOOGLE_ADS_CONFIGURATION_FILE_PATH`

## Webapp voor intake en auditruns

Er zit nu ook een eenvoudige webapp in de repo, gebouwd bovenop dezelfde repo-context:
- backend via FastAPI in `webapp/`
- vaste modelkeuze: `gpt-5.4` via de OpenAI Responses API
- promptopbouw uit `AGENTS.md` + `prompts/masterprompt-seo-geo.md` + intake + selectieve repo-skills
- skillbundles per audit: `keyword-research`, `competitor-analysis`, `technical-seo-checker`, `geo-content-optimizer`
- frameworks standaard actief: `CORE-EEAT` en `CITE`
- bronoutput blijft een Markdown-bestand in `seo-geo-delivery/`

Start lokaal:

```bash
python3 -m pip install -r requirements.txt
python3 -m uvicorn webapp.main:app --reload
```

Open daarna:

```text
http://127.0.0.1:8000
```

Beschikbare API-routes:
- `POST /api/audits` start een auditrun
- `GET /api/audits/{id}` leest status, skillbundles, toolresultaten en Markdown-output
- `POST /api/audits/{id}/export` publiceert een afgeronde audit naar Google Docs

Belangrijk voor de webapp:
- `OPENAI_API_KEY` is verplicht
- `GOOGLE_ADS_*` is optioneel voor keyword-data
- `GOOGLE_SEARCH_CONSOLE_PROPERTY` + Google credentials is optioneel voor Search Console-data
- Google Docs-export gebruikt dezelfde bestaande scripts en configuratie als de rest van deze repo

## Supabase koppeling

De webapp kan auditruns nu ook wegschrijven naar Supabase, naast de lokale fallback in `tmp/audits/`.

Benodigde variabelen:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- optioneel `SUPABASE_AUDITS_TABLE` (default: `seo_geo_audits`)

Aanpak:
1. Open jullie Supabase SQL editor.
2. Voer [supabase/seo_geo_audits.sql](/Users/thibo.a3/Red Pepper/Projecten/SEO-CHAT/supabase/seo_geo_audits.sql) uit.
3. Zet de drie env vars in de runtime waar de webapp draait.
4. Start de app opnieuw.

Gedrag:
- zonder Supabase-config blijft de app lokaal werken
- met Supabase-config gebruikt de app `local + supabase`
- lezen gebeurt eerst uit Supabase wanneer die geconfigureerd is
- schrijven gebeurt lokaal én naar Supabase

Beveiliging:
- gebruik alleen de **service role key** op de server
- expose deze key nooit in de browser of frontend-code

Voorbeelden:
```bash
python3 scripts/fetch_google_ads_keyword_data.py \
  --mode historical \
  --preset be-nl \
  "dakrenovatie Antwerpen" \
  "dakwerken Sint-Niklaas"
```

```bash
python3 scripts/fetch_google_ads_keyword_data.py \
  --mode ideas \
  --preset be-nl \
  --seed-url https://tectura-groep.be/ \
  --seed-keywords "dakrenovatie,dakwerken,zonnepanelen" \
  --row-limit 50 \
  --output output/keyword-data/tectura-keyword-ideas.csv
```

Presets:
- `be-nl`: België + Nederlands
- `be-fr`: België + Frans
- `nl-nl`: Nederland + Nederlands
- `fr-fr`: Frankrijk + Frans

Zo kunnen we per klant:
- eerst relevante ideeën ophalen
- daarna de shortlist naar echte maandvolumes trekken
- en die data in audits of klantanalyses verwerken zonder Search Console-koppeling

## Telegram groep koppeling
Als je wil dat iemand input in een Telegram-groep kan posten en dat Codex die input daarna kan lezen, zit er nu een eenvoudige bridge in `scripts/telegram_group_bridge.py`.

Wat deze bridge doet:
- leest nieuwe berichten uit een Telegram-bot
- filtert optioneel op toegelaten groeps-id's
- schrijft elk bericht naar `tmp/telegram-inbox/messages.jsonl`
- schrijft ook een leesbare samenvatting naar `tmp/telegram-inbox/latest-message.md`

Belangrijk:
- voeg de bot toe aan de Telegram-groep
- zet via BotFather de privacy mode uit als de bot alle groepsberichten moet kunnen zien
- deze bridge maakt berichten leesbaar voor Codex in deze repo
- voor een volledig automatische reply- of auditflow is nog een doorlopend proces of webhook nodig

Config in `.env`:
```bash
TELEGRAM_BOT_TOKEN=123456:abc
TELEGRAM_ALLOWED_CHAT_IDS=-1001234567890
```

Eenmalig ophalen van nieuwe berichten:
```bash
python3 scripts/telegram_group_bridge.py --once
```

Blijven pollen:
```bash
python3 scripts/telegram_group_bridge.py
```

Daarna kan Codex bijvoorbeeld `tmp/telegram-inbox/latest-message.md` lezen en die intake verder verwerken.

## Geautomatiseerde keyword snapshot
Als je niet handmatig wil:
- relevante keywords bedenken
- volumes opzoeken
- huidige zichtbaarheid spotchecken

gebruik dan `scripts/build_keyword_snapshot.py`.

Deze flow doet automatisch:
1. seed-keywords afleiden uit website, diensten en regio's
2. keyword-ideeën ophalen via Google Ads
3. shortlist selecteren
4. echte `Avg. monthly searches` ophalen
5. huidige zichtbaarheid controleren via live SERP-check

Voorbeeld:
```bash
python3 scripts/build_keyword_snapshot.py \
  --website https://dryguard.be/ \
  --services "vochtbestrijding,opstijgend vocht,kelderinjectie" \
  --regions "Vlaanderen,Oost-Vlaanderen,West-Vlaanderen,Antwerpen" \
  --preset be-nl \
  --format markdown
```

Of rechtstreeks naar bestand:
```bash
python3 scripts/build_keyword_snapshot.py \
  --website https://dryguard.be/ \
  --services "vochtbestrijding,opstijgend vocht,kelderinjectie" \
  --regions "Vlaanderen,Oost-Vlaanderen,West-Vlaanderen,Antwerpen" \
  --preset be-nl \
  --output output/keyword-data/dryguard-keyword-snapshot.md
```

Opmerking:
- bij een service account moet de doelmap in Google Drive expliciet gedeeld zijn met het service account e-mailadres
- OAuth is meestal het eenvoudigst als dezelfde gebruiker al toegang heeft tot de map
- voor een echt dummy-proof teamflow is een service account meestal het sterkst, omdat dan niet elke gebruiker apart hoeft in te loggen
- deze repo bevat bewust een gedeelde service-account key voor deze ene Drive-flow; behandel repo-toegang dus als toegang tot die map en roteer de key als teamtoegang verandert

## Skills Library

De `skills/` directory bevat 20 professionele SEO/GEO skills en 9 one-shot commands uit [seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) (v3.0.0). Deze worden als referentiekader gebruikt tijdens audits voor diepere en nauwkeurigere analyses.

### Alle 20 skills

| Fase | Skill | Beschrijving |
|------|-------|-------------|
| Research | `keyword-research` | Keyword discovery, intent-classificatie, volumedata |
| Research | `competitor-analysis` | Gestructureerde concurrentievergelijking |
| Research | `serp-analysis` | SERP feature en ranking analyse |
| Research | `content-gap-analysis` | Ontbrekende content en kansen identificeren |
| Build | `seo-content-writer` | SEO-geoptimaliseerde content schrijven |
| Build | `geo-content-optimizer` | Content optimaliseren voor AI-citatie (ChatGPT, Perplexity) |
| Build | `meta-tags-optimizer` | Title tags, meta descriptions, OG tags |
| Build | `schema-markup-generator` | JSON-LD structured data genereren |
| Optimize | `on-page-seo-auditor` | Volledige on-page audit met CORE-EEAT scoring |
| Optimize | `technical-seo-checker` | Technische SEO health check |
| Optimize | `internal-linking-optimizer` | Interne linkstructuur optimalisatie |
| Optimize | `content-refresher` | Bestaande content vernieuwen en verbeteren |
| Monitor | `rank-tracker` | Positie-tracking en rapportage |
| Monitor | `backlink-analyzer` | Backlinkprofiel analyse |
| Monitor | `performance-reporter` | SEO/GEO performance rapportage |
| Monitor | `alert-manager` | Monitoring en alertconfiguratie |
| Cross-cutting | `content-quality-auditor` | 80-item CORE-EEAT content audit |
| Cross-cutting | `domain-authority-auditor` | 40-item CITE domeinautoriteit audit |
| Cross-cutting | `entity-optimizer` | Knowledge Graph en entiteitoptimalisatie |
| Cross-cutting | `memory-management` | Auditresultaten cachen en hergebruiken |

### One-shot commands

| Command | Wat het doet |
|---------|-------------|
| `/seo:audit-page` | On-page SEO + CORE-EEAT audit van een pagina |
| `/seo:audit-domain` | CITE domain authority audit |
| `/seo:check-technical` | Technische SEO health check |
| `/seo:write-content` | SEO + GEO geoptimaliseerde content schrijven |
| `/seo:keyword-research` | Keyword discovery en clustering |
| `/seo:optimize-meta` | Title tags en meta descriptions optimaliseren |
| `/seo:generate-schema` | JSON-LD structured data genereren |
| `/seo:report` | Performance rapport genereren |
| `/seo:setup-alert` | Monitoring alert instellen |

### Kwaliteitsframeworks

- **CORE-EEAT** (80 items, 8 dimensies): content kwaliteitsscore. Bestand: `skills/references/core-eeat-benchmark.md`
- **CITE** (40 items, 4 dimensies): domeinautoriteit score. Bestand: `skills/references/cite-domain-rating.md`

### MCP-integraties

Via `.mcp.json` zijn optioneel verbindingen beschikbaar met Ahrefs, SimilarWeb, HubSpot, Amplitude, Notion en Slack.

## Bestandsconventies
- Gebruik bestandsnamen met klantprefix en datum in ISO-formaat.
- Bewaar de bronanalyse in Markdown; binaries zijn afgeleid en kunnen opnieuw gegenereerd worden.
- Laat bestaande klantbestanden staan tenzij er expliciet om vervanging gevraagd wordt.

Voorbeelden:
- `seo-geo-delivery/favorcool-seo-audit-2026-03-14.md`
- `seo-geo-delivery/favorcool-seo-geo-analyse-2026-03-14.md`
- `seo-geo-delivery/evm-dakwerken-seo-geo-plan.md`

## Lokale GitHub Setup
```bash
git init -b main
git add .
git commit -m "Initial commit"
git remote add origin <github-repo-url>
git push -u origin main
```

Als `gh` is ingelogd, kan de repo ook rechtstreeks met GitHub CLI worden aangemaakt.
