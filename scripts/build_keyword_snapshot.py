from __future__ import annotations

import argparse
import csv
import json
import os
import re
import urllib.parse
import urllib.request
from dataclasses import dataclass
from html import unescape
from pathlib import Path

from fetch_google_ads_keyword_data import (
    fetch_historical_metrics,
    fetch_keyword_ideas,
    load_client,
    resolve_targeting,
)


DEFAULT_ROW_LIMIT = 20
DEFAULT_IDEA_LIMIT = 80
USER_AGENT = "Mozilla/5.0 (compatible; SEO-CHAT/1.0; +https://example.com/bot)"


@dataclass
class KeywordRow:
    keyword: str
    avg_monthly_searches: int
    competition: str
    current_visibility: str
    ranking_url: str
    source_note: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Build an audit-ready keyword snapshot from website, services and regions. "
            "This script automates keyword discovery, Google Ads monthly volumes and live visibility checks."
        )
    )
    parser.add_argument("--website", required=True, help="Customer website URL")
    parser.add_argument(
        "--services",
        required=True,
        help="Comma-separated main services or themes, for example 'vochtbestrijding,opstijgend vocht'",
    )
    parser.add_argument(
        "--regions",
        default="",
        help="Optional comma-separated regions, for example 'Vlaanderen,Oost-Vlaanderen,West-Vlaanderen'",
    )
    parser.add_argument(
        "--competitors",
        default="",
        help="Optional comma-separated competitor URLs or brand names. Used only as extra context in output metadata.",
    )
    parser.add_argument(
        "--seed-keywords",
        default="",
        help="Optional extra comma-separated seed keywords.",
    )
    parser.add_argument(
        "--preset",
        default="be-nl",
        choices=("be-nl", "be-fr", "nl-nl", "fr-fr"),
        help="Google Ads language + geo preset.",
    )
    parser.add_argument(
        "--customer-id",
        default=None,
        help="Optional Google Ads customer ID override.",
    )
    parser.add_argument(
        "--config-file",
        default=None,
        help="Optional google-ads.yaml override.",
    )
    parser.add_argument(
        "--top-n",
        type=int,
        default=DEFAULT_ROW_LIMIT,
        help="Number of enriched keywords to keep in the final output.",
    )
    parser.add_argument(
        "--idea-limit",
        type=int,
        default=DEFAULT_IDEA_LIMIT,
        help="How many keyword ideas to request before filtering and ranking.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional output path. Supports .json, .csv or .md.",
    )
    parser.add_argument(
        "--format",
        choices=("table", "json", "csv", "markdown"),
        default="table",
        help="Output format when --output is omitted.",
    )
    return parser.parse_args()


