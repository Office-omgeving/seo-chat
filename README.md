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
- `scripts/`
  Hulpscripts om leveringen zoals PDF, DOCX of klantpacks te genereren.
- `output/`
  Gegenereerde exports. Deze map staat in `.gitignore` en hoort niet in GitHub.
- `tmp/`
  Tijdelijke werkbestanden en lokale experimenten. Ook genegeerd in Git.

## Werken Met Codex Cloud
1. Open deze repo in Codex Cloud.
2. Geef de klantnaam, website en gewenste analyse-opdracht mee.
3. Laat Codex werken binnen de conventies uit `AGENTS.md`.
4. Review de Markdown-bronbestanden in `seo-geo-delivery/`.
5. Genereer indien nodig exports via de scripts.
6. Commit de bronwijzigingen terug naar GitHub.

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
