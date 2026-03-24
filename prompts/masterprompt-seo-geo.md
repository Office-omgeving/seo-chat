# Masterprompt SEO & GEO Analyse

Gebruik deze prompt als standaardbasis voor elke nieuwe klantanalyse in deze repo.

## Aan te vullen klantcontext
Voeg boven of voor deze masterprompt altijd minimaal deze klantvariabelen toe:
- klantnaam
- website
- auditdatum
- hoofddiensten
- doelregio's
- 2 tot 3 relevante concurrenten
- brandkleur primair
- brandkleur accent
- extra context of aandachtspunten van de accountmanager

Als beschikbaar, voeg ook toe:
- Google Search Console property
- of Search Console-toegang beschikbaar is

## Masterprompt
BELANGRIJK

De analyse moet:

- ±30–40 pagina inhoud genereren
- diepgaand zijn
- concrete voorbeelden tonen
- een actieplan bevatten
- GEO altijd een eigen, expliciete sectie geven in de klantanalyse en niet alleen verspreid vermelden in andere SEO-hoofdstukken
- altijd een expliciete concurrentiesectie geven in de bronanalyse en klantanalyse
- altijd een expliciete sectie `Zoekwoordpotentie en huidige score` geven in de bronanalyse en klantanalyse
- altijd een expliciete sectie `Blogstrategie` of `Blog contentplan` geven in de bronanalyse en klantanalyse
- voor keywordvolumes en keywordideeën bij voorkeur gedeelde Google Ads Keyword Planner-data gebruiken
- Search Console-data alleen als extra laag gebruiken zodra propertytoegang beschikbaar is
- bij ontbrekende tooldata nooit de sectie weglaten, maar een transparante fallback gebruiken
- brandkleuren gebruiken in de klantanalyse wanneer ze zijn ingevuld

### 1. Executive Summary
Leg uit:

- wat de website momenteel doet
- wat de grootste SEO-problemen zijn
- wat de grootste groeikansen zijn
- waarom SEO belangrijk is voor dit bedrijf

Geef ook een korte groeiprognose.

### 2. Analyse van de huidige website
Analyseer:

- homepage
- dienstenpagina's
- navigatie
- structuur
- content

Beantwoord:

- Is de website momenteel een brochure website
- Is de website momenteel een marketing website
- Is de website momenteel een leadgeneratie website

### 3. Algemene SEO score
Maak een tabel:

| onderdeel | score |
| --- | --- |
| technische SEO |  |
| content SEO |  |
| local SEO |  |
| mobile SEO |  |
| structured data |  |
| trust signals |  |

Geef uitleg per onderdeel.

### 4. Core Web Vitals analyse
Leg eenvoudig uit:

- LCP
- INP
- CLS

Maak tabel:

| metric | doel | huidige score | beoordeling |
| --- | --- | --- | --- |

Geef concrete oplossingen:

- afbeeldingen optimaliseren
- CDN
- caching
- lazy loading

Leg ook uit wat een CDN is.

### 5. Afbeelding SEO analyse (ALT TAG ANALYSE)
Controleer echte afbeeldingen op de website.

Zoek en analyseer:

- hero afbeeldingen
- projectfoto's
- sliders
- content afbeeldingen

Zoek ook de huidige alt-tags van de website.

Maak tabel:

| afbeelding | huidige alt-tag | probleem | verbeterde alt-tag |
| --- | --- | --- | --- |

Voorbeeld:

| afbeelding | huidige alt | probleem | verbetering |
| --- | --- | --- | --- |
| hero afbeelding | IMG_1234 | geen context | dakrenovatie Antwerpen hellend dak |

Leg uit waarom alt-tags belangrijk zijn voor:

- SEO
- Google Images
- toegankelijkheid

### 6. Technische SEO audit
Analyseer:

- title tags
- meta descriptions
- H1 structuur
- URL structuur
- interne links

Gebruik structuur:

- Huidige situatie
- Probleem
- Verbeterde versie

Geef concrete voorbeelden.

Voorbeeld:

Homepage title

Huidige:
Home - Bedrijfsnaam

Verbeterde versie:
Dakwerken Antwerpen | Hellende en Platte Daken | Bedrijfsnaam

### 7. Ranking analyse
Maak tabel:

| keyword | positie | zoekvolume |
| --- | --- | --- |

Gebruik belangrijkste zoekwoorden rond diensten.

Deze sectie is verplicht in elke nieuwe analyse.

Als Search Console beschikbaar is:
- gebruik echte querydata voor clicks, impressies, CTR en gemiddelde positie
- benoem duidelijk welke zoekwoorden al tractie hebben maar nog buiten de top 10 of top 3 zitten
- maak onderscheid tussen echte Search Console-data en externe volumeschattingen

Als Search Console niet beschikbaar is:
- gebruik keywordvolumes uit Google Ads Keyword Planner of een vergelijkbare betrouwbare databron
- bepaal huidige ranking of zichtbaarheid via live waargenomen SERP-checks
- benoem transparant wanneer volumes exact zijn en wanneer ze bandbreedtes zijn
- label huidige posities als `waargenomen live check` wanneer ze niet uit een vaste rankingtool komen

Maak daarnaast altijd een tweede tabel met deze structuur:

| keyword | zoekvolume per maand | huidige positie / zichtbaarheid | wat ontbreekt | aanbevolen doelpagina |
| --- | --- | --- | --- | --- |

### 8. Keyword gap analyse
Zoekwoorden waar concurrenten op ranken.

| keyword | volume |
| --- | --- |

