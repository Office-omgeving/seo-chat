from __future__ import annotations

import argparse
import importlib
import os
import socket
import sys
from pathlib import Path


REQUIRED_MODULES = [
    ("fastapi", "fastapi"),
    ("jinja2", "Jinja2"),
    ("openai", "openai"),
    ("uvicorn", "uvicorn"),
]
REPO_ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Start the SEO/GEO FastAPI webapp in development mode."
    )
    parser.add_argument("--host", default="127.0.0.1", help="Bind host for the dev server.")
    parser.add_argument("--port", type=int, default=8000, help="Bind port for the dev server.")
    return parser.parse_args()


def ensure_dependencies() -> None:
    missing: list[str] = []
    for module_name, package_name in REQUIRED_MODULES:
        try:
            importlib.import_module(module_name)
        except ImportError:
            missing.append(package_name)

    if missing:
        packages = ", ".join(missing)
        raise SystemExit(
            "Missing Python dependencies for the webapp: "
            f"{packages}. Run `python3 -m pip install -r requirements.txt` first."
        )


def choose_available_port(host: str, preferred_port: int) -> int:
    port = preferred_port
    while port < preferred_port + 20:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            try:
                sock.bind((host, port))
                return port
            except OSError:
                port += 1
    raise SystemExit(
        f"Could not find a free port between {preferred_port} and {preferred_port + 19}."
    )


def main() -> None:
    args = parse_args()
    ensure_dependencies()
    if str(REPO_ROOT) not in sys.path:
        sys.path.insert(0, str(REPO_ROOT))
    current_pythonpath = os.environ.get("PYTHONPATH", "")
    pythonpath_parts = [part for part in current_pythonpath.split(os.pathsep) if part]
    if str(REPO_ROOT) not in pythonpath_parts:
        pythonpath_parts.insert(0, str(REPO_ROOT))
    os.environ["PYTHONPATH"] = os.pathsep.join(pythonpath_parts)
    port = choose_available_port(args.host, args.port)
    if port != args.port:
        print(f"Port {args.port} is in use. Starting dev server on http://{args.host}:{port} instead.")

    import uvicorn

    uvicorn.run(
        "webapp.main:app",
        host=args.host,
        port=port,
        app_dir=str(REPO_ROOT),
        reload=True,
    )


if __name__ == "__main__":
    main()
