# FlowPlus SEO Audit en GEO Analyse

**Bedrijf:** FlowPlus  
**Website:** https://flowplus.be/  
**Auditdatum:** 20 maart 2026  
**Doeldiensten:** airco installaties, warmtepompen, ventilatie  
**Doelregio's:** Antwerpen, Vlaams-Brabant  
**Benchmarks:** FavorCool, EnergyKing  
**Brandkleur primair:** #1C76A9  
**Brandkleur accent:** #232323  
**Accountmanager-notities:** niet aangeleverd; aannames zijn hieronder expliciet gemarkeerd  

## Methodologie
Deze audit combineert:
- live websitecrawl van `flowplus.be` op 20 maart 2026
- sitemapanalyse van FlowPlus en de opgegeven concurrenten
- handmatige metadata-, heading-, structured-data- en afbeeldingscontrole
- live SERP spot checks op commerciële zoektermen op 20 maart 2026
- lokale Lighthouse-metingen voor desktop en mobiel op de homepage

Belangrijke transparantie:
- de gedeelde Google Ads Keyword Planner-config was in deze omgeving niet ingevuld, waardoor exacte maandvolumes niet automatisch konden worden opgehaald
- waar geen harde volumecijfers beschikbaar waren, gebruik ik conservatieve bandbreedtes en label ik die als inschatting
- voor huidige zichtbaarheid gebruik ik live waargenomen SERP spot checks
- voor backlinks en Google Business Profile is dit een kwalitatieve analyse zonder rechtstreekse tooltoegang

---

## 1. Executive Summary

### Wat de website momenteel doet
FlowPlus is vandaag duidelijk geen brochurewebsite meer. De site werkt als een commerciële marketing- en leadgeneratiewebsite met:
- duidelijke dienstpagina's voor airco, warmtepompen en ventilatie
- meerdere offerteformulieren
- sterke contactprominentie
- een zichtbare telefoonlijn en serviceboodschap
- veel lokale airco-landingspagina's

Dat is een stevig vertrekpunt. Veel installateurs blijven hangen op een generieke homepage met een paar dienstblokken. FlowPlus doet al meer dan dat.

### Grootste SEO-problemen
De grootste remmers zitten vandaag in structuurkwaliteit, niet in puur aantal pagina's:
- de homepage is inhoudelijk breed maar semantisch te generiek voor de doelregio's Antwerpen en Vlaams-Brabant
- de site heeft extreem veel `airco-plaats`-pagina's, maar nauwelijks equivalente lokale uitbouw voor warmtepompen en ventilatie
- belangrijke commerciële zoektermen tonen in live spot checks geen consistente top-10 zichtbaarheid
- de mobiele performance is middelmatig tot zwak op LCP en interactiviteit
- structured data blijft hangen op `WebPage`, `BreadcrumbList` en `WebSite`; `LocalBusiness`, `HVACBusiness`, `FAQPage` en `AggregateRating` ontbreken
- meerdere afbeeldingen hebben lege alt-tags
- de robots-configuratie blokkeert onder meer `ChatGPT-User`, `GPTBot`, `ClaudeBot`, `anthropic-ai`, `DuckDuckGo` en `Applebot`, wat GEO-potentieel afremt

### Grootste groeikansen
De snelste groeikansen voor FlowPlus liggen in:
- één heldere regionale focuslaag voor Antwerpen en Vlaams-Brabant
- uitrol van warmtepomp- en ventilatiepagina's per regio, niet alleen airco
- opschonen en prioriteren van de enorme lokale airco-paginavoorraad
- bouwen van betere province hubs en service + stad clusters
- answer-ready content voor AI-zoekmachines en featured-answer formats
- betere structured data en lokale trustsignalen

### Waarom SEO belangrijk is voor FlowPlus
Voor FlowPlus is SEO belangrijk omdat het bedrijf in een markt zit met hoge koopintentie:
- mensen zoeken vlak voor contact of offerte
- diensten hebben een hoge ticketwaarde
- lokale relevantie is doorslaggevend
- de markt is versnipperd: wie het best structureert wint disproportioneel veel verkeer

Wie wint op zoektermen zoals `airco installateur Antwerpen`, `warmtepomp installateur Antwerpen` of `airco Vlaams-Brabant`, wint geen vrijblijvende bezoekers maar potentiële offerte-aanvragen.

### Korte groeiprognose
Bij een consistente uitvoering over 6 tot 9 maanden is een realistisch scenario:
- +25% tot +70% extra niet-merk SEO-verkeer
- duidelijk betere zichtbaarheid op airco-gerichte lokale termen
- eerste tractie op warmtepomp-zoektermen in Antwerpen
- een sterkere basis om daarna Vlaams-Brabant systematisch uit te rollen

In omzettermen is het effect voor FlowPlus vooral interessant omdat één extra HVAC-project per maand de SEO-investering al snel rechtvaardigt.

---

## 2. Analyse van de huidige website

### Homepage
De homepage communiceert meteen aanbod, service en contact. Ze is visueel commercieel genoeg en heeft formulieren, telefoonnummer en offerte-aanmoediging duidelijk zichtbaar. Dat is goed voor conversie.

Sterke punten:
- duidelijke diensttriade: airco, warmtepompen, ventilatie
- snel contactpad via `03 375 09 00` en offerteformulier
- leadgeneratie is overal aanwezig
- Aartselaar staat duidelijk in header en contactgedeelte
- review- en klantlogo-elementen versterken vertrouwen

Zwakke punten:
- de title tag is generiek en bevat geen regiofocus
- de H1 bevat een taalfout: `Uw betrouwbaar partner` moet `Uw betrouwbare partner` zijn
- de homepage focust niet sterk genoeg op Antwerpen en Vlaams-Brabant
- er is geen scherpe prioritering tussen residentieel, B2B en regio-intentie
- de hoofdbelofte klinkt commercieel, maar niet expliciet SEO-gestuurd

### Dienstenpagina's
De drie hoofddiensten bestaan en dat is positief. Vooral de airco-sectie is het verst uitgewerkt.

