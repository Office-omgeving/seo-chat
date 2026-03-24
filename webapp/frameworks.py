from __future__ import annotations

from pathlib import Path

from .models import FrameworkBundle


class FrameworkScorer:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root

    def resolve(self) -> list[FrameworkBundle]:
        core_path = self.repo_root / "skills/references/core-eeat-benchmark.md"
        cite_path = self.repo_root / "skills/references/cite-domain-rating.md"

        frameworks: list[FrameworkBundle] = []
        if core_path.exists():
            frameworks.append(
                FrameworkBundle(
                    slug="core-eeat",
                    title="CORE-EEAT",
                    path=str(core_path),
                    summary=[
                        "Beoordeel contentkwaliteit over 8 dimensies: C, O, R, E, Exp, Ept, A en T.",
                        "Gebruik per item de schaal pass=10, partial=5, fail=0.",
                        "Bereken GEO Score als gemiddelde van C, O, R en E.",
                        "Bereken SEO Score als gemiddelde van Exp, Ept, A en T.",
                        "Veto-items: C01, R10 en T04 cappen de totaalscore op Low.",
                    ],
                    output_requirements=[
                        "Neem een expliciete CORE-EEAT scorecard op met dimensiescores en korte observaties.",
                        "Label contentrisico's en veto-items expliciet wanneer relevant.",
                    ],
                )
            )
        if cite_path.exists():
            frameworks.append(
                FrameworkBundle(
                    slug="cite",
                    title="CITE",
                    path=str(cite_path),
                    summary=[
                        "Beoordeel domeinautoriteit over 4 dimensies: Citation, Identity, Trust en Eminence.",
                        "Gebruik per item de schaal pass=10, partial=5, fail=0.",
                        "Bereken CITE Score gewogen: C x 0.35, I x 0.20, T x 0.25, E x 0.20.",
                        "Veto-items: T03, T05 en T09 triggeren een Manipulation Alert en cap op Poor.",
                        "Gebruik CITE samen met CORE-EEAT om inhoud en domein als bron te beoordelen.",
                    ],
                    output_requirements=[
                        "Neem een expliciete CITE scorecard op met dimensiescores en korte observaties.",
                        "Noem vertrouwen-, entiteit- en autoriteitssignalen apart van contentkwaliteit.",
                    ],
                )
            )
        return frameworks

