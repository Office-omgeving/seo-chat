# SEO-CHAT

Gedeelde werkrepo voor SEO- en GEO-klantanalyses. Dit project is bedoeld als vaste GitHub-bron die we in Codex Cloud kunnen openen, zodat iedereen dezelfde context, structuur en werkwijze gebruikt.

## Doel
- klantanalyses centraal bewaren in een vast GitHub-project
- Codex Cloud altijd tegen dezelfde repo laten werken
- analyses, plannen en klantversies reproduceerbaar maken
- scripts en bronbestanden delen zonder lokale machine-afhankelijkheid

## Structuur
- `seo-geo-delivery/`
  Bronbestanden per klant: audits, plannen, klantversies, copy, operations en presentaties.
- `prompts/`
  Vaste masterprompts voor terugkerende analyse-opdrachten.
- `scripts/`
  Hulpscripts om leveringen zoals PDF, DOCX of klantpacks te genereren.
- `output/`
  Gegenereerde exports. Deze map staat in `.gitignore` en hoort niet in GitHub.
- `tmp/`
  Tijdelijke werkbestanden en lokale experimenten. Ook genegeerd in Git.

## Werken Met Codex Cloud
1. Open deze repo in Codex Cloud.
2. Geef minimaal klantnaam, website, auditdatum, hoofddiensten, doelregio's, concurrenten en extra context mee.
3. Laat Codex werken vanuit `prompts/masterprompt-seo-geo.md` en binnen de conventies uit `AGENTS.md`.
4. Laat de bronanalyse eerst als Markdown opbouwen in `seo-geo-delivery/`.
5. Review daarna de audit en maak indien nodig een klantversie of export via de scripts.
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
- extra context of commerciële aandachtspunten

Handige templates:
- `templates/customer-intake.md`
- `templates/codex-audit-request.md`

## Accountmanager flow
Voor een zo eenvoudig mogelijke flow:
1. Vul `templates/customer-intake.md` in of gebruik `templates/codex-audit-request.md` als copy-paste prompt.
2. Geef die input in Codex.
3. Laat Codex de audit opbouwen in `seo-geo-delivery/`.
4. Laat Codex de eindversie standaard publiceren naar de ingestelde Google Docs map.
5. Gebruik de teruggegeven Google Doc-link om het klantdocument te openen.

Shortcut flow voor accountmanagers:
1. Typ enkel `SEO`.
2. Codex vraagt dan automatisch alleen deze 5 zaken:
   - klantnaam
   - website URL
   - hoofddiensten
   - doelregio's
   - 2 tot 3 concurrenten
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

Opmerking:
- bij een service account moet de doelmap in Google Drive expliciet gedeeld zijn met het service account e-mailadres
- OAuth is meestal het eenvoudigst als dezelfde gebruiker al toegang heeft tot de map
- voor een echt dummy-proof teamflow is een service account meestal het sterkst, omdat dan niet elke gebruiker apart hoeft in te loggen
- deze repo bevat bewust een gedeelde service-account key voor deze ene Drive-flow; behandel repo-toegang dus als toegang tot die map en roteer de key als teamtoegang verandert

## Bestandsconventies
- Gebruik bestandsnamen met klantprefix en datum in ISO-formaat.
- Bewaar de bronanalyse in Markdown; binaries zijn afgeleid en kunnen opnieuw gegenereerd worden.
- Laat bestaande klantbestanden staan tenzij er expliciet om vervanging gevraagd wordt.

Voorbeelden:
- `seo-geo-delivery/favorcool-seo-audit-2026-03-14.md`
- `seo-geo-delivery/favorcool-seo-geo-klantversie.md`
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
