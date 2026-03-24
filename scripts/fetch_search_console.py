from __future__ import annotations

import argparse
import csv
import json
import os
from datetime import date, timedelta
from pathlib import Path

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from export_to_google_docs import build_credentials, load_environment


SEARCH_CONSOLE_SCOPES = ["https://www.googleapis.com/auth/webmasters.readonly"]
DEFAULT_DATE_WINDOW_DAYS = 28
DEFAULT_ROW_LIMIT = 250


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch Search Console property data for SEO audit workflows."
    )
    parser.add_argument(
        "property_uri",
        nargs="?",
        default=os.getenv("GOOGLE_SEARCH_CONSOLE_PROPERTY"),
        help="Property URI, for example https://example.com/ or sc-domain:example.com",
    )
    parser.add_argument(
        "--list-properties",
        action="store_true",
        help="List available Search Console properties for the current credentials.",
    )
    parser.add_argument(
        "--start-date",
        help="Start date in YYYY-MM-DD. Defaults to 28 days before end date.",
    )
    parser.add_argument(
        "--end-date",
        help="End date in YYYY-MM-DD. Defaults to yesterday.",
    )
    parser.add_argument(
        "--dimensions",
        default="query",
        help="Comma-separated dimensions, for example query,page or query,page,country,device",
    )
    parser.add_argument(
        "--row-limit",
        type=int,
        default=DEFAULT_ROW_LIMIT,
        help="Maximum number of rows to fetch.",
    )
    parser.add_argument(
        "--search-type",
        choices=("web", "image", "video", "discover", "googleNews", "news"),
        default="web",
        help="Search type for the request body.",
    )
    parser.add_argument(
        "--data-state",
        choices=("final", "all", "hourly_all"),
        default="final",
        help="Data freshness mode.",
    )
    parser.add_argument(
        "--aggregation-type",
        choices=("auto", "byPage", "byProperty", "byNewsShowcasePanel"),
        default="auto",
        help="Aggregation mode for Search Analytics.",
    )
    parser.add_argument(
        "--query-contains",
        help="Optional contains filter for the query dimension.",
    )
    parser.add_argument(
        "--page-contains",
        help="Optional contains filter for the page dimension.",
    )
    parser.add_argument(
        "--country",
        help="Optional country filter, for example BEL or NLD.",
    )
    parser.add_argument(
        "--device",
        choices=("desktop", "mobile", "tablet"),
        help="Optional device filter.",
    )
    parser.add_argument(
        "--search-appearance",
        help="Optional searchAppearance filter.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional output path. Supports .json or .csv.",
    )
    parser.add_argument(
        "--format",
        choices=("table", "json", "csv"),
        default="table",
        help="Output format when --output is omitted.",
    )
    parser.add_argument(
        "--service-account-file",
        default=os.getenv("GOOGLE_SERVICE_ACCOUNT_FILE"),
        help="Path to a Google service account JSON file.",
    )
    parser.add_argument(
        "--client-secrets-file",
        default=os.getenv("GOOGLE_OAUTH_CLIENT_SECRET_FILE"),
        help="Path to an OAuth desktop client credentials JSON file.",
    )
    parser.add_argument(
        "--token-file",
        default=os.getenv(
            "GOOGLE_SEARCH_CONSOLE_OAUTH_TOKEN_FILE",
            "tmp/google-search-console-oauth-token.json",
        ),
        help="Path where the Search Console OAuth token should be stored.",
    )
    parser.add_argument(
        "--oauth-mode",
        choices=("local-server", "console"),
        default=os.getenv("GOOGLE_OAUTH_MODE", "local-server"),
        help="How to complete the first OAuth login if you do not use a service account.",
    )
    return parser.parse_args()


def validate_args(args: argparse.Namespace) -> None:
    if args.list_properties:
        return
    if not args.property_uri:
        raise SystemExit(
            "Missing property URI. Pass a property like https://example.com/ or sc-domain:example.com."
        )
    if not args.service_account_file and not args.client_secrets_file:
        raise SystemExit(
            "Missing Google credentials. Provide a service account JSON or OAuth client secrets JSON."
        )
    if args.row_limit <= 0:
        raise SystemExit("--row-limit must be greater than 0.")


def resolve_dates(args: argparse.Namespace) -> tuple[str, str]:
    if args.end_date:
        end_date = date.fromisoformat(args.end_date)
    else:
        end_date = date.today() - timedelta(days=1)

    if args.start_date:
        start_date = date.fromisoformat(args.start_date)
    else:
        start_date = end_date - timedelta(days=DEFAULT_DATE_WINDOW_DAYS - 1)

    if start_date > end_date:
        raise SystemExit("--start-date cannot be after --end-date.")

    return start_date.isoformat(), end_date.isoformat()


def build_service(args: argparse.Namespace):
    credentials = build_credentials(args, scopes=SEARCH_CONSOLE_SCOPES)
    return build("searchconsole", "v1", credentials=credentials)


def list_properties(service) -> list[dict]:
    response = service.sites().list().execute()
    return response.get("siteEntry", [])


