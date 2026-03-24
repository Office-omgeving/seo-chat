from __future__ import annotations

import argparse
import csv
import json
import os
from pathlib import Path


DEFAULT_ROW_LIMIT = 100
PRESETS = {
    "be-nl": {"language_id": "1010", "geo_target_ids": ["70301"]},
    "be-fr": {"language_id": "1002", "geo_target_ids": ["70301"]},
    "nl-nl": {"language_id": "1010", "geo_target_ids": ["1023191"]},
    "fr-fr": {"language_id": "1002", "geo_target_ids": ["2250"]},
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Fetch keyword volumes or keyword ideas from Google Ads Keyword Planner. "
            "Uses one shared Google Ads setup instead of per-customer Search Console access."
        )
    )
    parser.add_argument(
        "keywords",
        nargs="*",
        help="Optional explicit keywords. If omitted, use --seed-url and/or --seed-keywords.",
    )
    parser.add_argument(
        "--input-file",
        type=Path,
        help="Optional text file with one keyword per line.",
    )
    parser.add_argument(
        "--seed-url",
        help="Optional URL seed for keyword idea generation.",
    )
    parser.add_argument(
        "--seed-keywords",
        help="Optional comma-separated keyword seeds for idea generation.",
    )
    parser.add_argument(
        "--mode",
        choices=("historical", "ideas"),
        default="historical",
        help="Use 'historical' for exact keyword metrics or 'ideas' for idea generation.",
    )
    parser.add_argument(
        "--preset",
        choices=sorted(PRESETS.keys()),
        default="be-nl",
        help="Shortcut for common language + geo combinations.",
    )
    parser.add_argument(
        "--language-id",
        help="Override language criterion ID.",
    )
    parser.add_argument(
        "--geo-target-id",
        action="append",
        dest="geo_target_ids",
        help="Override one or more geo target IDs.",
    )
    parser.add_argument(
        "--customer-id",
        default=os.getenv("GOOGLE_ADS_CUSTOMER_ID"),
        help="Google Ads customer ID used for Keyword Planner requests.",
    )
    parser.add_argument(
        "--config-file",
        default=os.getenv("GOOGLE_ADS_CONFIGURATION_FILE_PATH"),
        help="Path to google-ads.yaml. Falls back to GOOGLE_ADS_CONFIGURATION_FILE_PATH.",
    )
    parser.add_argument(
        "--row-limit",
        type=int,
        default=DEFAULT_ROW_LIMIT,
        help="Maximum number of keyword ideas to return in ideas mode.",
    )
    parser.add_argument(
        "--include-average-cpc",
        action="store_true",
        help="Ask historical metrics for average CPC when available.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional output file (.json or .csv).",
    )
    parser.add_argument(
        "--format",
        choices=("table", "json", "csv"),
        default="table",
        help="Output format when --output is omitted.",
    )
    return parser.parse_args()


def read_keywords(args: argparse.Namespace) -> list[str]:
    keywords = list(args.keywords)
    if args.input_file:
        if not args.input_file.exists():
            raise SystemExit(f"Input file does not exist: {args.input_file}")
        for line in args.input_file.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if stripped:
                keywords.append(stripped)

    if args.seed_keywords:
        for item in args.seed_keywords.split(","):
            stripped = item.strip()
            if stripped:
                keywords.append(stripped)

    deduped: list[str] = []
    seen = set()
    for keyword in keywords:
        lowered = keyword.lower()
        if lowered in seen:
            continue
        seen.add(lowered)
        deduped.append(keyword)
    return deduped


def resolve_targeting(args: argparse.Namespace) -> tuple[str, list[str]]:
    preset = PRESETS[args.preset]
    language_id = args.language_id or preset["language_id"]
    geo_target_ids = args.geo_target_ids or preset["geo_target_ids"]
    return language_id, geo_target_ids


def validate_args(args: argparse.Namespace, keywords: list[str]) -> None:
    if not args.customer_id:
        raise SystemExit("Missing Google Ads customer ID. Pass --customer-id or set GOOGLE_ADS_CUSTOMER_ID.")
    if not args.config_file:
        raise SystemExit(
            "Missing Google Ads config file. Pass --config-file or set GOOGLE_ADS_CONFIGURATION_FILE_PATH."
        )
    if args.row_limit <= 0:
        raise SystemExit("--row-limit must be greater than 0.")

    if args.mode == "historical" and not keywords:
        raise SystemExit("Historical mode requires at least one keyword.")

    if args.mode == "ideas" and not (args.seed_url or keywords):
        raise SystemExit("Ideas mode requires --seed-url and/or one or more seed keywords.")


