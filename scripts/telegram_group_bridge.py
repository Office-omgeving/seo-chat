from __future__ import annotations

import argparse
import json
import os
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib import error, parse, request

from dotenv import load_dotenv


ROOT_DIR = Path(__file__).resolve().parent.parent
DEFAULT_INBOX_FILE = ROOT_DIR / "tmp/telegram-inbox/messages.jsonl"
DEFAULT_OFFSET_FILE = ROOT_DIR / "tmp/telegram-inbox/offset.txt"
DEFAULT_LATEST_MESSAGE_FILE = ROOT_DIR / "tmp/telegram-inbox/latest-message.md"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Poll Telegram group messages and mirror them into tmp/ so Codex can read them."
    )
    parser.add_argument(
        "--once",
        action="store_true",
        help="Fetch at most one update batch and then stop.",
    )
    parser.add_argument(
        "--poll-timeout",
        type=int,
        help="Long-poll timeout in seconds. Defaults to TELEGRAM_POLL_TIMEOUT or 30.",
    )
    parser.add_argument(
        "--allowed-chat-ids",
        help="Comma-separated list of Telegram chat ids to accept. Defaults to TELEGRAM_ALLOWED_CHAT_IDS.",
    )
    parser.add_argument(
        "--inbox-file",
        type=Path,
        help="Where to append raw normalized messages. Defaults to TELEGRAM_INBOX_FILE.",
    )
    parser.add_argument(
        "--offset-file",
        type=Path,
        help="Where to persist the Telegram update offset. Defaults to TELEGRAM_OFFSET_FILE.",
    )
    parser.add_argument(
        "--latest-message-file",
        type=Path,
        help="Where to write the latest human-readable message summary. Defaults to TELEGRAM_LATEST_MESSAGE_FILE.",
    )
    return parser.parse_args()


@dataclass
class BridgeConfig:
    token: str
    poll_timeout: int
    allowed_chat_ids: set[int]
    inbox_file: Path
    offset_file: Path
    latest_message_file: Path


def load_environment() -> None:
    load_dotenv(ROOT_DIR / ".env")


def parse_chat_ids(value: str) -> set[int]:
    chat_ids: set[int] = set()
    for chunk in value.split(","):
        cleaned = chunk.strip()
        if not cleaned:
            continue
        try:
            chat_ids.add(int(cleaned))
        except ValueError as exc:
            raise SystemExit(f"Ongeldig chat-id in configuratie: {cleaned}") from exc
    return chat_ids


def build_config(args: argparse.Namespace) -> BridgeConfig:
    token = os.getenv("TELEGRAM_BOT_TOKEN", "").strip()
    if not token:
        raise SystemExit("TELEGRAM_BOT_TOKEN ontbreekt. Zet die in .env of de shell.")

    poll_timeout = args.poll_timeout or int(os.getenv("TELEGRAM_POLL_TIMEOUT", "30"))

    allowed_chat_ids_raw = args.allowed_chat_ids
    if allowed_chat_ids_raw is None:
        allowed_chat_ids_raw = os.getenv("TELEGRAM_ALLOWED_CHAT_IDS", "")
    allowed_chat_ids = parse_chat_ids(allowed_chat_ids_raw) if allowed_chat_ids_raw else set()

    inbox_file = args.inbox_file or Path(os.getenv("TELEGRAM_INBOX_FILE", DEFAULT_INBOX_FILE))
    offset_file = args.offset_file or Path(os.getenv("TELEGRAM_OFFSET_FILE", DEFAULT_OFFSET_FILE))
    latest_message_file = args.latest_message_file or Path(
        os.getenv("TELEGRAM_LATEST_MESSAGE_FILE", DEFAULT_LATEST_MESSAGE_FILE)
    )

    return BridgeConfig(
        token=token,
        poll_timeout=poll_timeout,
        allowed_chat_ids=allowed_chat_ids,
        inbox_file=resolve_path(inbox_file),
        offset_file=resolve_path(offset_file),
        latest_message_file=resolve_path(latest_message_file),
    )


def resolve_path(path: Path) -> Path:
    if path.is_absolute():
        return path
    return ROOT_DIR / path


class TelegramApi:
    def __init__(self, token: str) -> None:
        self.base_url = f"https://api.telegram.org/bot{token}/"

    def call(self, method: str, params: dict[str, Any] | None = None) -> Any:
        payload = parse.urlencode(params or {}, doseq=True).encode("utf-8")
        req = request.Request(self.base_url + method, data=payload, method="POST")
        try:
            with request.urlopen(req, timeout=65) as response:
                raw = response.read().decode("utf-8")
        except error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            raise RuntimeError(f"Telegram API fout ({exc.code}): {detail}") from exc
        except error.URLError as exc:
            raise RuntimeError(f"Netwerkfout richting Telegram API: {exc.reason}") from exc

        data = json.loads(raw)
        if not data.get("ok"):
            raise RuntimeError(f"Telegram API gaf een fout terug: {data}")
        return data["result"]

    def get_me(self) -> dict[str, Any]:
        return self.call("getMe")

    def get_updates(self, offset: int | None, timeout: int) -> list[dict[str, Any]]:
        params: dict[str, Any] = {
            "timeout": timeout,
            "allowed_updates": json.dumps(["message", "edited_message"]),
        }
        if offset is not None:
            params["offset"] = offset
        return self.call("getUpdates", params)


