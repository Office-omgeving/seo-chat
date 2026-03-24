from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from html import unescape
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin
from urllib.request import Request, urlopen

from .models import AuditIntake


USER_AGENT = "SEO-CHAT-Webapp/1.0 (+https://openai.com)"


def _safe_json_from_stdout(stdout: str) -> dict:
    try:
        return json.loads(stdout)
    except json.JSONDecodeError:
        return {"status": "error", "message": "Kon JSON-output niet parsen.", "raw_output": stdout}


class RepoDataCollector:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root

    def collect(self, intake: AuditIntake) -> dict:
        return {
            "website_snapshot": self.collect_website_snapshot(intake.website_url),
            "keyword_data": self.collect_keyword_data(intake),
            "search_console": self.collect_search_console(intake),
        }

    def _run_script(self, relative_path: str, args: list[str]) -> dict:
        command = [sys.executable, str(self.repo_root / relative_path), *args]
        completed = subprocess.run(
            command,
            cwd=self.repo_root,
            check=False,
            capture_output=True,
            text=True,
        )
        if completed.returncode != 0:
            return {
                "status": "error",
                "command": command,
                "stderr": completed.stderr.strip(),
                "stdout": completed.stdout.strip(),
            }
        payload = _safe_json_from_stdout(completed.stdout)
        payload["status"] = "ok"
        return payload

    def collect_keyword_data(self, intake: AuditIntake) -> dict:
        if not os.getenv("GOOGLE_ADS_CUSTOMER_ID") or not os.getenv("GOOGLE_ADS_CONFIGURATION_FILE_PATH"):
            return {
                "status": "unavailable",
                "message": "Google Ads-config ontbreekt; keyword-data wordt niet automatisch verrijkt.",
            }

        seeds: list[str] = []
        for service in intake.main_services[:4]:
            seeds.append(service)
            for region in intake.target_regions[:2]:
                seeds.append(f"{service} {region}")
        unique_seeds = []
        seen = set()
        for seed in seeds:
            lowered = seed.lower()
            if lowered in seen:
                continue
            seen.add(lowered)
            unique_seeds.append(seed)
        return self._run_script(
            "scripts/fetch_google_ads_keyword_data.py",
            [*unique_seeds[:8], "--format", "json", "--preset", "be-nl"],
        )

    def collect_search_console(self, intake: AuditIntake) -> dict:
        property_uri = intake.search_console_property or os.getenv("GOOGLE_SEARCH_CONSOLE_PROPERTY", "")
        has_credentials = os.getenv("GOOGLE_SERVICE_ACCOUNT_FILE") or os.getenv("GOOGLE_OAUTH_CLIENT_SECRET_FILE")
        if not property_uri or not has_credentials:
            return {
                "status": "unavailable",
                "message": "Search Console-property of credentials ontbreken; deze laag is optioneel.",
            }
        return self._run_script(
            "scripts/fetch_search_console.py",
            [
                property_uri,
                "--dimensions",
                "query",
                "--row-limit",
                "25",
                "--format",
                "json",
            ],
        )

    def collect_website_snapshot(self, website_url: str) -> dict:
        normalized_url = website_url.strip()
        if not normalized_url:
            return {"status": "unavailable", "message": "Geen website-URL opgegeven."}

        try:
            html = self._fetch_text(normalized_url)
        except Exception as exc:  # pragma: no cover - network variability
            return {
                "status": "error",
                "message": f"Kon website niet ophalen: {exc}",
                "url": normalized_url,
            }

        robots_url = urljoin(normalized_url, "/robots.txt")
        sitemap_url = urljoin(normalized_url, "/sitemap.xml")
        snapshot = {
            "status": "ok",
            "url": normalized_url,
            "title": self._extract_title(html),
            "meta_description": self._extract_meta_description(html),
            "h1_headings": self._extract_h1s(html),
            "robots": self._fetch_optional_text(robots_url),
            "sitemap_exists": self._url_exists(sitemap_url),
        }
        return snapshot

    def _fetch_text(self, url: str) -> str:
        request = Request(url, headers={"User-Agent": USER_AGENT})
        with urlopen(request, timeout=15) as response:  # nosec B310
            charset = response.headers.get_content_charset() or "utf-8"
            return response.read().decode(charset, errors="replace")

    def _fetch_optional_text(self, url: str) -> dict:
        try:
            content = self._fetch_text(url)
        except (HTTPError, URLError, TimeoutError):  # pragma: no cover - network variability
            return {"status": "missing", "url": url}
        return {"status": "ok", "url": url, "content": content[:4000]}

    def _url_exists(self, url: str) -> bool:
        try:
            request = Request(url, headers={"User-Agent": USER_AGENT})
            with urlopen(request, timeout=10):  # nosec B310
                return True
        except Exception:  # pragma: no cover - network variability
            return False

    def _extract_title(self, html: str) -> str:
        match = re.search(r"<title[^>]*>(.*?)</title>", html, flags=re.IGNORECASE | re.DOTALL)
        return self._strip_html(match.group(1)) if match else ""

    def _extract_meta_description(self, html: str) -> str:
        match = re.search(
            r'<meta[^>]+name=["\']description["\'][^>]+content=["\'](.*?)["\']',
            html,
            flags=re.IGNORECASE | re.DOTALL,
        )
        if not match:
            match = re.search(
                r'<meta[^>]+content=["\'](.*?)["\'][^>]+name=["\']description["\']',
                html,
                flags=re.IGNORECASE | re.DOTALL,
            )
        return self._strip_html(match.group(1)) if match else ""

    def _extract_h1s(self, html: str) -> list[str]:
        matches = re.findall(r"<h1[^>]*>(.*?)</h1>", html, flags=re.IGNORECASE | re.DOTALL)
        headings: list[str] = []
        for match in matches:
            heading = self._strip_html(match)
            if heading:
                headings.append(heading)
        return headings[:5]

    def _strip_html(self, value: str) -> str:
        text = re.sub(r"<[^>]+>", " ", value)
        text = unescape(text)
        return " ".join(text.split())

