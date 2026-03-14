from __future__ import annotations

import argparse
import mimetypes
import os
from pathlib import Path

from google.auth.transport.requests import Request
from google.oauth2 import service_account
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

try:
    from dotenv import load_dotenv
except ImportError:  # pragma: no cover - optional dependency
    load_dotenv = None


SCOPES = ["https://www.googleapis.com/auth/drive.file"]
GOOGLE_DOC_MIME_TYPE = "application/vnd.google-apps.document"
DOCX_MIME_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
DEFAULT_GOOGLE_DRIVE_FOLDER_ID = "1kIrKfCzU9oFgZJYSUOZxlUvSPZFUMGgf"
DEFAULT_REPO_GOOGLE_ENV_PATH = Path(__file__).resolve().parents[1] / "config" / "google-docs.env"


def load_environment() -> None:
    if load_dotenv is not None:
        if DEFAULT_REPO_GOOGLE_ENV_PATH.exists():
            load_dotenv(DEFAULT_REPO_GOOGLE_ENV_PATH)
        load_dotenv()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Upload a DOCX file to Google Drive and convert it into a Google Doc."
    )
    parser.add_argument("input_file", type=Path, help="Path to the local DOCX file")
    parser.add_argument(
        "--folder-id",
        default=os.getenv("GOOGLE_DRIVE_FOLDER_ID", DEFAULT_GOOGLE_DRIVE_FOLDER_ID),
        help="Google Drive folder id. Falls back to GOOGLE_DRIVE_FOLDER_ID.",
    )
    parser.add_argument(
        "--name",
        help="Optional Google Doc filename. Defaults to the input filename without extension.",
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
        default=os.getenv("GOOGLE_OAUTH_TOKEN_FILE", "tmp/google-oauth-token.json"),
        help="Path where the OAuth token should be stored.",
    )
    parser.add_argument(
        "--oauth-mode",
        choices=("local-server", "console"),
        default=os.getenv("GOOGLE_OAUTH_MODE", "local-server"),
        help="How to complete the first OAuth login if you do not use a service account.",
    )
    return parser.parse_args()


def validate_args(args: argparse.Namespace) -> None:
    if not args.input_file.exists():
        raise SystemExit(f"Input file does not exist: {args.input_file}")
    if args.input_file.suffix.lower() != ".docx":
        raise SystemExit("This script currently supports DOCX uploads only.")
    if not args.folder_id:
        raise SystemExit("Missing folder id. Pass --folder-id or set GOOGLE_DRIVE_FOLDER_ID.")
    if not args.service_account_file and not args.client_secrets_file:
        raise SystemExit(
            "Missing Google credentials. Provide a service account JSON or OAuth client secrets JSON."
        )


def build_credentials(args: argparse.Namespace):
    if args.service_account_file:
        return service_account.Credentials.from_service_account_file(
            args.service_account_file,
            scopes=SCOPES,
        )

    token_file = Path(args.token_file)
    token_file.parent.mkdir(parents=True, exist_ok=True)

    credentials = None
    if token_file.exists():
        credentials = Credentials.from_authorized_user_file(str(token_file), SCOPES)

    if credentials and credentials.valid:
        return credentials

    if credentials and credentials.expired and credentials.refresh_token:
        credentials.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(args.client_secrets_file, SCOPES)
        if args.oauth_mode == "console" and hasattr(flow, "run_console"):
            credentials = flow.run_console()
        else:
            credentials = flow.run_local_server(port=0, open_browser=True)

    token_file.write_text(credentials.to_json(), encoding="utf-8")
    return credentials


def guess_mime_type(path: Path) -> str:
    guessed, _ = mimetypes.guess_type(path.name)
    return guessed or DOCX_MIME_TYPE


def upload_google_doc(args: argparse.Namespace, credentials) -> dict:
    service = build("drive", "v3", credentials=credentials)
    metadata = {
        "name": args.name or args.input_file.stem,
        "parents": [args.folder_id],
        "mimeType": GOOGLE_DOC_MIME_TYPE,
    }
    media = MediaFileUpload(
        str(args.input_file),
        mimetype=guess_mime_type(args.input_file),
        resumable=True,
    )
    return (
        service.files()
        .create(
            body=metadata,
            media_body=media,
            fields="id, name, webViewLink, parents",
            supportsAllDrives=True,
        )
        .execute()
    )


def main() -> None:
    load_environment()
    args = parse_args()
    validate_args(args)
    credentials = build_credentials(args)
    created_file = upload_google_doc(args, credentials)
    print(f"Created Google Doc: {created_file['name']}")
    print(f"File ID: {created_file['id']}")
    print(f"Open: {created_file['webViewLink']}")


if __name__ == "__main__":
    main()
