from __future__ import annotations

import argparse
import os
import re
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Pt

from export_to_google_docs import (
    DEFAULT_GOOGLE_DRIVE_FOLDER_ID,
    build_credentials,
    load_environment,
    upload_google_doc,
    validate_args as validate_export_args,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert a Markdown audit to DOCX and publish it as a Google Doc."
    )
    parser.add_argument("input_markdown", type=Path, help="Path to the Markdown source audit")
    parser.add_argument(
        "--output-docx",
        type=Path,
        help="Optional path for the intermediate DOCX export. Defaults to output/docx/<input-name>.docx",
    )
    parser.add_argument(
        "--name",
        help="Optional Google Doc filename. Defaults to the Markdown filename without extension.",
    )
    parser.add_argument(
        "--folder-id",
        help="Optional Google Drive folder id. Falls back to the default repo folder or env.",
    )
    parser.add_argument(
        "--service-account-file",
        help="Optional Google service account JSON file.",
    )
    parser.add_argument(
        "--client-secrets-file",
        help="Optional OAuth desktop client credentials JSON file.",
    )
    parser.add_argument(
        "--token-file",
        help="Optional OAuth token file path.",
    )
    parser.add_argument(
        "--oauth-mode",
        choices=("local-server", "console"),
        help="How to complete the first OAuth login.",
    )
    return parser.parse_args()


def build_output_docx_path(input_markdown: Path, output_docx: Path | None) -> Path:
    if output_docx is not None:
        output_docx.parent.mkdir(parents=True, exist_ok=True)
        return output_docx

    default_path = Path("output/docx") / f"{input_markdown.stem}.docx"
    default_path.parent.mkdir(parents=True, exist_ok=True)
    return default_path


def configure_styles(document: Document) -> None:
    normal = document.styles["Normal"]
    normal.font.name = "Arial"
    normal.font.size = Pt(10.5)

    document.styles["Title"].font.name = "Arial"
    document.styles["Title"].font.size = Pt(22)
    document.styles["Heading 1"].font.name = "Arial"
    document.styles["Heading 1"].font.size = Pt(16)
    document.styles["Heading 2"].font.name = "Arial"
    document.styles["Heading 2"].font.size = Pt(13)
    document.styles["Heading 3"].font.name = "Arial"
    document.styles["Heading 3"].font.size = Pt(11.5)


def add_inline_runs(paragraph, text: str) -> None:
    parts = re.split(r"(\*\*.*?\*\*)", text)
    for part in parts:
        if not part:
            continue
        if part.startswith("**") and part.endswith("**") and len(part) >= 4:
            run = paragraph.add_run(part[2:-2])
            run.bold = True
        else:
            paragraph.add_run(part)


def markdown_to_docx(input_markdown: Path, output_docx: Path) -> None:
    document = Document()
    configure_styles(document)
    first_title_written = False

    for raw_line in input_markdown.read_text(encoding="utf-8").splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

        if not stripped:
            document.add_paragraph("")
            continue

        if stripped.startswith("# "):
            if not first_title_written:
                paragraph = document.add_paragraph(style="Title")
                paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
                add_inline_runs(paragraph, stripped[2:])
                first_title_written = True
            else:
                paragraph = document.add_paragraph(style="Heading 1")
                add_inline_runs(paragraph, stripped[2:])
            continue

        if stripped.startswith("## "):
            paragraph = document.add_paragraph(style="Heading 1")
            add_inline_runs(paragraph, stripped[3:])
            continue

        if stripped.startswith("### "):
            paragraph = document.add_paragraph(style="Heading 2")
            add_inline_runs(paragraph, stripped[4:])
            continue

        if stripped.startswith("#### "):
            paragraph = document.add_paragraph(style="Heading 3")
            add_inline_runs(paragraph, stripped[5:])
            continue

        if stripped.startswith("- "):
            paragraph = document.add_paragraph(style="List Bullet")
            add_inline_runs(paragraph, stripped[2:])
            continue

        if re.match(r"^\d+\.\s+", stripped):
            paragraph = document.add_paragraph(style="List Number")
            add_inline_runs(paragraph, re.sub(r"^\d+\.\s+", "", stripped))
            continue

        paragraph = document.add_paragraph()
        add_inline_runs(paragraph, stripped)

    output_docx.parent.mkdir(parents=True, exist_ok=True)
    document.save(str(output_docx))


def merge_export_args(args: argparse.Namespace) -> argparse.Namespace:
    export_args = argparse.Namespace()
    export_args.input_file = build_output_docx_path(args.input_markdown, args.output_docx)
    export_args.folder_id = args.folder_id or os.getenv(
        "GOOGLE_DRIVE_FOLDER_ID",
        DEFAULT_GOOGLE_DRIVE_FOLDER_ID,
    )
    export_args.name = args.name
    export_args.service_account_file = args.service_account_file or os.getenv("GOOGLE_SERVICE_ACCOUNT_FILE")
    export_args.client_secrets_file = args.client_secrets_file or os.getenv("GOOGLE_OAUTH_CLIENT_SECRET_FILE")
    export_args.token_file = args.token_file or os.getenv("GOOGLE_OAUTH_TOKEN_FILE", "tmp/google-oauth-token.json")
    export_args.oauth_mode = args.oauth_mode or os.getenv("GOOGLE_OAUTH_MODE", "local-server")
    return export_args


def main() -> None:
    load_environment()
    args = parse_args()
    if not args.input_markdown.exists():
        raise SystemExit(f"Input markdown does not exist: {args.input_markdown}")

    export_args = merge_export_args(args)
    markdown_to_docx(args.input_markdown, export_args.input_file)
    export_args.name = export_args.name or args.input_markdown.stem
    validate_export_args(export_args)
    credentials = build_credentials(export_args)
    created_file = upload_google_doc(export_args, credentials)

    print(f"Generated DOCX: {export_args.input_file}")
    print(f"Created Google Doc: {created_file['name']}")
    print(f"File ID: {created_file['id']}")
    print(f"Open: {created_file['webViewLink']}")


if __name__ == "__main__":
    main()
