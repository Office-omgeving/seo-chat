from __future__ import annotations

import json
from pathlib import Path

from .models import AuditIntake, FrameworkBundle, SkillBundle


class PromptBuilder:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.agents_path = repo_root / "AGENTS.md"
        self.masterprompt_path = repo_root / "prompts/masterprompt-seo-geo.md"

    def _read_required_context(self) -> tuple[str, str]:
        return (
            self.agents_path.read_text(encoding="utf-8"),
            self.masterprompt_path.read_text(encoding="utf-8"),
        )

    def build(
        self,
        intake: AuditIntake,
        skills: list[SkillBundle],
        frameworks: list[FrameworkBundle],
        tool_results: dict,
    ) -> str:
        agents_text, masterprompt_text = self._read_required_context()
        skill_bundle = [
            {
                "slug": skill.slug,
                "title": skill.title,
                "category": skill.category,
                "rationale": skill.rationale,
                "summary": skill.summary,
            }
            for skill in skills
        ]
        framework_bundle = [
            {
                "slug": framework.slug,
                "title": framework.title,
                "summary": framework.summary,
                "output_requirements": framework.output_requirements,
            }
            for framework in frameworks
        ]

        sections = [
            "# Repo regels uit AGENTS.md",
            agents_text.strip(),
            "# Auditstructuur uit masterprompt",
            masterprompt_text.strip(),
            "# Genormaliseerde intake",
            json.dumps(intake.to_dict(), ensure_ascii=False, indent=2),
            "# Geselecteerde skill bundles",
            json.dumps(skill_bundle, ensure_ascii=False, indent=2),
            "# Framework scoring en outputvereisten",
            json.dumps(framework_bundle, ensure_ascii=False, indent=2),
            "# Toolresultaten en observaties",
            json.dumps(tool_results, ensure_ascii=False, indent=2),
            "# Strikte uitvoerinstructies",
            "\n".join(
                [
                    "- Produceer alleen Markdown voor een bronaudit in deze repo.",
                    "- Houd Nederlands als standaardtaal aan.",
                    "- Neem verplicht expliciete secties op met exact deze titels: `GEO`, `Concurrentie`, `Zoekwoordpotentie en huidige score`.",
                    "- Voeg ook expliciete scorecards toe voor `CORE-EEAT` en `CITE` met korte observaties en vermelde veto-items wanneer relevant.",
                    "- Als tooldata ontbreekt, benoem dat transparant en gebruik een realistische fallback in plaats van de sectie weg te laten.",
                    "- Gebruik AGENTS.md als hoogste prioriteit voor workflow, naamgeving, exports en responseformat.",
                    "- Gebruik skill bundles en frameworks voor diepgang, checklists en scores.",
                    "- Geef concrete voorbeelden, prioriteiten, quick wins en een actieplan.",
                    "- Retourneer geen JSON, geen code fences en geen toelichting buiten het auditdocument.",
                ]
            ),
        ]
        return "\n\n".join(sections)