#### Airco
Airco is veruit de sterkste SEO-laag van FlowPlus:
- een hoofdservicepagina
- onderhouds- en systeempagina's
- een zeer groot aantal lokale airco-landingspagina's
- provinciepagina's voor Antwerpen en Oost-Vlaanderen

Tegelijk ontstaat hier ook het grootste risico:
- 455 URL's met het patroon `/airco-.../`
- sterk repetitieve titels, meta descriptions en H1-variaties
- waarschijnlijk dunne inhoud of minimaal onderscheid tussen veel stadspagina's
- risico op indexvervuiling, cannibalisatie en crawlbudgetverspilling

#### Warmtepompen
Warmtepompen is commercieel aanwezig, maar SEO-matig nog te generiek:
- er is een hoofdpagina
- er zijn enkele blogartikelen
- er is geen zichtbare lokale architectuur voor Antwerpen of Vlaams-Brabant
- `https://flowplus.be/warmtepomp-antwerpen/` gaf op 20 maart 2026 een `404`

Dat betekent dat FlowPlus op warmtepompvlak nog niet de regionale SEO-infrastructuur heeft die het op airco al wel probeert op te bouwen.

#### Ventilatie
Ventilatie is aanwezig, maar nog dunner uitgewerkt dan airco en warmtepompen:
- een hoofdservicepagina
- een systeempagina
- enkele informatieve artikels
- geen duidelijke regionale commerciële landingspagina's
- `https://flowplus.be/ventilatie-antwerpen/` gaf op 20 maart 2026 een `404`

### Navigatie en structuur
De navigatie is overzichtelijk en commercieel bruikbaar:
- Home
- Airco
- Airco systemen
- Airco modellen
- Airco onderhoud
- Warmtepompen
- Ventilatie
- Ventilatie systemen
- Over ons
- Nieuws
- Contact

Wat ontbreekt in de hoofdstructuur:
- regiohubs
- provinciehubs voor target markets
- een heldere kennishub per dienst
- een pagina voor realisaties of cases per regio
- zichtbare FAQ-hubs

### Contentlaag
De contentlaag is beter dan gemiddeld, maar nog niet sterk genoeg om topical authority te claimen.

Positief:
- 37 zichtbare post-URL's in de sitemap
- artikels over onderhoud, luchtvochtigheid, warmtepompen en vergelijkingen
- meertalige content aanwezig

Negatief:
- een deel van de content is meertalig duplicatief in plaats van extra topical authority
- er is nog te weinig diepgaande lokale koopgidscontent
- veel lokale intentie lijkt vooral op URL-niveau aanwezig, niet op inhoudsniveau
- weinig duidelijke BOFU-content voor warmtepompen en ventilatie per regio

### Is de site een brochurewebsite, marketingwebsite of leadgeneratiewebsite?
FlowPlus is vandaag het best te omschrijven als een **marketingwebsite met duidelijke leadgeneratie-elementen**.

Ze is geen brochurewebsite omdat:
- er meerdere formulieren op belangrijke pagina's staan
- telefonische contactopname overal aanwezig is
- de site inhoudelijk draait om offerte en advies

Ze is nog geen volwassen SEO-leadmachine omdat:
- de commerciële informatiearchitectuur uit balans is
- de warmtepomp- en ventilatie-intentie achterloopt op airco
- de beste lokale URL-architectuur nog niet gepaard gaat met zichtbare niet-merkposities

---

## 3. Algemene SEO-score

| Onderdeel | Score /10 | Uitleg |
| --- | --- | --- |
| Technische SEO | 6/10 | Basis is degelijk en indexeerbaar, maar metadata, schema, lokale paginakwaliteit en 404-gaten houden de site onder haar potentieel. |
| Content SEO | 6/10 | Meer content dan gemiddeld voor een HVAC-speler, maar onvoldoende diepte op commerciële regio-intentie buiten airco. |
| Local SEO | 6/10 | Antwerpen is aanwezig via Aartselaar en vele airco-city pages, maar Vlaams-Brabant is zwak en warmtepomp/ventilatie missen lokale uitbouw. |
| Mobile SEO | 5/10 | Mobiel is bruikbaar, maar LCP 6,7 s en interactive 13,1 s zijn te hoog voor een site die leads moet converteren. |
| Structured Data | 4/10 | Enkel basale schema-objecten gevonden; belangrijke business-, service-, review- en FAQ-schema's ontbreken. |
| Trust Signals | 7/10 | Contactgegevens, reviewwidget, klantlogo's en duidelijke CTA's werken goed, maar lokale bewijsvoering kan scherper. |

### Interpretatie
FlowPlus heeft geen SEO-crisis. Het probleem is eerder dat de site op sommige vlakken al ambitieus genoeg oogt, maar inhoudelijk en technisch nog niet afgemaakt is. Daardoor voelt ze groter dan ze organisch vandaag waarschijnlijk presteert.

---

## 4. Core Web Vitals analyse

### Uitleg in mensentaal

#### LCP
LCP toont hoe snel het grootste zichtbare element geladen is. Dat is meestal een grote headline, hero-afbeelding of contentblok bovenaan de pagina.

#### INP / interactiviteit
INP en de bredere interactiviteitsmetingen tonen hoe snel de site reageert zodra iemand wil klikken, scrollen of typen.

#### CLS
CLS toont of de pagina verspringt tijdens het laden. Dat lijkt bij FlowPlus redelijk goed onder controle.

### Lighthouse-resultaten homepage

| Context | Performance score | FCP | LCP | Interactive | Total Blocking Time | CLS | Beoordeling |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mobiel | 68/100 | 2,7 s | 6,7 s | 13,1 s | 180 ms | 0,00 | Te traag voor een leadgerichte homepage |
| Desktop | 83/100 | 0,4 s | 2,8 s | 2,8 s | 0 ms | 0,001 | Degelijk, maar LCP kan nog beter |

### Concrete conclusie
Het grootste performantieprobleem zit mobiel niet in de server, maar in de front-end belasting:
- scripts van third parties
- widgetbelasting
- zware visuele componenten
- veel lazy-loaded media en pagebuilder-output

