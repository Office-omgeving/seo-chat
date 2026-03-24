from __future__ import annotations

import json
import os
import threading
from pathlib import Path

from .models import AuditRecord


class LocalAuditStore:
    def __init__(self, repo_root: Path):
        self.audit_dir = repo_root / "tmp" / "audits"
        self.audit_dir.mkdir(parents=True, exist_ok=True)

    def _record_path(self, audit_id: str) -> Path:
        return self.audit_dir / f"{audit_id}.json"

    def save(self, record: AuditRecord) -> None:
        path = self._record_path(record.audit_id)
        path.write_text(json.dumps(record.to_dict(), indent=2, ensure_ascii=False), encoding="utf-8")

    def load(self, audit_id: str) -> AuditRecord | None:
        path = self._record_path(audit_id)
        if not path.exists():
            return None
        payload = json.loads(path.read_text(encoding="utf-8"))
        return AuditRecord(**payload)


class SupabaseAuditStore:
    def __init__(self, url: str, service_role_key: str, table_name: str):
        try:
            from supabase import create_client
        except ImportError as exc:  # pragma: no cover - dependency guard
            raise RuntimeError(
                "De dependency 'supabase' ontbreekt. Installeer requirements.txt voor Supabase-opslag."
            ) from exc

        self.table_name = table_name
        self.client = create_client(url, service_role_key)

    def save(self, record: AuditRecord) -> None:
        payload = record.to_dict()
        response = (
            self.client.table(self.table_name)
            .upsert(payload, on_conflict="audit_id")
            .execute()
        )
        if getattr(response, "data", None) is None:
            raise RuntimeError("Supabase upsert gaf geen data terug.")

    def load(self, audit_id: str) -> AuditRecord | None:
        response = (
            self.client.table(self.table_name)
            .select("*")
            .eq("audit_id", audit_id)
            .limit(1)
            .execute()
        )
        rows = getattr(response, "data", None) or []
        if not rows:
            return None
        return AuditRecord(**rows[0])


class AuditStorage:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.local_store = LocalAuditStore(repo_root)
        self._lock = threading.Lock()
        self.remote_store = self._build_remote_store()
        self._backend_label = "local+supabase" if self.remote_store is not None else "local"
        self._remote_error = ""

    def _build_remote_store(self) -> SupabaseAuditStore | None:
        url = os.getenv("SUPABASE_URL", "").strip()
        service_role_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "").strip()
        table_name = os.getenv("SUPABASE_AUDITS_TABLE", "seo_geo_audits").strip() or "seo_geo_audits"
        if not url or not service_role_key:
            return None
        return SupabaseAuditStore(url, service_role_key, table_name)

    @property
    def backend_label(self) -> str:
        return self._backend_label

    @property
    def remote_error(self) -> str:
        return self._remote_error

    def supabase_enabled(self) -> bool:
        return self.remote_store is not None

    def status(self) -> dict[str, str | bool]:
        return {
            "backend": self.backend_label,
            "supabase_enabled": self.supabase_enabled(),
            "remote_error": self.remote_error,
        }

    def save(self, record: AuditRecord) -> None:
        with self._lock:
            self.local_store.save(record)
            if self.remote_store is not None:
                try:
                    self.remote_store.save(record)
                    self._remote_error = ""
                except Exception as exc:  # pragma: no cover - network integration
                    self._remote_error = str(exc)

    def load(self, audit_id: str) -> AuditRecord | None:
        if self.remote_store is not None:
            try:
                record = self.remote_store.load(audit_id)
            except Exception as exc:  # pragma: no cover - network integration
                self._remote_error = str(exc)
            else:
                if record is not None:
                    self.local_store.save(record)
                    self._remote_error = ""
                    return record
        return self.local_store.load(audit_id)
