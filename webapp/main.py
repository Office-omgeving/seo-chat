from __future__ import annotations

import os
from pathlib import Path

from fastapi import BackgroundTasks, FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from .engine import OpenAIResponsesClient, SEOAuditEngine
from .models import AuditIntake
from .storage import AuditStorage


REPO_ROOT = Path(__file__).resolve().parents[1]
try:
    from dotenv import load_dotenv
except ImportError:  # pragma: no cover - optional dependency
    load_dotenv = None

if load_dotenv is not None:
    load_dotenv(REPO_ROOT / "config" / "google-docs.env", override=False)
    load_dotenv(REPO_ROOT / ".env", override=True)

storage = AuditStorage(REPO_ROOT)
engine = SEOAuditEngine(REPO_ROOT, storage, OpenAIResponsesClient())

app = FastAPI(title="SEO/GEO Audit Webapp", version="1.0.0")
app.mount("/assets", StaticFiles(directory=REPO_ROOT / "assets"), name="assets")
templates = Jinja2Templates(directory=str(REPO_ROOT / "webapp" / "templates"))


@app.get("/", response_class=HTMLResponse)
async def index(request: Request) -> HTMLResponse:
    return templates.TemplateResponse(
        request,
        "index.html",
        {
            "model_name": "gpt-5.4",
            "storage_status": storage.status(),
        },
    )


@app.post("/api/audits")
async def create_audit(request: Request, background_tasks: BackgroundTasks) -> JSONResponse:
    payload = await request.json()
    try:
        intake = AuditIntake.from_payload(payload)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    record = engine.new_record(intake)
    background_tasks.add_task(engine.run, record.audit_id)
    return JSONResponse({"audit_id": record.audit_id, "status": record.status})


@app.get("/api/audits/{audit_id}")
async def get_audit(audit_id: str) -> JSONResponse:
    record = storage.load(audit_id)
    if record is None:
        raise HTTPException(status_code=404, detail="Audit niet gevonden.")
    return JSONResponse(record.to_dict())


@app.post("/api/audits/{audit_id}/export")
async def export_audit(audit_id: str) -> JSONResponse:
    try:
        record = engine.export_existing(audit_id)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    return JSONResponse(record.to_dict())


@app.get("/api/system/status")
async def system_status() -> JSONResponse:
    return JSONResponse(
        {
            "model_name": "gpt-5.4",
            "storage": storage.status(),
        }
    )