### Concrete actiepunten
- beperk externe scripts tot wat commercieel echt nodig is
- herbekijk de Trustindex-widget en laad die pas later in de pagina
- optimaliseer hero-afbeeldingen en zet het belangrijkste visuele element lichter neer
- verminder onnodige Elementor-secties boven de vouw
- laad niet-kritische JS uitgesteld

### Wat is een CDN?
Een CDN is een netwerk van servers dat statische bestanden zoals afbeeldingen, CSS en JavaScript dichter bij de bezoeker serveert. Daardoor laden pagina's sneller. Voor FlowPlus lost een CDN niet alles op, maar het helpt wel in combinatie met lichtere front-end assets.

---

## 5. Afbeelding SEO analyse

### Vaststellingen
FlowPlus gebruikt meerdere echte upload-afbeeldingen op homepage, dienstpagina's en contactpagina. Daarbij vallen meteen meerdere lege alt-tags op. Dat is een gemiste kans voor:
- context voor zoekmachines
- betere Google Images-signalen
- toegankelijkheid voor schermlezers

### Voorbeelden uit de live site

| Afbeelding | Huidige alt-tag | Probleem | Verbeterde alt-tag |
| --- | --- | --- | --- |
| `/uploads/2023/03/IMG_2345.jpeg` | leeg | Geen context, waarschijnlijk realisatie- of sfeerbeeld | `airco-installatie-door-flowplus-bij-particulier-in-antwerpen` |
| `/uploads/2022/06/two-residential-modern-heat-pumps...jpg` | leeg | Warmtepompbeeld zonder semantiek | `lucht-lucht-warmtepomp-buitenunits-bij-woning` |
| `/uploads/2022/06/installation-of-ceiling-hvac-ventilation-hole...jpg` | leeg | Ventilatiebeeld zonder context | `ventilatiesysteem-plafondinstallatie-bij-bedrijfspand` |
| `/uploads/2022/08/Flowplus-11.jpg` | leeg | Projectfoto zonder regionale of dienstcontext | `airco-plaatsing-door-flowplus-in-regio-antwerpen` |
| `/uploads/2022/08/Flowplus-10.jpg` | leeg | Nog een projectbeeld zonder context | `warmtepomp-of-airco-installatie-flowplus-bij-woning` |
| `/uploads/2023/02/swarovski-logo.jpeg` | leeg | Klantlogo zonder merknaam | `Swarovski logo` |
| `/uploads/2023/02/sunglass-hut-logo-1024x538.png` | leeg | Klantlogo zonder merknaam | `Sunglass Hut logo` |
| `/uploads/2023/02/logo-iro-1024x512.webp` | leeg | Klantlogo zonder merknaam | `IRO Paris logo` |

### Waarom dit belangrijk is
Alt-tags zijn niet alleen een SEO-detail:
- ze helpen Google begrijpen wat er op de pagina visueel staat
- ze verbeteren zichtbaarheid in afbeeldingenzoekresultaten
- ze maken de site toegankelijker

### Richtlijn voor FlowPlus
Gebruik alt-tags volgens drie regels:
- beschrijf wat er echt zichtbaar is
- voeg dienst of context toe als dat logisch is
- gebruik geen keywordspam

---

## 6. Technische SEO audit

### Samenvatting
Technisch is FlowPlus niet slecht, maar de site is wel onevenwichtig. De basis werkt, maar te veel details zijn onaf.

### Huidige situatie, probleem en verbeterde versie

#### Homepage title
Huidig:
`Airco, warmtepomp en ventilatie voor particulieren en bedrijven.`

Probleem:
- generiek
- geen regiofocus
- geen installateur-intentie

Verbeterde versie:
`Airco en warmtepomp installateur in Antwerpen en Vlaams-Brabant | FlowPlus`

#### Homepage meta description
Huidig:
`Flowplus is uw betrouwbaar partner voor airco, ventilatie & warmtepompen. Vrijblijvende offerte en service door gekwalificeerde professionals.`

Probleem:
- taalfout in `betrouwbaar`
- geen regiofocus
- weinig commerciële differentiatie

Verbeterde versie:
`FlowPlus installeert en onderhoudt airco, warmtepompen en ventilatie in Antwerpen en Vlaams-Brabant. Vraag vrijblijvend advies of een offerte aan.`

#### Homepage H1
Huidig:
`Uw betrouwbaar partner voor airco, ventilatie & warmtepompen`

Probleem:
- taalfout
- geen lokale relevantie

Verbeterde versie:
`Uw betrouwbare partner voor airco, warmtepompen en ventilatie in Antwerpen en Vlaams-Brabant`

#### Airco hoofdpagina
Huidige title:
`Installatie & onderhoud van airco, voor particulier én bedrijven.`

Probleem:
- taaltechnisch stroef
- geen regio
- geen installateurkeyword

Verbeterde versie:
`Airco installateur voor particulieren en bedrijven in Antwerpen | FlowPlus`

#### Warmtepompen hoofdpagina
Huidige title:
`Warmtepomp laten installeren of onderhouden? Contacteer ons!`

Probleem:
- CTA-achtig maar niet zoekgericht
- te weinig regio en intentie

Verbeterde versie:
`Warmtepomp installateur in Antwerpen en Vlaams-Brabant | FlowPlus`

#### Provinciepagina Antwerpen
Huidige title:
`Airco provincie Antwerpen - Flowplus | Airco - Warmtepompen - Ventilatie`

Probleem:
- zwakke SEO-copy
- ontbrekende meta description
- te weinig commerciële precisie

Verbeterde versie:
`Airco installateur provincie Antwerpen | Plaatsing en onderhoud | FlowPlus`

### Heading-structuur
Op meerdere pagina's duiken dubbele of onhandige H1's op:
- `airco-antwerpen` heeft twee H1's
- `warmtepompen` heeft twee H1's
- `ventilatie` heeft twee H1's

