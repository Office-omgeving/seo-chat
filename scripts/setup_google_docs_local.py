from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path


DEFAULT_FOLDER_ID = "1kIrKfCzU9oFgZJYSUOZxlUvSPZFUMGgf"
DEFAULT_CREDENTIALS_PATH = Path("tmp/credentials/google-service-account.json")
DEFAULT_ENV_PATH = Path(".env")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Set up local Google Docs publishing for this repo."
    )
    parser.add_argument(
        "service_account_file",
        type=Path,
        help="Path to the downloaded Google service account JSON file.",
    )
    parser.add_argument(
        "--folder-id",
        default=DEFAULT_FOLDER_ID,
        help="Google Drive folder id. Defaults to the shared SEO-CHAT folder.",
    )
    parser.add_argument(
        "--env-file",
        type=Path,
        default=DEFAULT_ENV_PATH,
        help="Path to the local .env file to write.",
    )
    parser.add_argument(
        "--target-credentials-file",
        type=Path,
        default=DEFAULT_CREDENTIALS_PATH,
        help="Where the local service account file should be copied inside the repo.",
    )
    return parser.parse_args()


def validate_service_account_file(path: Path) -> dict:
    if not path.exists():
        raise SystemExit(f"Service account JSON does not exist: {path}")

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Could not parse JSON file: {path}") from exc

    required_keys = {"type", "project_id", "client_email", "private_key"}
    missing = required_keys.difference(data)
    if missing:
        raise SystemExit(
            f"JSON file is missing required service account fields: {', '.join(sorted(missing))}"
        )
    if data.get("type") != "service_account":
        raise SystemExit("JSON file is not a Google service account key.")
    return data


def copy_credentials(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    target.chmod(0o600)


def write_env(env_path: Path, credentials_path: Path, folder_id: str) -> None:
    env_contents = "\n".join(
        [
            f"GOOGLE_DRIVE_FOLDER_ID={folder_id}",
            f"GOOGLE_SERVICE_ACCOUNT_FILE={credentials_path}",
            "GOOGLE_OAUTH_TOKEN_FILE=tmp/google-oauth-token.json",
            "GOOGLE_OAUTH_MODE=local-server",
            "",
        ]
    )
    env_path.write_text(env_contents, encoding="utf-8")


def main() -> None:
    args = parse_args()
    service_account_data = validate_service_account_file(args.service_account_file)
    copy_credentials(args.service_account_file, args.target_credentials_file)
    write_env(args.env_file, args.target_credentials_file, args.folder_id)

    print("Google Docs local setup complete.")
    print(f"Project: {service_account_data['project_id']}")
    print(f"Service account: {service_account_data['client_email']}")
    print(f"Credentials copied to: {args.target_credentials_file}")
    print(f"Local env written to: {args.env_file}")
    print("Next step: run a publish command or start a normal SEO workflow in Codex.")


if __name__ == "__main__":
    main()
