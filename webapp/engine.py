from __future__ import annotations

import os
import re
import subprocess
import sys
import uuid
from dataclasses import asdict
from datetime import date
from pathlib import Path
from typing import Protocol

from .data_sources import RepoDataCollector
from .frameworks import FrameworkScorer
from .models import AuditIntake, AuditRecord
from .prompt_builder import PromptBuilder
from .skills import SkillResolver
from .storage import AuditStorage


class AuditModelClient(Protocol):
    def generate_markdown(self, prompt: str) -> str:
        ...


class OpenAIResponsesClient:
    model = "gpt-5.4"

    def __init__(self) -> None:
        self._client = None

    def generate_markdown(self, prompt: str) -> str:
        if self._client is None:
            try:
                from openai import OpenAI
            except ImportError as exc:  # pragma: no cover - dependency guard
                raise RuntimeError(
                    "De dependency 'openai' ontbreekt. Installeer requirements.txt voor de webapp."
                ) from exc
        if not os.getenv("OPENAI_API_KEY"):
            raise RuntimeError("OPENAI_API_KEY ontbreekt voor de Responses API.")
        if self._client is None:
            from openai import OpenAI

            self._client = OpenAI()
        response = self._client.responses.create(
            model=self.model,
            reasoning={"effort": "medium"},
            text={"verbosity": "high"},
            input=prompt,
        )
        output_text = getattr(response, "output_text", "")
        if output_text:
            return output_text.strip()
        raise RuntimeError("Geen tekstoutput teruggekregen van de Responses API.")


class SEOAuditEngine:
    def __init__(
        self,
        repo_root: Path,
        storage: AuditStorage,
        model_client: AuditModelClient,
    ) -> None:
        self.repo_root = repo_root
        self.storage = storage
        self.model_client = model_client
        self.skill_resolver = SkillResolver(repo_root)
        self.framework_scorer = FrameworkScorer(repo_root)
        self.prompt_builder = PromptBuilder(repo_root)
        self.data_collector = RepoDataCollector(repo_root)

    def new_record(self, intake: AuditIntake) -> AuditRecord:
        audit_id = uuid.uuid4().hex[:12]
        record = AuditRecord.create(audit_id, intake)
        self.storage.save(record)
        return record

    def run(self, audit_id: str) -> None:
        record = self.storage.load(audit_id)
        if record is None:
            return

        try:
            intake = AuditIntake.from_payload(record.intake)
            record.status = "running"
            record.append_progress("Audit gestart.")
            self.storage.save(record)

            skills = self.skill_resolver.resolve()
            frameworks = self.framework_scorer.resolve()
            record.selected_skills = [asdict(skill) for skill in skills]
            record.selected_frameworks = [asdict(framework) for framework in frameworks]
            record.append_progress("Relevante repo-skills en frameworks geselecteerd.")
            self.storage.save(record)

            tool_results = self.data_collector.collect(intake)
            record.tool_results = tool_results
            record.append_progress("Toolresultaten en websitedata verzameld.")
            self.storage.save(record)

            prompt = self.prompt_builder.build(intake, skills, frameworks, tool_results)
            record.append_progress("Prompt opgebouwd met AGENTS.md, masterprompt en skill bundle.")
            self.storage.save(record)

            markdown = self.model_client.generate_markdown(prompt)
            markdown_path = self._write_markdown(intake, markdown)
            record.markdown_content = markdown
            record.markdown_path = str(markdown_path)
            record.append_progress("Bronaudit als Markdown opgeslagen.")
            self.storage.save(record)

            if intake.publish_to_google_docs:
                record.export = self._publish_google_doc(markdown_path, intake)
                record.append_progress("Google Docs-export uitgevoerd.")

            record.status = "completed"
            record.touch()
            self.storage.save(record)
        except Exception as exc:  # pragma: no cover - integration path
            record.status = "failed"
            record.error = str(exc)
            record.append_progress("Audit mislukt.")
            self.storage.save(record)

    def export_existing(self, audit_id: str) -> AuditRecord:
        record = self.storage.load(audit_id)
        if record is None:
            raise FileNotFoundError("Audit niet gevonden.")
        if not record.markdown_path:
            raise ValueError("Audit heeft nog geen Markdown-bronbestand.")
        intake = AuditIntake.from_payload(record.intake)
        record.status = "exporting"
        record.append_progress("Google Docs-export gestart.")
        self.storage.save(record)
        record.export = self._publish_google_doc(Path(record.markdown_path), intake)
        record.status = "completed"
        record.touch()
        self.storage.save(record)
        return record

    def _write_markdown(self, intake: AuditIntake, markdown: str) -> Path:
        slug = self._slugify(intake.customer_name)
        filename = f"{slug}-seo-audit-{intake.audit_date or date.today().isoformat()}.md"
        path = self.repo_root / "seo-geo-delivery" / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(markdown.strip() + "\n", encoding="utf-8")
        return path

    def _publish_google_doc(self, markdown_path: Path, intake: AuditIntake) -> dict:
        command = [
            sys.executable,
            str(self.repo_root / "scripts/publish_markdown_to_google_docs.py"),
            str(markdown_path),
            "--name",
            f"{self._slugify(intake.customer_name)}-seo-audit-{intake.audit_date}",
        ]
        completed = subprocess.run(
            command,
            cwd=self.repo_root,
            check=False,
            capture_output=True,
            text=True,
        )
        if completed.returncode != 0:
            raise RuntimeError(completed.stderr.strip() or completed.stdout.strip() or "Google Docs-export mislukt.")

        export = {"status": "ok", "stdout": completed.stdout.strip()}
        for line in completed.stdout.splitlines():
            if line.startswith("Open: "):
                export["google_doc_url"] = line.replace("Open: ", "", 1).strip()
            elif line.startswith("File ID: "):
                export["google_doc_id"] = line.replace("File ID: ", "", 1).strip()
        return export

    def _slugify(self, value: str) -> str:
        normalized = value.lower().strip()
        normalized = re.sub(r"[^a-z0-9]+", "-", normalized)
        return normalized.strip("-") or "klant"