Dat is geen ramp, maar wel een signaal dat de pagebuilder-structuur niet strak genoeg staat. Eén duidelijke H1 per pagina blijft de beste keuze.

### Concrete taal- en copyfouten
Naast SEO-issues zijn er ook een paar zichtbare taal- en copyfouten die best expliciet worden rechtgezet:

| Pagina | Huidige formulering | Probleem | Betere versie |
| --- | --- | --- | --- |
| homepage meta + H1 | `Uw betrouwbaar partner` | grammaticaal fout | `Uw betrouwbare partner` |
| homepage body | `Wij beschikken over een team van gekwalificieerde professioneels die je bij staan met raad én daad.` | meerdere fouten: `gekwalificieerde`, `professioneels`, `bij staan` | `Wij beschikken over een team van gekwalificeerde professionals die je bijstaan met raad en daad.` |
| ventilatie title | `Opzoek naar een ventilatie installateur?` | `Opzoek` moet los | `Op zoek naar een ventilatie installateur?` |
| airco title/meta | `voor particulier én bedrijven` | meervoud/enkelvoud klopt niet | `voor particulieren en bedrijven` |
| contact H1 | `Vraag uw offerte en laten we samenwerken.` | klinkt taalkundig en commercieel stroef | `Vraag uw vrijblijvende offerte aan` of `Vraag advies of een offerte aan` |
| warmtepompen H2 | `Laat u verwarmen door een warmtepomp , da’s een slimme keuze!` | foutieve spatie voor komma | `Laat u verwarmen door een warmtepomp, da's een slimme keuze.` |
| ventilatie H2 | `De juiste ventilatie en de EPB -normen` | foutieve spatie voor koppelteken | `De juiste ventilatie en de EPB-normen` |

Deze fouten zijn op zichzelf geen rankingkiller, maar ze verlagen wel de professionele indruk, CTR-kwaliteit en conversiebetrouwbaarheid.

### URL-structuur
Sterk:
- veel lokale airco-URL's zijn kort en begrijpelijk

Zwak:
- de architectuur is erg scheef verdeeld over diensten
- `airco` heeft honderden lokale URL's
- `warmtepompen` en `ventilatie` missen die structuur bijna volledig
- commerciële prioriteiten zitten verstopt in kwantiteit in plaats van heldere hiërarchie

### Interne links
De site stuurt goed naar contact en offerte, maar minder goed naar inhoudelijke clusters:
- CTA-links zijn sterk
- contextuele links tussen blog, dienst en regio kunnen veel beter
- warmtepomp- en ventilatieartikelen lijken nog te weinig door te linken naar commerciële money pages

### Structured data
Op gecontroleerde pagina's vond ik enkel:
- `WebPage`
- `ImageObject`
- `BreadcrumbList`
- `WebSite`

Wat ontbreekt:
- `Organization` of `LocalBusiness`
- `HVACBusiness`
- `PostalAddress`
- `openingHours`
- `Service`
- `FAQPage`
- `AggregateRating`

Dat is een grote gemiste kans, vooral voor local SEO en GEO.

### International / meertaligheid
De site heeft Nederlandse, Engelse en Franse versies. Dat kan een plus zijn. Maar op dit moment lijkt de meertaligheid vooral extra URL-volume op te leveren. Zonder duidelijke lokale strategie in Vlaanderen brengt dat minder waarde dan sterkere Nederlandstalige prioriteitscontent.

---

## 7. Zoekwoordpotentie en huidige score

### Methodologische noot
De gedeelde Google Ads customer ID stond niet ingevuld in deze omgeving. Daarom gebruik ik:
- maandvolume-bandbreedtes als conservatieve inschatting
- live zichtbaarheidsspotchecks op 20 maart 2026

### Ranking analyse

| Keyword | Huidige positie / zichtbaarheid | Zoekvolume | Bron |
| --- | --- | --- | --- |
| airco installateur Antwerpen | niet zichtbaar in top 10 | 250-750 | waargenomen live check + volume-inschatting |
| airco Antwerpen | niet zichtbaar in top 10 | 500-1.500 | waargenomen live check + volume-inschatting |
| warmtepomp installateur Antwerpen | niet zichtbaar in top 10 | 150-500 | waargenomen live check + volume-inschatting |
| warmtepomp Antwerpen | niet zichtbaar in top 10 | 250-750 | waargenomen live check + volume-inschatting |
| airco installateur Vlaams-Brabant | niet zichtbaar in top 10 | 100-350 | waargenomen live check + volume-inschatting |
| warmtepomp installateur Vlaams-Brabant | niet zichtbaar in top 10 | 100-250 | waargenomen live check + volume-inschatting |
| airco onderhoud Antwerpen | niet zichtbaar in top 10 | 100-350 | waargenomen live check + volume-inschatting |
| warmtepomp Aartselaar | niet zichtbaar in top 10 | 10-50 | waargenomen live check + volume-inschatting |

### Zoekwoordpotentie en huidige score

| Keyword | Zoekvolume per maand | Huidige positie / zichtbaarheid | Wat ontbreekt | Aanbevolen doelpagina |
| --- | --- | --- | --- | --- |
| airco installateur Antwerpen | 250-750 | buiten top 10 | sterkere regionale autoriteit, betere homepage + hub | homepage of `airco-provincie-antwerpen` |
| airco Antwerpen | 500-1.500 | buiten top 10 | scherpere intentie, betere regionale bewijsvoering | `airco-antwerpen` |
| warmtepomp installateur Antwerpen | 150-500 | buiten top 10 | specifieke commerciële landingspagina bestaat niet | nieuwe pagina `warmtepomp-antwerpen` |
| warmtepomp Antwerpen | 250-750 | buiten top 10 | lokale warmtepompcluster ontbreekt | nieuwe pagina `warmtepomp-antwerpen` |
| airco installateur Vlaams-Brabant | 100-350 | buiten top 10 | geen provinciehub of stadscluster | nieuwe pagina `airco-provincie-vlaams-brabant` |
| warmtepomp installateur Vlaams-Brabant | 100-250 | buiten top 10 | geen lokale warmtepomparchitectuur | nieuwe pagina `warmtepomp-provincie-vlaams-brabant` |
| ventilatie installateur Antwerpen | 50-150 | geen zichtbare tractie | te weinig commerciële regionale ventilatiecontent | nieuwe pagina `ventilatie-antwerpen` |
| airco Mechelen | 100-250 | buiten top 10 in spotcheck | bestaande city page mist extra autoriteit | `airco-mechelen` opschonen en versterken |
| airco Aartselaar | 50-150 | buiten top 10 in spotcheck | lokale proof en interne links missen kracht | `airco-aartselaar` |
| airco onderhoud Antwerpen | 100-350 | buiten top 10 | onderhoudspagina nog te generiek | aparte onderhoud + regio pagina |
| Daikin warmtepomp installateur Antwerpen | 20-80 | beperkte zichtbaarheid | merk + dienst + regio ontbreekt | nieuwe merkenpagina of subsectie |
| airco voor bedrijven Antwerpen | 50-150 | beperkte zichtbaarheid | B2B-intentie staat niet scherp genoeg los van residentieel | nieuwe B2B landingspagina |

