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

## Naming conventions
- Use lowercase, hyphenated filenames.
- Prefer ISO dates in filenames for point-in-time audits.
- Keep customer names consistent across related files.

## Common deliverables
- Audit: `<customer>-seo-audit-YYYY-MM-DD.md`
- Plan: `<customer>-seo-geo-plan.md`
- Client version: `<customer>-seo-geo-klantversie.md`
- Presentation source: `presentation/<customer>-seo-audit-presentatie.js`

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