def load_client(config_file: str):
    try:
        from google.ads.googleads.client import GoogleAdsClient
    except ImportError as exc:  # pragma: no cover - dependency guard
        raise SystemExit(
            "Missing dependency 'google-ads'. Run `python3 -m pip install -r requirements.txt` first."
        ) from exc

    return GoogleAdsClient.load_from_storage(config_file)


def build_common_request_fields(client, request, customer_id: str, language_id: str, geo_target_ids: list[str]) -> None:
    language_service = client.get_service("LanguageConstantService")
    geo_target_service = client.get_service("GeoTargetConstantService")

    request.customer_id = customer_id.replace("-", "")
    request.language = language_service.language_constant_path(language_id)
    for geo_target_id in geo_target_ids:
        request.geo_target_constants.append(
            geo_target_service.geo_target_constant_path(str(geo_target_id))
        )
    request.keyword_plan_network = client.enums.KeywordPlanNetworkEnum.GOOGLE_SEARCH


def fetch_historical_metrics(client, customer_id: str, keywords: list[str], language_id: str, geo_target_ids: list[str], include_average_cpc: bool) -> dict:
    service = client.get_service("KeywordPlanIdeaService")
    request = client.get_type("GenerateKeywordHistoricalMetricsRequest")
    build_common_request_fields(client, request, customer_id, language_id, geo_target_ids)
    request.keywords.extend(keywords)
    if include_average_cpc:
        request.historical_metrics_options.include_average_cpc = True

    response = service.generate_keyword_historical_metrics(request=request)
    rows = []
    for result in response.results:
        metrics = result.keyword_metrics
        monthly_breakdown = []
        for month in metrics.monthly_search_volumes:
            monthly_breakdown.append(
                {
                    "year": month.year,
                    "month": str(month.month),
                    "monthly_searches": month.monthly_searches,
                }
            )
        rows.append(
            {
                "keyword": result.text,
                "close_variants": list(result.close_variants),
                "avg_monthly_searches": metrics.avg_monthly_searches,
                "competition": metrics.competition.name if metrics.competition else "",
                "competition_index": metrics.competition_index if metrics.competition_index is not None else "",
                "low_top_of_page_bid_micros": metrics.low_top_of_page_bid_micros,
                "high_top_of_page_bid_micros": metrics.high_top_of_page_bid_micros,
                "average_cpc_micros": getattr(metrics, "average_cpc_micros", 0),
                "monthly_search_volumes": monthly_breakdown,
            }
        )

    return {
        "mode": "historical",
        "customer_id": customer_id.replace("-", ""),
        "language_id": language_id,
        "geo_target_ids": geo_target_ids,
        "rows": rows,
    }


def fetch_keyword_ideas(client, customer_id: str, seed_url: str | None, seed_keywords: list[str], language_id: str, geo_target_ids: list[str], row_limit: int) -> dict:
    service = client.get_service("KeywordPlanIdeaService")
    request = client.get_type("GenerateKeywordIdeasRequest")
    build_common_request_fields(client, request, customer_id, language_id, geo_target_ids)
    request.page_size = row_limit

    if seed_url and seed_keywords:
        request.keyword_and_url_seed.url = seed_url
        request.keyword_and_url_seed.keywords.extend(seed_keywords)
    elif seed_url:
        request.url_seed.url = seed_url
    else:
        request.keyword_seed.keywords.extend(seed_keywords)

    rows = []
    for idea in service.generate_keyword_ideas(request=request):
        metrics = idea.keyword_idea_metrics
        rows.append(
            {
                "keyword": idea.text,
                "avg_monthly_searches": metrics.avg_monthly_searches if metrics else 0,
                "competition": metrics.competition.name if metrics and metrics.competition else "",
                "competition_index": metrics.competition_index if metrics and metrics.competition_index is not None else "",
                "low_top_of_page_bid_micros": metrics.low_top_of_page_bid_micros if metrics else 0,
                "high_top_of_page_bid_micros": metrics.high_top_of_page_bid_micros if metrics else 0,
            }
        )

    rows.sort(key=lambda item: item["avg_monthly_searches"], reverse=True)
    return {
        "mode": "ideas",
        "customer_id": customer_id.replace("-", ""),
        "language_id": language_id,
        "geo_target_ids": geo_target_ids,
        "seed_url": seed_url,
        "seed_keywords": seed_keywords,
        "rows": rows,
    }


def micros_to_currency(value: int | str) -> str:
    if not value:
        return ""
    try:
        return f"{int(value) / 1_000_000:.2f}"
    except (TypeError, ValueError):
        return ""


def format_value(column: str, value) -> str:
    if column.endswith("_micros"):
        return micros_to_currency(value)
    if isinstance(value, list):
        return ", ".join(str(item) for item in value)
    return str(value)