### Concrete conclusie
FlowPlus heeft al veel URL's, maar de huidige zichtbaarheid suggereert dat URL-volume alleen niet genoeg is. De site heeft nood aan:
- duidelijkere prioriteitspagina's
- sterkere inhoud per landingspagina
- meer bewijs, FAQ's en lokale context

---

## 8. Keyword gap analyse

### Waar concurrenten sneller scoren
EnergyKing doet inhoudelijk drie dingen beter:
- duidelijke provinciegerichte SEO-pagina's
- veel grotere contentmachine
- betere combinatie van dienst + regio + educatieve content

FavorCool doet twee dingen beter:
- sterkere commerciële merkpositionering
- eenvoudigere focus, minder versnippering

### Belangrijkste gaps voor FlowPlus

| Keywordcluster | Waarom interessant | Huidige FlowPlus-gap |
| --- | --- | --- |
| warmtepomp + Antwerpen | hoge koopintentie | geen volwaardige commerciële lokale pagina |
| warmtepomp + Vlaams-Brabant | groeiregio | geen provincie- of stadscluster |
| ventilatie + Antwerpen | minder concurrentie, toch waardevol | geen lokale servicepagina |
| airco + Vlaams-Brabant | strategische regio | geen duidelijke provinciehub |
| airco onderhoud + regio | onderhoud levert terugkerende omzet | onderhoudscontent is te generiek |
| prijs- en kostenvragen | ideaal voor SEO + GEO | te weinig dedicated kostencontent |
| keuzecontent | helpt twijfelaars converteren | beperkte vergelijkingstabellen en beslissingscontent |
| B2B HVAC-content | bedrijven zoeken vaak anders dan particulieren | weinig zichtbare B2B clusters |

### Queries waar FlowPlus nu inhoudelijk kansen laat liggen
- wat kost een airco installatie in Antwerpen
- warmtepomp laten installeren in Antwerpen
- warmtepomp of airco voor appartement
- ventilatiesysteem laten plaatsen Antwerpen
- airco voor kantoor Antwerpen
- airco premies of btw-voordeel

---

## 9. Concurrentie analyse

### Indicatieve benchmark

| Factor | FlowPlus | FavorCool | EnergyKing |
| --- | --- | --- | --- |
| Zichtbare sitemap-URL's | 541 | 61 | 274 |
| Content-/post-URL's | 37 | 1 | 134 |
| Provinciepagina's | 2 airco-provinciepagina's | geen duidelijke provinciehub in sitemap | 2 provincie-sitemappaden |
| Lokale stadspagina's | zeer veel airco-city pages | beperkt | minder extreem, maar doelgerichter |
| Warmtepomp lokale pagina's | vrijwel afwezig | beperkt maar merkmatig beter verpakt | wel commerciële lokale uitrol |
| Structured data volwassenheid | basis | basis tot middelmatig | vermoedelijk beter op lokale intentie |
| Backlinkwaarschijnlijkheid | middelmatig | middelmatig | hoger door merk-, content- en schaalvoordeel |

### Wat FlowPlus beter doet dan FavorCool
- veel sterkere lokale airco-uitrol
- meer organische URL-kansen
- duidelijkere lokale dienstcombinaties op URL-niveau

### Wat FavorCool beter doet dan FlowPlus
- minder versnipperd merkverhaal
- commerciëlere bovenlaag
- duidelijkere hoofdpositionering op de homepage

### Wat EnergyKing beter doet dan FlowPlus
- grotere contentmachine
- sterkere schaal op duurzame energiecontent
- zichtbaarere regionale landingspagina's voor warmtepompintentie

### Waarom concurrenten beter kunnen ranken
De kans is groot dat concurrenten beter scoren door drie dingen:
- betere contentdiepte
- sterkere dienst + regio combinaties op prioriteitstermen
- minder onevenwichtige architectuur

FlowPlus heeft potentieel veel URL's, maar niet alle URL's dragen evenveel echte autoriteit of uniek nut.

---

## 10. Google Business profiel analyse

### Publiek zichtbare signalen
Op de website zelf zijn volgende local SEO-signalen duidelijk aanwezig:
- kantooradres: `Oeyvaersbosch 11, 2630 Aartselaar`
- telefoonnummer: `03 375 09 00`
- e-mailadres: `info@flowplus.be`
- reviewwidget via Trustindex
- klantlogo's en testimonials

### Wat vermoedelijk ontbreekt of sterker kan
Zonder directe GBP-login lijken dit de belangrijkste verbeterpunten:
- categorieën specifieker afstemmen op HVAC, airco en warmtepompen
- meer recente projectfoto's uploaden met beschrijving
- reviewverzameling meer regionaal sturen
- updates en posts ritmischer inzetten
- Q&A benutten voor servicegebieden, onderhoud en types installaties