def load_offset(path: Path) -> int | None:
    if not path.exists():
        return None
    raw = path.read_text(encoding="utf-8").strip()
    if not raw:
        return None
    try:
        return int(raw)
    except ValueError as exc:
        raise SystemExit(f"Ongeldige offset in {path}: {raw}") from exc


def save_offset(path: Path, offset: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(str(offset), encoding="utf-8")


def normalize_update(update: dict[str, Any]) -> dict[str, Any] | None:
    message = update.get("message") or update.get("edited_message")
    if not message:
        return None

    chat = message.get("chat", {})
    sender = message.get("from", {})
    text = message.get("text") or message.get("caption") or ""

    return {
        "update_id": update.get("update_id"),
        "message_id": message.get("message_id"),
        "message_kind": "edited_message" if "edited_message" in update else "message",
        "received_at_utc": datetime.now(timezone.utc).isoformat(),
        "telegram_date_utc": datetime.fromtimestamp(message.get("date", 0), tz=timezone.utc).isoformat(),
        "chat": {
            "id": chat.get("id"),
            "type": chat.get("type"),
            "title": chat.get("title") or "",
            "username": chat.get("username") or "",
        },
        "sender": {
            "id": sender.get("id"),
            "username": sender.get("username") or "",
            "first_name": sender.get("first_name") or "",
            "last_name": sender.get("last_name") or "",
            "is_bot": bool(sender.get("is_bot")),
        },
        "text": text,
        "raw_entities": message.get("entities") or [],
    }


def is_allowed_message(entry: dict[str, Any], allowed_chat_ids: set[int]) -> bool:
    if entry["sender"]["is_bot"]:
        return False
    if not allowed_chat_ids:
        return True
    return entry["chat"]["id"] in allowed_chat_ids


def append_json_line(path: Path, entry: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(entry, ensure_ascii=False))
        handle.write("\n")


def build_message_summary(entry: dict[str, Any]) -> str:
    sender_name = " ".join(
        part for part in [entry["sender"]["first_name"], entry["sender"]["last_name"]] if part
    ).strip()
    if entry["sender"]["username"]:
        sender_name = f"{sender_name} (@{entry['sender']['username']})".strip()

    chat_label = entry["chat"]["title"] or entry["chat"]["username"] or str(entry["chat"]["id"])
    text = entry["text"].strip() or "[geen tekst, mogelijk alleen media]"

    return "\n".join(
        [
            "# Latest Telegram message",
            "",
            f"- Ontvangen: {entry['received_at_utc']}",
            f"- Telegram datum: {entry['telegram_date_utc']}",
            f"- Chat: {chat_label} ({entry['chat']['id']})",
            f"- Afzender: {sender_name or '[onbekend]'}",
            f"- Bericht-ID: {entry['message_id']}",
            "",
            "## Bericht",
            "",
            text,
            "",
        ]
    )


def write_latest_message(path: Path, entry: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(build_message_summary(entry), encoding="utf-8")


def process_updates(
    updates: list[dict[str, Any]],
    config: BridgeConfig,
) -> int:
    latest_offset: int | None = None

    for update in updates:
        update_id = update.get("update_id")
        if isinstance(update_id, int):
            latest_offset = update_id + 1

        entry = normalize_update(update)
        if entry is None or not is_allowed_message(entry, config.allowed_chat_ids):
            continue

        append_json_line(config.inbox_file, entry)
        write_latest_message(config.latest_message_file, entry)

        chat_label = entry["chat"]["title"] or entry["chat"]["id"]
        sender = entry["sender"]["username"] or entry["sender"]["first_name"] or "onbekend"
        preview = entry["text"].strip().replace("\n", " ")
        if len(preview) > 90:
            preview = preview[:87] + "..."
        print(f"[telegram] opgeslagen uit {chat_label} door {sender}: {preview or '[geen tekst]'}")

    return latest_offset if latest_offset is not None else -1 if updates else -1


def main() -> int:
    load_environment()
    args = parse_args()
    config = build_config(args)
    api = TelegramApi(config.token)

    me = api.get_me()
    username = me.get("username", "")
    print(f"[telegram] bridge actief voor bot @{username}" if username else "[telegram] bridge actief")

    offset = load_offset(config.offset_file)

    while True:
        updates = api.get_updates(offset=offset, timeout=config.poll_timeout)
        latest_offset = process_updates(updates, config)
        if latest_offset != -1:
            offset = latest_offset
            save_offset(config.offset_file, offset)

        if args.once:
            break

        if not updates:
            time.sleep(1)

    print(f"[telegram] inbox: {config.inbox_file}")
    print(f"[telegram] latest: {config.latest_message_file}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("\n[telegram] bridge gestopt", file=sys.stderr)
        raise SystemExit(130)
