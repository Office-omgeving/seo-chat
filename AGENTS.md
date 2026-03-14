# Agent instructions (scope: this directory and subdirectories)

## Scope and layout
- This AGENTS.md applies to the entire repository.
- Primary working directories:
  - `seo-geo-delivery/` for customer-facing source deliverables
  - `scripts/` for generation utilities
  - `output/` for generated exports that should stay out of Git
  - `tmp/` for local scratch files and experiments

## Repository purpose
- This repository is the shared source of truth for recurring SEO and GEO customer analyses.
- Prefer reusable source files in Markdown over one-off local documents.
- Optimize for Codex Cloud collaboration: future contributors should be able to open this repo and continue work without hidden local context.

## Customer analysis workflow
1. Inspect existing files for the customer before creating new deliverables.
2. Keep source deliverables in `seo-geo-delivery/` using a clear customer prefix.
3. Use Dutch by default for customer-facing outputs unless the request says otherwise.
4. Preserve previous analyses and add dated files when the work is a new audit snapshot.
5. Put generated exports in `output/` and temporary work in `tmp/`.

## Prompt workflow
- Use `prompts/masterprompt-seo-geo.md` as the default masterprompt for SEO and GEO audits unless the user explicitly asks for a different structure.
- Use `templates/customer-intake.md` to structure raw customer input when the request is still incomplete or informal.
- Use `templates/codex-audit-request.md` as the default copy-paste request format for account managers.
- If the user message is only `SEO` or clearly meant as a shortcut trigger for a new audit, do not start the audit immediately. First ask only for these 5 required fields: customer name, website URL, main services, target regions, and 2 to 3 competitors.
- After those 5 fields are provided, infer missing context where possible, run the default audit workflow, and publish the final client-facing document to Google Drive unless the user explicitly says not to.
- Before generating an audit, gather or infer the minimum client context: customer name, website, audit date, main services, target regions, relevant competitors, and account-manager notes.
- If some data is missing, make realistic assumptions and label them clearly in the output.
- Start from a source audit in Markdown, then derive client-facing versions and exports from that source file.
- Keep the source analysis substantive enough to support a client-ready document of roughly 30 to 40 pages once exported.

## Export workflow
- Prefer a source-of-truth audit in Markdown first, then export to DOCX or PDF.
- Use `scripts/export_to_google_docs.py` to upload a finished DOCX into Google Drive as a native Google Doc.
- Use `scripts/publish_markdown_to_google_docs.py` when the source audit is still in Markdown and should be published in one step.
- Use `scripts/setup_google_docs_local.py` as the default one-time setup step for each teammate on a new machine or fresh Codex environment.
- Load Google publishing defaults from `config/google-docs.env`, then allow `.env` to override locally if needed.
- When using a service account, make sure the target Drive folder is shared with that service account email before exporting.
- Default behavior for account-manager audit runs is to publish the final client-facing document to the configured Google Drive folder unless the user explicitly asks not to export yet.
- After publishing, always return the Google Doc link in the final response.
- Exception for the shortcut trigger flow: if the audit was launched through the `SEO` shortcut and the publish succeeded, keep the final user-facing response minimal and answer exactly: `Staat in de drive, succes!`
- This repo intentionally includes the shared Google Docs publishing configuration for the team. Treat `config/google-service-account.json` as sensitive and rotate it immediately if repo access changes unexpectedly.

## Naming conventions
- Use lowercase, hyphenated filenames.
- Prefer ISO dates in filenames for point-in-time audits.
- Keep customer names consistent across related files.

## Common deliverables
- Audit: `<customer>-seo-audit-YYYY-MM-DD.md`
- Plan: `<customer>-seo-geo-plan.md`
- Client version: `<customer>-seo-geo-klantversie.md`
- Presentation source: `presentation/<customer>-seo-audit-presentatie.js`
- Masterprompt: `prompts/masterprompt-seo-geo.md`

## Editing guidance
- Do not delete or rename existing customer files unless the user explicitly asks.
- If changing scripts, keep them reusable for future customers rather than hard-coding one-off paths when possible.
- Keep generated files out of Git unless the user explicitly wants them versioned.

## Verification
- For script edits, run targeted validation from the repo root:
  - `python3 -m py_compile scripts/*.py`
- If a script output format changes, mention which export should be regenerated for verification.

## Do not
- Do not commit `tmp/` or `output/`.
- Do not overwrite one customer's work with another customer's content.
- Do not assume a file is disposable just because it looks generated; check whether it is a source artifact first.