### Concrete aanbevelingen
- gebruik steeds dezelfde NAP-gegevens op website, GBP en directories
- voeg fotoalbums toe per dienst en per regio
- vraag reviews die dienst + plaats benoemen
- gebruik in review-aanvragen formuleringen zoals `airco in Antwerpen`, `warmtepomp in Aartselaar`, `ventilatie in Mechelen`
- voeg servicegebieden expliciet toe met focus op Antwerpen en Vlaams-Brabant

### Conclusie
FlowPlus heeft de basisingrediënten voor een sterk Google Business Profile, maar op de site zie ik nog niet genoeg lokale semantische versterking om dat profiel maximaal te laten renderen in SEO en GEO.

---

## 11. Backlink analyse

### Transparante noot
Zonder Ahrefs, Majestic of Semrush-data maak ik hier een kwalitatieve analyse.

### Huidige situatie
FlowPlus oogt geloofwaardig en heeft genoeg bedrijfsrealiteit om links te verdienen, maar de site lijkt vandaag vooral op eigen commerciële pagina's te steunen. De contentmachine is nog niet sterk genoeg om vanzelf veel backlinks aan te trekken.

### Vergelijking

| Metric | FlowPlus | Concurrenten |
| --- | --- | --- |
| Linkwaardige gidscontent | middelmatig | EnergyKing waarschijnlijk sterker |
| Regionale PR-waardigheid | goed | vergelijkbaar |
| Partners/merken | potentieel aanwezig | FavorCool en EnergyKing benutten merkverhalen sterker |
| Cases/realisaties | beperkt zichtbaar | concurrenten halen hier mogelijk extra trust uit |

### Aanbevolen backlinkstrategie
- lokale architecten, aannemers en bouwpartners
- leveranciers- en merkpartnerpagina's
- artikels op regionale ondernemersplatformen
- cases op lokale nieuwssites of businessclubs
- samenwerkingen met syndici, vastgoedspelers en B2B netwerken

### Beste linkable assets om eerst te bouwen
- gids `airco vs warmtepomp`
- kostenpagina per dienst
- subsidie- of btw-gids
- regiopagina met echte casefoto's
- B2B referentiecase

---

## 12. Interne link strategie

### Probleem vandaag
De site linkt goed naar contact, maar nog te weinig slim naar:
- kern-dienstpagina's
- regionale money pages
- ondersteunende blogartikels
- vergelijkings- en keuzecontent

### Aanpak
Werk met drie lagen:
- money pages
- support pages
- evidence pages

### Voorbeeld
De pagina `warmtepomp-antwerpen` moet intern gelinkt worden vanuit:
- homepage
- warmtepompen hoofdpagina
- artikel over verschil warmtepomp en airco
- artikel over koelen met warmtepomp
- contactpagina
- provinciepagina Antwerpen

### Richtlijnen
- gebruik beschrijvende ankerteksten
- link vanuit artikels altijd terug naar de commerciële pagina
- verbind iedere regionale pagina aan één hoofdhub en meerdere ondersteunende artikels
- laat city pages ook teruglinken naar provinciehub

---

## 13. Blogstrategie

### Waarom een expliciete blogsectie hier nodig is
Ja, die hoort erin. Voor FlowPlus is een blog- of kenniscentrum geen nice-to-have maar de brug tussen:
- informatieve zoekintentie
- commerciële landingspagina's
- GEO-zichtbaarheid

Vandaag is er al nieuws- en blogcontent aanwezig, maar die is nog te weinig planmatig gekoppeld aan de prioritaire dienst- en regiopagina's.

### Doel van de bloglaag
De blogsectie moet drie dingen doen:
- extra verkeer aantrekken op vragen en vergelijkingen
- interne links sturen naar money pages
- FlowPlus citeerbaar maken voor AI-zoekmachines

### Prioritaire contentpijlers
- prijs en kostprijs
- vergelijkingen
- keuzehulp
- onderhoud
- regionale vragen
- B2B/HVAC-vragen

## Blogkalender: 12 artikels
| Titel | Zoekintentie | Primaire linkdoelen |
| --- | --- | --- |
| Wat kost een airco installatie in Antwerpen in 2026? | prijs + commercieel informatief | `airco-antwerpen`, `contact` |
| Warmtepomp of airco: wat kies je best voor jouw woning? | vergelijking | `warmtepompen`, `airco` |
| Welke airco kies je voor een appartement? | keuzehulp | `airco`, `airco-antwerpen` |
| Wanneer kies je voor ventilatie type C of D? | vergelijking + informatief | `ventilatie`, `contact` |
| Wat kost een warmtepomp in Antwerpen? | prijsintentie | `warmtepomp-antwerpen`, `contact` |
| Airco onderhoud: wanneer is het nodig en hoe vaak? | onderhoud | `airco-onderhoud`, `contact` |
| Airco voor kantoor of winkel: waar moet je op letten? | B2B informatief | `airco`, `contact` |
| Welke premies of btw-regels zijn relevant voor HVAC in 2026? | regelgeving + trust | `warmtepompen`, `airco` |
| Hoeveel verbruikt een airco echt? | informatief + twijfelfase | `airco`, `airco-antwerpen` |
| Warmtepomp in bestaande woning: wanneer loont het? | beslissingsondersteuning | `warmtepompen`, `contact` |
| Airco in Vlaams-Brabant: waar moet je op letten bij plaatsing? | lokaal/commercieel | `airco-provincie-vlaams-brabant`, `contact` |
| Ventilatie in een renovatieproject: wanneer moet je dit meenemen? | informatief + commerciële voorbereiding | `ventilatie`, `contact` |

## Volledig uitgewerkt blogartikel 1
**Titel:** Wat kost een airco installatie in Antwerpen in 2026?

### Intro
Wie zoekt naar de prijs van een airco installatie in Antwerpen, wil meestal snel weten welk budget realistisch is en waar de verschillen in offertes vandaan komen. Er bestaat geen vaste standaardprijs, omdat de kost mee afhangt van het type toestel, het aantal ruimtes, de technische plaatsing en de afwerking van het project.

### Waar hangt de prijs van af?
#### 1. Type systeem
Een single split voor één ruimte vraagt een andere investering dan een multisplit voor meerdere kamers. Hoe meer binnenunits, hoe groter de technische en budgettaire impact.

