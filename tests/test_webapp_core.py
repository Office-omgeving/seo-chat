from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from webapp.frameworks import FrameworkScorer
from webapp.models import AuditIntake
from webapp.prompt_builder import PromptBuilder
from webapp.skills import SkillResolver


REPO_ROOT = Path(__file__).resolve().parents[1]


class SkillResolverTests(unittest.TestCase):
    def test_resolves_relevant_skills(self) -> None:
        resolver = SkillResolver(REPO_ROOT)
        bundles = resolver.resolve()
        self.assertEqual(4, len(bundles))
        self.assertEqual(
            ["keyword-research", "competitor-analysis", "technical-seo-checker", "geo-content-optimizer"],
            [bundle.slug for bundle in bundles],
        )


class FrameworkScorerTests(unittest.TestCase):
    def test_resolves_frameworks(self) -> None:
        scorer = FrameworkScorer(REPO_ROOT)
        bundles = scorer.resolve()
        self.assertEqual(["core-eeat", "cite"], [bundle.slug for bundle in bundles])


class PromptBuilderTests(unittest.TestCase):
    def test_prompt_contains_expected_sections_and_order(self) -> None:
        intake = AuditIntake.from_payload(
            {
                "customer_name": "Voorbeeld",
                "website_url": "https://example.com",
                "audit_date": "2026-03-23",
                "main_services": ["SEO"],
                "target_regions": ["Antwerpen"],
                "competitors": ["Concurrent 1", "Concurrent 2"],
                "brand_primary_color": "#17162C",
                "brand_accent_color": "#6B7388",
            }
        )
        prompt_builder = PromptBuilder(REPO_ROOT)
        skills = SkillResolver(REPO_ROOT).resolve()
        frameworks = FrameworkScorer(REPO_ROOT).resolve()
        prompt = prompt_builder.build(intake, skills, frameworks, {"keyword_data": {"status": "unavailable"}})
        headings = [
            "# Repo regels uit AGENTS.md",
            "# Auditstructuur uit masterprompt",
            "# Genormaliseerde intake",
            "# Geselecteerde skill bundles",
            "# Framework scoring en outputvereisten",
            "# Toolresultaten en observaties",
            "# Strikte uitvoerinstructies",
        ]
        positions = [prompt.index(heading) for heading in headings]
        self.assertEqual(positions, sorted(positions))
        self.assertIn("`GEO`", prompt)
        self.assertIn("`Concurrentie`", prompt)
        self.assertIn("`Zoekwoordpotentie en huidige score`", prompt)


if __name__ == "__main__":
    unittest.main()