def parse_csv_items(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


def fetch_url(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=20) as response:
        return response.read().decode("utf-8", errors="ignore")


def strip_html(text: str) -> str:
    return " ".join(unescape(re.sub(r"<[^>]+>", " ", text)).split())


def extract_page_text_signals(html: str) -> list[str]:
    signals: list[str] = []
    title_match = re.search(r"<title[^>]*>(.*?)</title>", html, re.I | re.S)
    if title_match:
        signals.append(strip_html(title_match.group(1)))
    for pattern in (
        r"<h1[^>]*>(.*?)</h1>",
        r'<meta[^>]+name=["\']description["\'][^>]+content=["\'](.*?)["\']',
    ):
        for match in re.finditer(pattern, html, re.I | re.S):
            signals.append(strip_html(match.group(1)))
    return [signal for signal in signals if signal]


def build_seed_keywords(website: str, services: list[str], regions: list[str], extra_keywords: list[str]) -> list[str]:
    seeds: list[str] = []
    seeds.extend(services)
    seeds.extend(extra_keywords)

    for service in services:
        for region in regions:
            seeds.append(f"{service} {region}")

    try:
        html = fetch_url(website)
        seeds.extend(extract_page_text_signals(html))
    except Exception:
        pass

    cleaned: list[str] = []
    seen = set()
    for seed in seeds:
        normalized = re.sub(r"\s+", " ", seed).strip()
        lowered = normalized.lower()
        if not normalized or lowered in seen:
            continue
        seen.add(lowered)
        cleaned.append(normalized)
    return cleaned


def keyword_relevance_score(keyword: str, services: list[str], regions: list[str]) -> tuple[int, int]:
    lowered = keyword.lower()
    service_hits = sum(1 for service in services if service.lower() in lowered)
    region_hits = sum(1 for region in regions if region.lower() in lowered)
    return service_hits, region_hits


def select_shortlist(idea_rows: list[dict], services: list[str], regions: list[str], top_n: int) -> list[str]:
    ranked = []
    for row in idea_rows:
        keyword = row.get("keyword", "").strip()
        if not keyword:
            continue
        service_hits, region_hits = keyword_relevance_score(keyword, services, regions)
        if service_hits == 0:
            continue
        ranked.append(
            (
                service_hits,
                region_hits,
                int(row.get("avg_monthly_searches", 0) or 0),
                keyword,
            )
        )

    ranked.sort(key=lambda item: (item[0], item[1], item[2], -len(item[3])), reverse=True)

    shortlist: list[str] = []
    seen = set()
    for _, _, _, keyword in ranked:
        lowered = keyword.lower()
        if lowered in seen:
            continue
        seen.add(lowered)
        shortlist.append(keyword)
        if len(shortlist) >= top_n:
            break
    return shortlist


def extract_domain(url: str) -> str:
    parsed = urllib.parse.urlparse(url)
    return parsed.netloc.lower().removeprefix("www.")


def live_visibility_check(keyword: str, website: str) -> tuple[str, str, str]:
    domain = extract_domain(website)
    query_url = "https://html.duckduckgo.com/html/?q=" + urllib.parse.quote(keyword)
    request = urllib.request.Request(query_url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=20) as response:
        html = response.read().decode("utf-8", errors="ignore")

    pattern = re.compile(r'<a rel="nofollow" class="result__a" href="(.*?)">(.*?)</a>', re.S)
    matches = pattern.findall(html)[:10]
    for index, (href, _title) in enumerate(matches, start=1):
        resolved_href = unescape(href)
        target = urllib.parse.urlparse(resolved_href)
        raw = urllib.parse.parse_qs(target.query).get("uddg", [""])[0] or resolved_href
        if extract_domain(raw) == domain:
            return (
                f"positie {index} in waargenomen top 10",
                raw,
                "waargenomen live SERP-check",
            )
    return (
        "niet zichtbaar in waargenomen top 10",
        "",
        "waargenomen live SERP-check",
    )


def build_rows(historical_rows: list[dict], website: str) -> list[KeywordRow]:
    result: list[KeywordRow] = []
    for row in historical_rows:
        visibility, ranking_url, source_note = live_visibility_check(row["keyword"], website)
        result.append(
            KeywordRow(
                keyword=row["keyword"],
                avg_monthly_searches=int(row.get("avg_monthly_searches", 0) or 0),
                competition=row.get("competition", ""),
                current_visibility=visibility,
                ranking_url=ranking_url,
                source_note=source_note,
            )
        )
    return result


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def write_csv(path: Path, rows: list[KeywordRow]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "keyword",
                "avg_monthly_searches",
                "competition",
                "current_visibility",
                "ranking_url",
                "source_note",
            ],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(row.__dict__)


def build_markdown(rows: list[KeywordRow]) -> str:
    lines = [
        "| Keyword | Zoekvolume per maand | Huidige positie / zichtbaarheid | Ranking URL | Bron |",
        "| --- | --- | --- | --- | --- |",
    ]
    for row in rows:
        ranking_url = row.ranking_url or "-"
        lines.append(
            f"| `{row.keyword}` | {row.avg_monthly_searches} | {row.current_visibility} | {ranking_url} | {row.source_note} |"
        )
    return "\n".join(lines)


def print_table(rows: list[KeywordRow]) -> None:
    columns = ["keyword", "avg_monthly_searches", "competition", "current_visibility"]
    widths = {column: len(column) for column in columns}
    for row in rows:
        values = {
            "keyword": row.keyword,
            "avg_monthly_searches": str(row.avg_monthly_searches),
            "competition": row.competition,
            "current_visibility": row.current_visibility,
        }
        for column in columns:
            widths[column] = max(widths[column], len(values[column]))

    header = " | ".join(column.ljust(widths[column]) for column in columns)
    separator = "-+-".join("-" * widths[column] for column in columns)
    print(header)
    print(separator)
    for row in rows:
        values = {
            "keyword": row.keyword,
            "avg_monthly_searches": str(row.avg_monthly_searches),
            "competition": row.competition,
            "current_visibility": row.current_visibility,
        }
        print(" | ".join(values[column].ljust(widths[column]) for column in columns))


def main() -> None:
    args = parse_args()
    services = parse_csv_items(args.services)
    regions = parse_csv_items(args.regions)
    extra_keywords = parse_csv_items(args.seed_keywords)
    competitors = parse_csv_items(args.competitors)
    customer_id = args.customer_id or os.getenv("GOOGLE_ADS_CUSTOMER_ID")
    config_file = args.config_file or os.getenv("GOOGLE_ADS_CONFIGURATION_FILE_PATH")

    if not services:
        raise SystemExit("Pass at least one service via --services.")
    if not customer_id:
        raise SystemExit("Missing Google Ads customer ID. Pass --customer-id or set GOOGLE_ADS_CUSTOMER_ID.")
    if not config_file:
        raise SystemExit(
            "Missing Google Ads config file. Pass --config-file or set GOOGLE_ADS_CONFIGURATION_FILE_PATH."
        )
    if args.top_n <= 0:
        raise SystemExit("--top-n must be greater than 0.")
    if args.idea_limit <= 0:
        raise SystemExit("--idea-limit must be greater than 0.")

    client = load_client(config_file)
    language_id, geo_target_ids = resolve_targeting(args)

    seed_keywords = build_seed_keywords(args.website, services, regions, extra_keywords)
    idea_payload = fetch_keyword_ideas(
        client=client,
        customer_id=customer_id,
        seed_url=args.website,
        seed_keywords=seed_keywords,
        language_id=language_id,
        geo_target_ids=geo_target_ids,
        row_limit=args.idea_limit,
    )
    shortlist = select_shortlist(idea_payload["rows"], services, regions, args.top_n)
    historical_payload = fetch_historical_metrics(
        client=client,
        customer_id=customer_id,
        keywords=shortlist,
        language_id=language_id,
        geo_target_ids=geo_target_ids,
        include_average_cpc=False,
    )
    rows = build_rows(historical_payload["rows"], args.website)

    payload = {
        "website": args.website,
        "services": services,
        "regions": regions,
        "competitors": competitors,
        "seed_keywords": seed_keywords,
        "shortlist": shortlist,
        "rows": [row.__dict__ for row in rows],
    }

    if args.output:
        suffix = args.output.suffix.lower()
        if suffix == ".json":
            write_json(args.output, payload)
        elif suffix == ".csv":
            write_csv(args.output, rows)
        elif suffix == ".md":
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(build_markdown(rows), encoding="utf-8")
        else:
            raise SystemExit("Unsupported output extension. Use .json, .csv or .md.")
        print(f"Wrote keyword snapshot to: {args.output}")
        return

    if args.format == "json":
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        return
    if args.format == "csv":
        writer = csv.writer(__import__("sys").stdout)
        writer.writerow(
            ["keyword", "avg_monthly_searches", "competition", "current_visibility", "ranking_url", "source_note"]
        )
        for row in rows:
            writer.writerow(
                [
                    row.keyword,
                    row.avg_monthly_searches,
                    row.competition,
                    row.current_visibility,
                    row.ranking_url,
                    row.source_note,
                ]
            )
        return
    if args.format == "markdown":
        print(build_markdown(rows))
        return

    print_table(rows)


if __name__ == "__main__":
    main()