#### 2. Woning of gebouwtype
Een appartement, rijwoning of handelszaak vraagt niet dezelfde aanpak. De bereikbaarheid van de buitenunit, leidingtrajecten en afwerking wegen sterk door in de offerte.

#### 3. Vermogen en gebruik
Een slaapkamer, leefruimte of kantoor vraagt elk een andere capaciteit. Een goede dimensionering is belangrijk om comfort te combineren met een logisch verbruik.

#### 4. Afwerkingsniveau
Ook geluidsniveau, design van de binnenunit, bediening via app en de zichtbaarheid van leidingen bepalen mee hoe hoog de uiteindelijke investering ligt.

### Waarom een plaatsbezoek belangrijk is
Een richtprijs online helpt, maar een correcte offerte begint met een technisch bezoek. FlowPlus kan dan inschatten welk systeem past, waar de installatie het best komt en hoe de afwerking proper en efficiënt kan gebeuren.

### Answer-ready samenvatting
De kost van een airco installatie in Antwerpen hangt vooral af van het gekozen systeem, het aantal ruimtes, de technische plaatsing en het gewenste comfortniveau. Een eenvoudige single split-installatie ligt anders dan een multisplit of een complexer traject in een handelszaak. Een plaatsbezoek blijft de beste basis voor een correcte offerte.

### Interne links
- Naar `airco-antwerpen`
- Naar `contact`

### Call to action
Wilt u weten wat een airco installatie in uw woning of zaak ongeveer zal kosten? Vraag advies of een vrijblijvende offerte aan bij FlowPlus.

## Volledig uitgewerkt blogartikel 2
**Titel:** Warmtepomp of airco: wat kies je best voor jouw woning?

### Intro
Twijfelt u tussen een warmtepomp en een airco, dan is de juiste keuze meestal niet zwart-wit. Beide systemen verhogen het comfort, maar ze lossen niet exact dezelfde vraag op. De beste oplossing hangt af van uw woning, uw huidige installatie en de vraag of koelen, verwarmen of een combinatie centraal staat.

### Wanneer een airco logisch is
Een airco is vaak de juiste keuze wanneer snelle en gerichte koeling de hoofdbehoefte is. Zeker in slaapkamers, leefruimtes of appartementen waar oververhitting een terugkerend probleem is, biedt een airco snel comfort.

### Wanneer een warmtepomp interessanter is
Een warmtepomp komt sterker in beeld wanneer u ook duurzaam wil verwarmen en toekomstgerichter wil investeren. Dat vraagt wel een woning en afgiftesysteem die technisch geschikt zijn.

### Welke factoren bepalen de juiste keuze?
#### Comfortdoel
Zoekt u vooral verkoeling, dan kijkt u anders naar de investering dan wanneer ook energiezuinige verwarming en lagere verbruikskosten belangrijk zijn.

#### Technische situatie
De isolatiegraad, beschikbare ruimte en bestaande installatie maken een groot verschil in wat realistisch en slim is.

#### Budget en timing
Sommige oplossingen zijn sneller uitvoerbaar en direct inzetbaar, terwijl andere meer voorbereiding vragen maar op langere termijn interessanter kunnen zijn.

### Hoe FlowPlus hierin adviseert
FlowPlus bekijkt niet alleen een toestel, maar de volledige context van de woning of het gebouw. Zo vertrekt het advies niet vanuit een product, maar vanuit comfort, haalbaarheid en een logische investering.

### Answer-ready samenvatting
Een airco is vooral interessant wanneer gerichte koeling snel nodig is, terwijl een warmtepomp beter past bij wie ook efficiënt wil verwarmen en toekomstgericht wil investeren. De juiste keuze hangt af van comfortdoel, technische haalbaarheid en budget. Daarom is advies op maat belangrijker dan een algemene vuistregel.

### Interne links
- Naar `warmtepompen`
- Naar `airco`

### Call to action
Wilt u weten of een airco of warmtepomp voor uw woning de slimste keuze is? Laat FlowPlus uw situatie bekijken en ontvang gericht advies.

## Blogbrief template voor de overige 10 artikels
Gebruik voor elk artikel deze vaste opbouw:
- Intro met probleem en context
- Uitleg in mensentaal
- 3 tot 5 duidelijke secties
- Minstens 1 checklist, vergelijkingstabel of FAQ-blok
- Answer-ready samenvatting van 40 tot 80 woorden
- 2 interne links naar commerciële pagina's
- 1 CTA naar advies of offerte

## 14. Ideale SEO site structuur

### Doel
FlowPlus heeft nood aan een slimmere architectuur, niet per se nog meer losse pagina's.

### Visuele sitemap

```text
Homepage
|
|-- Airco
|   |-- Airco installeren
|   |-- Airco onderhoud
|   |-- Airco systemen
|   |-- Airco modellen
|   |-- Airco voor bedrijven
|   |-- Airco prijzen
|   |-- Airco provincie Antwerpen
|   |   |-- Airco Antwerpen
|   |   |-- Airco Mechelen
|   |   |-- Airco Lier
|   |   |-- Airco Kontich
|   |   `-- Airco Aartselaar
|   `-- Airco provincie Vlaams-Brabant
|       |-- Airco Leuven
|       |-- Airco Vilvoorde
|       |-- Airco Zaventem
|       |-- Airco Aarschot
|       `-- Airco Halle
|
|-- Warmtepompen
|   |-- Warmtepomp installeren
|   |-- Warmtepomp onderhoud
|   |-- Warmtepomp soorten
|   |-- Warmtepomp prijzen
|   |-- Warmtepomp voor bedrijven
|   |-- Warmtepomp provincie Antwerpen
|   |   |-- Warmtepomp Antwerpen
|   |   |-- Warmtepomp Mechelen
|   |   `-- Warmtepomp Aartselaar
|   `-- Warmtepomp provincie Vlaams-Brabant
|       |-- Warmtepomp Leuven
|       |-- Warmtepomp Vilvoorde
|       `-- Warmtepomp Halle
|
|-- Ventilatie
|   |-- Ventilatie systemen
|   |-- Ventilatie onderhoud
|   |-- Ventilatie voor bedrijven
|   |-- Ventilatie provincie Antwerpen
|   |   |-- Ventilatie Antwerpen
|   |   `-- Ventilatie Mechelen
|   `-- Ventilatie provincie Vlaams-Brabant
|       |-- Ventilatie Leuven
|       `-- Ventilatie Zaventem
|
|-- Regio's
|   |-- Antwerpen
|   `-- Vlaams-Brabant
|
|-- Cases
|   |-- Airco case Antwerpen
|   |-- Warmtepomp case Mechelen
|   `-- Ventilatie case kantoor Antwerpen
|
`-- Kenniscentrum
    |-- Airco vs warmtepomp
    |-- Wat kost een airco installatie?
    |-- Wat kost een warmtepomp?
    |-- Welke airco voor appartement?
    |-- Wanneer kies je ventilatie type C of D?
    |-- Premies en btw voor HVAC
    `-- Onderhoudsgidsen per dienst