def build_dimension_filters(args: argparse.Namespace) -> list[dict]:
    filters: list[dict] = []
    if args.query_contains:
        filters.append(
            {
                "dimension": "query",
                "operator": "contains",
                "expression": args.query_contains,
            }
        )
    if args.page_contains:
        filters.append(
            {
                "dimension": "page",
                "operator": "contains",
                "expression": args.page_contains,
            }
        )
    if args.country:
        filters.append(
            {
                "dimension": "country",
                "operator": "equals",
                "expression": args.country.upper(),
            }
        )
    if args.device:
        filters.append(
            {
                "dimension": "device",
                "operator": "equals",
                "expression": args.device.upper(),
            }
        )
    if args.search_appearance:
        filters.append(
            {
                "dimension": "searchAppearance",
                "operator": "equals",
                "expression": args.search_appearance,
            }
        )
    return filters


def fetch_search_analytics(service, args: argparse.Namespace) -> dict:
    start_date, end_date = resolve_dates(args)
    dimensions = [item.strip() for item in args.dimensions.split(",") if item.strip()]
    request_body = {
        "startDate": start_date,
        "endDate": end_date,
        "dimensions": dimensions,
        "rowLimit": args.row_limit,
        "dataState": args.data_state,
        "aggregationType": args.aggregation_type,
        "type": args.search_type,
    }

    filters = build_dimension_filters(args)
    if filters:
        request_body["dimensionFilterGroups"] = [{"groupType": "and", "filters": filters}]

    response = (
        service.searchanalytics()
        .query(siteUrl=args.property_uri, body=request_body)
        .execute()
    )
    return {
        "property_uri": args.property_uri,
        "start_date": start_date,
        "end_date": end_date,
        "dimensions": dimensions,
        "request": request_body,
        "rows": normalize_rows(response.get("rows", []), dimensions),
        "response_aggregation_type": response.get("responseAggregationType"),
    }


def normalize_rows(rows: list[dict], dimensions: list[str]) -> list[dict]:
    normalized: list[dict] = []
    for row in rows:
        item = {}
        keys = row.get("keys", [])
        for index, dimension in enumerate(dimensions):
            item[dimension] = keys[index] if index < len(keys) else ""
        item["clicks"] = row.get("clicks", 0)
        item["impressions"] = row.get("impressions", 0)
        item["ctr"] = row.get("ctr", 0)
        item["position"] = row.get("position", 0)
        normalized.append(item)
    return normalized


def print_properties(rows: list[dict]) -> None:
    if not rows:
        print("No Search Console properties available for these credentials.")
        return
    print("Available Search Console properties:")
    for row in rows:
        site_url = row.get("siteUrl", "")
        permission = row.get("permissionLevel", "")
        print(f"- {site_url} ({permission})")


def format_value(column: str, value) -> str:
    if column == "ctr":
        return f"{value * 100:.2f}%"
    if column == "position":
        return f"{value:.2f}"
    if isinstance(value, float):
        return f"{value:.2f}"
    return str(value)


def print_table(payload: dict) -> None:
    rows = payload["rows"]
    if not rows:
        print("No Search Console rows returned for this request.")
        return

    columns = payload["dimensions"] + ["clicks", "impressions", "ctr", "position"]
    widths = {column: len(column) for column in columns}

    for row in rows:
        for column in columns:
            widths[column] = max(widths[column], len(format_value(column, row.get(column, ""))))

    print(f"Property: {payload['property_uri']}")
    print(f"Date range: {payload['start_date']} -> {payload['end_date']}")
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
    columns = payload["dimensions"] + ["clicks", "impressions", "ctr", "position"]
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)


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
    load_environment()
    args = parse_args()
    validate_args(args)

    try:
        service = build_service(args)

        if args.list_properties:
            print_properties(list_properties(service))
            return

        payload = fetch_search_analytics(service, args)
        if args.output:
            write_output(args.output, payload)
            print(f"Wrote Search Console data to: {args.output}")
            return

        if args.format == "json":
            print(json.dumps(payload, indent=2, ensure_ascii=False))
            return
        if args.format == "csv":
            writer = csv.DictWriter(
                os.sys.stdout,
                fieldnames=payload["dimensions"] + ["clicks", "impressions", "ctr", "position"],
            )
            writer.writeheader()
            writer.writerows(payload["rows"])
            return

        print_table(payload)
    except HttpError as exc:
        content = ""
        if hasattr(exc, "content") and exc.content:
            try:
                content = exc.content.decode("utf-8", errors="ignore")
            except AttributeError:
                content = str(exc.content)

        if "accessNotConfigured" in content or "has not been used in project" in content:
            raise SystemExit(
                "Search Console API is nog niet ingeschakeld voor dit Google-project. "
                "Activeer searchconsole.googleapis.com in Google Cloud en probeer daarna opnieuw."
            ) from exc
        if exc.resp is not None and exc.resp.status == 403:
            raise SystemExit(
                "Geen toegang tot deze Search Console property. "
                "Voeg de service account of OAuth-gebruiker toe aan de property en probeer opnieuw."
            ) from exc
        raise SystemExit(f"Search Console API request failed: {exc}") from exc


if __name__ == "__main__":
    main()