Als Search Console beschikbaar is:
- voeg ook een blok toe met `queries waar de klant al impressies voor krijgt maar nog onderpresteert`
- gebruik die data om sneller quick wins te prioriteren dan alleen op externe keywordtools

Als Search Console niet beschikbaar is:
- gebruik concurrenten, site-inhoud, diensten en regio's om de relevante keywordset af te leiden
- vul volumes aan met gedeelde keywordtooldata

### 9. Concurrentie analyse
Zoek 2 sterke concurrenten in dezelfde regio.

Maak tabel:

| factor | klant | concurrent 1 | concurrent 2 |
| --- | --- | --- | --- |
| pagina's |  |  |  |
| blogartikelen |  |  |  |
| stadpagina's |  |  |  |
| backlinks |  |  |  |

Leg uit waarom concurrenten beter ranken.

Deze sectie is verplicht in elke nieuwe analyse.

### 10. Google Business profiel analyse
Analyseer:

- reviews
- rating
- foto's
- posts
- categorieën

Geef concrete verbeteringen.

### 11. Backlink analyse
Maak tabel:

| metric | klant | concurrent |
| --- | --- | --- |

Geef strategie:

- lokale partners
- leveranciers
- bouwplatformen
- nieuwswebsites

### 12. Interne link strategie
Leg uit hoe blogartikelen en diensten moeten linken.

Geef voorbeelden.

### 13. Ideale SEO site structuur
Maak een SEO site structuur van ±100 pagina's.

Maak ook een visuele sitemap.

Voorbeeld:

```text
Homepage
|
|-- Diensten
|   |-- Dakrenovatie
|   |-- Plat dak
|   |-- Hellend dak
|   |-- Dakisolatie
|   `-- Industriële daken
|
|-- Steden
|   |-- Dakwerken Antwerpen
|   |-- Dakwerken Brasschaat
|   |-- Dakwerken Schoten
|   `-- Dakwerken Kapellen
|
|-- Service + Stad
|   |-- Dakrenovatie Antwerpen
|   |-- Plat dak Antwerpen
|   `-- Dakisolatie Antwerpen
|
|-- Blog
|   |-- Wat kost een dakrenovatie
|   |-- EPDM vs roofing
|   `-- Dakisolatie premie
|
|-- Projecten
|
`-- Offerte
```

### 14. Content strategie
Leg uit:

- Pillar pages
- Cluster model

Geef voorbeeld.

### 15. Blogstrategie en contentplan
Maak:

- 2 blogs per maand
- 6 maanden

Geef altijd deze vaste onderdelen in deze volgorde:

1. Waarom de bloglaag nodig is voor SEO en GEO
2. Prioritaire contentpijlers
3. Een blogkalender van 12 artikels
4. Minstens 2 kort uitgewerkte voorbeeldblogs
5. Een vaste template voor de overige artikels

Gebruik voor de kalender minimaal deze tabel:

| maand | artikel | zoekintentie | primaire linkdoelen |
| --- | --- | --- | --- |

Werk daarna minstens 2 voorbeeldblogs uit met deze vaste opbouw:

- Titel
- Intro
- 3 tot 5 duidelijke secties in mensentaal
- korte answer-ready samenvatting van 40 tot 80 woorden
- 2 interne links naar commerciële pagina's
- 1 CTA naar offerte, inspectie of advies

Gebruik voor alle overige blogartikels deze vaste template:

- Intro met probleem en context
- Uitleg in mensentaal
- 3 tot 5 duidelijke secties
- minstens 1 checklist, vergelijkingstabel of FAQ-blok
- answer-ready samenvatting van 40 tot 80 woorden
- 2 interne links naar commerciële pagina's
- 1 CTA naar offerte, inspectie of advies

### 16. GEO Analyse (AI zoekmachines)
Analyseer hoe goed de website scoort voor AI zoekmachines zoals:

- ChatGPT
- Perplexity
- Gemini

Deze sectie is verplicht in elke nieuwe analyse en mag niet verdwijnen uit de klantanalyse.

Maak tabel:

| factor | score |
| --- | --- |
| AI citeerbare content |  |
| FAQ content |  |
| prijsartikelen |  |
| vergelijkingen |  |
| stappenplannen |  |

### 17. GEO Script Analyse
Analyseer welke scripts ontbreken.

Typische scripts die AI citeert:

- prijsartikelen
- vergelijkingen
- gidsen
- FAQ pagina's

### 18. GEO Scripts Genereren
Genereer minstens 3 volledige GEO scripts.

1. Vergelijking script: EPDM vs roofing
2. Gids script: Wat kost een dakrenovatie
3. FAQ script: Wanneer moet een dak vervangen worden

Structuur:

- Titel
- Intro
- Uitleg
- Voordelen
- Stappen
- FAQ

### 19. Perfect uitgewerkte dienstenpagina
Schrijf een voorbeeld dienstenpagina met:

- titel
- intro
- voordelen
- kosten
- stappen
- FAQ
- call to action

### 20. SEO Roadmap
- Maand 1–2
- Maand 3–4
- Maand 5–6

### 21. Prioriteitenlijst
Top 5 acties met grootste impact.

### 22. Voorzichtige opbrengstprognose
Gebruik:

- bezoekers
- conversie
- leads
- projecten

Maak omzetberekening.

Gebruik een voorzichtige schatting.

### 23. Conclusie
Samenvatting van:

- huidige situatie
- grootste kansen
- verwachte impact

## Extra instructies
Schrijf:

- duidelijk
- professioneel
- met tabellen
- met concrete voorbeelden

Als informatie ontbreekt:

- maak een realistische inschatting