```

### Waarom dit beter werkt
- duidelijkere prioriteitspagina's
- minder verspilling op irrelevante of dunne local pages
- sterkere verhouding tussen dienst, regio en ondersteunende content

---

## 15. GEO

## Waarom GEO hier expliciet belangrijk is
AI-zoekmachines en answer engines werken het best met content die:
- duidelijk geformuleerd is
- semantisch strak is opgebouwd
- feitelijke lokale context bevat
- vragen rechtstreeks beantwoordt

### Wat FlowPlus vandaag tegenhoudt
Het grootste GEO-probleem is niet de schrijfstijl, maar de toegankelijkheid:
- `robots.txt` blokkeert expliciet onder meer `ChatGPT-User`, `GPTBot`, `ClaudeBot`, `anthropic-ai`, `DuckDuckGo` en `Applebot`
- structured data voor lokale business en diensten ontbreekt
- veel pagina's zijn opgevat als commerciële landingspagina's, maar niet als answer-ready content

### Gevolg
FlowPlus maakt het AI-systemen moeilijker om:
- de site te citeren
- lokale expertise te herkennen
- de juiste dienst/regiocombinatie op te halen

### Concrete GEO-aanpak
- herbekijk de AI-crawlerblokkades in `robots.txt`
- bouw FAQ-secties per hoofdservice
- voeg duidelijke definities, vergelijkingstabellen en samenvattingen toe
- maak pagina's met expliciete vraagstructuren zoals:
  - Wat kost een airco in Antwerpen?
  - Welke warmtepomp past bij een woning in Vlaams-Brabant?
  - Wanneer kies je voor ventilatie type D?

### Contentformats met hoge GEO-kans
- vergelijkingsartikels
- stappenplannen
- checklists
- service area pages met concrete bullets
- korte samenvattingen bovenaan belangrijke pagina's

---

## 16. 90-dagen roadmap

### Maand 1
- homepage title, meta en H1 herschrijven
- concrete copyfouten rechtzetten zoals `Uw betrouwbaar partner`, `Opzoek naar een ventilatie installateur?` en `gekwalificieerde professioneels die je bij staan`
- dubbele H1's wegwerken op `warmtepompen`, `ventilatie` en `airco-antwerpen`
- `LocalBusiness` of `HVACBusiness` schema toevoegen
- province page Antwerpen verbeteren
- nieuwe pagina `airco-provincie-vlaams-brabant` bouwen
- warmtepomp- en ventilatie-404-gaten oplossen met echte landingspagina's

### Maand 2
- `warmtepomp-antwerpen`
- `warmtepomp-provincie-vlaams-brabant`
- `ventilatie-antwerpen`
- `airco-leuven`
- `airco-vilvoorde`
- `airco-zaventem`
- FAQ-blokken op homepage en dienstpagina's

### Maand 3
- prijscontent
- keuzecontent
- onderhoudscontent per dienst
- eerste case pages
- interne linkblokken tussen blog, regio en dienst

### Daarna
- city pages rationaliseren: behouden, samenvoegen of `noindex` voor zwakke pagina's
- reviewstrategie regionaliseren
- backlinkcampagne starten
- meertalige content pas uitbreiden nadat de NL-core op orde is

---

## 17. Prioriteitenmatrix

| Prioriteit | Impact | Moeilijkheid | Opmerking |
| --- | --- | --- | --- |
| Homepage metadata en H1 verbeteren | hoog | laag | snelle winst |
| `warmtepomp-antwerpen` publiceren | hoog | laag | cruciale commerciële gap |
| `airco-provincie-vlaams-brabant` publiceren | hoog | laag | nodig voor targetregio |
| Schema uitbreiden naar `LocalBusiness` en `FAQPage` | hoog | middel | helpt local SEO en GEO |
| Trustindex en scripts optimaliseren | middel | middel | vooral mobiel belangrijk |
| Lokale airco-pagina's rationaliseren | hoog | hoog | belangrijk, maar vergt audit per pagina |
| Cases per regio bouwen | middel | middel | sterk voor vertrouwen |
| AI-crawlerbeleid in robots herzien | hoog | laag | directe GEO-impact |

---

## 18. Eindconclusie
FlowPlus heeft meer SEO-grondstof dan veel HVAC-bedrijven:
- veel URL's
- duidelijke diensten
- goede leadfocus
- zichtbaar lokaal adres en contact

Maar juist daardoor valt het onevenwicht sterker op. De site is vandaag te veel `airco-volume` en te weinig `regionale strategie`.

De belangrijkste strategische keuze voor FlowPlus is daarom niet `meer pagina's maken`, maar:
- prioriteit geven aan Antwerpen en Vlaams-Brabant
- warmtepompen en ventilatie even serieus nemen als airco
- technische en semantische kwaliteit optrekken
- de site ook geschikt maken voor AI discovery

Als FlowPlus die vier punten goed uitvoert, kan de bestaande basis veel meer renderen dan vandaag.
