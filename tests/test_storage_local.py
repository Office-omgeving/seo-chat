from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from webapp.models import AuditIntake, AuditRecord
from webapp.storage import AuditStorage


class LocalAuditStorageTests(unittest.TestCase):
    def test_local_storage_roundtrip_without_supabase(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repo_root = Path(temp_dir)
            (repo_root / "tmp").mkdir(parents=True, exist_ok=True)
            storage = AuditStorage(repo_root)

            intake = AuditIntake.from_payload(
                {
                    "customer_name": "Test Klant",
                    "website_url": "https://example.com",
                    "audit_date": "2026-03-23",
                    "main_services": ["SEO"],
                    "target_regions": ["Antwerpen"],
                    "competitors": ["A", "B"],
                    "brand_primary_color": "#111111",
                    "brand_accent_color": "#222222",
                }
            )
            record = AuditRecord.create("abc123", intake)
            record.status = "running"
            storage.save(record)

            loaded = storage.load("abc123")
            self.assertIsNotNone(loaded)
            assert loaded is not None
            self.assertEqual("running", loaded.status)
            self.assertEqual("local", storage.backend_label)


if __name__ == "__main__":
    unittest.main()
