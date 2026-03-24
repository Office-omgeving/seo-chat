from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import date, datetime
from typing import Any


REQUIRED_LIST_FIELD_MIN_ITEMS = {
    "main_services": 1,
    "target_regions": 1,
    "competitors": 2,
}


def _clean_text(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip()


def normalize_text_list(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        raw_items = value.replace("\r", "\n").replace(",", "\n").split("\n")
    elif isinstance(value, list):
        raw_items = value
    else:
        raw_items = [value]

    cleaned: list[str] = []
    seen = set()
    for item in raw_items:
        text = _clean_text(item)
        if not text:
            continue
        lowered = text.lower()
        if lowered in seen:
            continue
        seen.add(lowered)
        cleaned.append(text)
    return cleaned


@dataclass
class AuditIntake:
    customer_name: str
    website_url: str
    audit_date: str
    main_services: list[str]
    target_regions: list[str]
    competitors: list[str]
    brand_primary_color: str
    brand_accent_color: str
    account_manager_notes: str = ""
    search_console_property: str = ""
    publish_to_google_docs: bool = False

    @classmethod
    def from_payload(cls, payload: dict[str, Any]) -> "AuditIntake":
        intake = cls(
            customer_name=_clean_text(payload.get("customer_name")),
            website_url=_clean_text(payload.get("website_url")),
            audit_date=_clean_text(payload.get("audit_date")) or date.today().isoformat(),
            main_services=normalize_text_list(payload.get("main_services")),
            target_regions=normalize_text_list(payload.get("target_regions")),
            competitors=normalize_text_list(payload.get("competitors")),
            brand_primary_color=_clean_text(payload.get("brand_primary_color")),
            brand_accent_color=_clean_text(payload.get("brand_accent_color")),
            account_manager_notes=_clean_text(payload.get("account_manager_notes")),
            search_console_property=_clean_text(payload.get("search_console_property")),
            publish_to_google_docs=bool(payload.get("publish_to_google_docs", False)),
        )
        intake.validate()
        return intake

    def validate(self) -> None:
        required_scalars = {
            "customer_name": self.customer_name,
            "website_url": self.website_url,
            "brand_primary_color": self.brand_primary_color,
            "brand_accent_color": self.brand_accent_color,
        }
        missing = [field_name for field_name, value in required_scalars.items() if not value]
        for field_name, minimum in REQUIRED_LIST_FIELD_MIN_ITEMS.items():
            values = getattr(self, field_name)
            if len(values) < minimum:
                missing.append(field_name)
        if missing:
            raise ValueError(f"Missing required intake fields: {', '.join(sorted(missing))}")

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class SkillBundle:
    slug: str
    title: str
    category: str
    path: str
    rationale: str
    summary: list[str]


@dataclass
class FrameworkBundle:
    slug: str
    title: str
    path: str
    summary: list[str]
    output_requirements: list[str]


@dataclass
class AuditRecord:
    audit_id: str
    created_at: str
    updated_at: str
    status: str
    intake: dict[str, Any]
    selected_skills: list[dict[str, Any]] = field(default_factory=list)
    selected_frameworks: list[dict[str, Any]] = field(default_factory=list)
    tool_results: dict[str, Any] = field(default_factory=dict)
    markdown_path: str = ""
    markdown_content: str = ""
    export: dict[str, Any] = field(default_factory=dict)
    error: str = ""
    progress: list[str] = field(default_factory=list)

    @classmethod
    def create(cls, audit_id: str, intake: AuditIntake) -> "AuditRecord":
        timestamp = datetime.utcnow().isoformat(timespec="seconds") + "Z"
        return cls(
            audit_id=audit_id,
            created_at=timestamp,
            updated_at=timestamp,
            status="queued",
            intake=intake.to_dict(),
            progress=["Audit aangemaakt."],
        )

    def touch(self) -> None:
        self.updated_at = datetime.utcnow().isoformat(timespec="seconds") + "Z"

    def append_progress(self, message: str) -> None:
        self.progress.append(message)
        self.touch()

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

