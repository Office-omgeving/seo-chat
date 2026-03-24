from __future__ import annotations

import re
from pathlib import Path

from .models import SkillBundle


RELEVANT_SKILLS = [
    {
        "slug": "keyword-research",
        "title": "Keyword Research",
        "category": "research",
        "relative_path": "skills/research/keyword-research/SKILL.md",
        "rationale": "Gebruik voor zoekwoordpotentie, intentclassificatie en kansrijke clusters.",
    },
    {
        "slug": "competitor-analysis",
        "title": "Competitor Analysis",
        "category": "research",
        "relative_path": "skills/research/competitor-analysis/SKILL.md",
        "rationale": "Gebruik voor de verplichte concurrentiesectie en vergelijkingsmatrix.",
    },
    {
        "slug": "technical-seo-checker",
        "title": "Technical SEO Checker",
        "category": "optimize",
        "relative_path": "skills/optimize/technical-seo-checker/SKILL.md",
        "rationale": "Gebruik voor technische audit, Core Web Vitals en crawl/indexatie-checks.",
    },
    {
        "slug": "geo-content-optimizer",
        "title": "GEO Content Optimizer",
        "category": "build",
        "relative_path": "skills/build/geo-content-optimizer/SKILL.md",
        "rationale": "Gebruik voor GEO- en AI-citatie-analyse in een aparte sectie.",
    },
]


def _extract_frontmatter_value(text: str, key: str) -> str:
    match = re.search(rf"^{re.escape(key)}:\s*(.+)$", text, flags=re.MULTILINE)
    if not match:
        return ""
    value = match.group(1).strip().strip("'").strip('"')
    return value


def _extract_heading_block(text: str, heading: str) -> list[str]:
    lines = text.splitlines()
    capture = False
    collected: list[str] = []
    heading_line = heading.strip().lower()
    for line in lines:
        if line.strip().lower() == heading_line:
            capture = True
            continue
        if capture and line.startswith("## "):
            break
        if capture:
            collected.append(line.rstrip())
    return collected


def _extract_bullets(block_lines: list[str], limit: int) -> list[str]:
    bullets: list[str] = []
    for line in block_lines:
        stripped = line.strip()
        if stripped.startswith(("- ", "* ")):
            bullets.append(stripped[2:].strip())
        elif re.match(r"^\d+\.\s+", stripped):
            bullets.append(re.sub(r"^\d+\.\s+", "", stripped))
        if len(bullets) >= limit:
            break
    return bullets


def _summarize_skill(path: Path) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    summary: list[str] = []
    description = _extract_frontmatter_value(raw, "description")
    if description:
        summary.append(description)

    for heading in ("## What This Skill Does", "## Instructions", "## When to Use This Skill"):
        bullets = _extract_bullets(_extract_heading_block(raw, heading), limit=4)
        for bullet in bullets:
            if bullet not in summary:
                summary.append(bullet)
        if len(summary) >= 6:
            break
    return summary[:6]


class SkillResolver:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root

    def resolve(self) -> list[SkillBundle]:
        bundles: list[SkillBundle] = []
        for item in RELEVANT_SKILLS:
            path = self.repo_root / item["relative_path"]
            if not path.exists():
                continue
            bundles.append(
                SkillBundle(
                    slug=item["slug"],
                    title=item["title"],
                    category=item["category"],
                    path=str(path),
                    rationale=item["rationale"],
                    summary=_summarize_skill(path),
                )
            )
        return bundles