def print_table(payload: dict) -> None:
    rows = payload["rows"]
    if not rows:
        print("No keyword rows returned.")
        return

    if payload["mode"] == "historical":
        columns = [
            "keyword",
            "avg_monthly_searches",
            "competition",
            "competition_index",
            "low_top_of_page_bid_micros",
            "high_top_of_page_bid_micros",
        ]
    else:
        columns = [
            "keyword",
            "avg_monthly_searches",
            "competition",
            "competition_index",
            "low_top_of_page_bid_micros",
            "high_top_of_page_bid_micros",
        ]

    widths = {column: len(column) for column in columns}
    for row in rows:
        for column in columns:
            widths[column] = max(widths[column], len(format_value(column, row.get(column, ""))))

    print(f"Mode: {payload['mode']}")
    print(f"Language ID: {payload['language_id']}")
    print(f"Geo target IDs: {', '.join(payload['geo_target_ids'])}")
    print(f"Rows: {len(rows)}")
    print("")

    header = " | ".join(column.ljust(widths[column]) for column in columns)
    separator = "-+-".join("-" * widths[column] for column in columns)
    print(header)
    print(separator)
    for row in rows:
        print(
            " | ".join(
                format_value(column, row.get(column, "")).ljust(widths[column]) for column in columns
            )
        )


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def write_csv(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = payload["rows"]
    if payload["mode"] == "historical":
        columns = [
            "keyword",
            "close_variants",
            "avg_monthly_searches",
            "competition",
            "competition_index",
            "low_top_of_page_bid_micros",
            "high_top_of_page_bid_micros",
            "average_cpc_micros",
        ]
    else:
        columns = [
            "keyword",
            "avg_monthly_searches",
            "competition",
            "competition_index",
            "low_top_of_page_bid_micros",
            "high_top_of_page_bid_micros",
        ]

    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns)
        writer.writeheader()
        for row in rows:
            flat_row = dict(row)
            if "close_variants" in flat_row:
                flat_row["close_variants"] = ", ".join(flat_row["close_variants"])
            writer.writerow({column: flat_row.get(column, "") for column in columns})


def write_output(path: Path, payload: dict) -> None:
    suffix = path.suffix.lower()
    if suffix == ".json":
        write_json(path, payload)
        return
    if suffix == ".csv":
        write_csv(path, payload)
        return
    raise SystemExit("Unsupported output extension. Use .json or .csv.")


def main() -> None:
    args = parse_args()
    keywords = read_keywords(args)
    validate_args(args, keywords)
    language_id, geo_target_ids = resolve_targeting(args)

    client = load_client(args.config_file)
    if args.mode == "historical":
        payload = fetch_historical_metrics(
            client=client,
            customer_id=args.customer_id,
            keywords=keywords,
            language_id=language_id,
            geo_target_ids=geo_target_ids,
            include_average_cpc=args.include_average_cpc,
        )
    else:
        payload = fetch_keyword_ideas(
            client=client,
            customer_id=args.customer_id,
            seed_url=args.seed_url,
            seed_keywords=keywords,
            language_id=language_id,
            geo_target_ids=geo_target_ids,
            row_limit=args.row_limit,
        )

    if args.output:
        write_output(args.output, payload)
        print(f"Wrote Google Ads keyword data to: {args.output}")
        return

    if args.format == "json":
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        return

    if args.format == "csv":
        writer = csv.writer(os.sys.stdout)
        if payload["mode"] == "historical":
            writer.writerow(
                [
                    "keyword",
                    "avg_monthly_searches",
                    "competition",
                    "competition_index",
                    "low_top_of_page_bid_micros",
                    "high_top_of_page_bid_micros",
                ]
            )
            for row in payload["rows"]:
                writer.writerow(
                    [
                        row["keyword"],
                        row["avg_monthly_searches"],
                        row["competition"],
                        row["competition_index"],
                        row["low_top_of_page_bid_micros"],
                        row["high_top_of_page_bid_micros"],
                    ]
                )
        else:
            writer.writerow(
                [
                    "keyword",
                    "avg_monthly_searches",
                    "competition",
                    "competition_index",
                    "low_top_of_page_bid_micros",
                    "high_top_of_page_bid_micros",
                ]
            )
            for row in payload["rows"]:
                writer.writerow(
                    [
                        row["keyword"],
                        row["avg_monthly_searches"],
                        row["competition"],
                        row["competition_index"],
                        row["low_top_of_page_bid_micros"],
                        row["high_top_of_page_bid_micros"],
                    ]
                )
        return

    print_table(payload)


if __name__ == "__main__":
    main()
