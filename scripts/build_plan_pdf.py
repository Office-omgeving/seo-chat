from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


def clean_inline(text: str) -> str:
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    return text


def build_styles():
    styles = getSampleStyleSheet()
    styles.add(
        ParagraphStyle(
            name="CoverTitle",
            parent=styles["Title"],
            fontName="Helvetica-Bold",
            fontSize=22,
            leading=28,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#183153"),
            spaceAfter=10,
        )
    )
    styles.add(
        ParagraphStyle(
            name="CoverMeta",
            parent=styles["BodyText"],
            fontName="Helvetica",
            fontSize=10.5,
            leading=14,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#4A5568"),
        )
    )
    styles.add(
        ParagraphStyle(
            name="Section1",
            parent=styles["Heading1"],
            fontName="Helvetica-Bold",
            fontSize=16,
            leading=20,
            textColor=colors.HexColor("#183153"),
            spaceBefore=8,
            spaceAfter=6,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Section2",
            parent=styles["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=13,
            leading=17,
            textColor=colors.HexColor("#254E70"),
            spaceBefore=8,
            spaceAfter=4,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Body",
            parent=styles["BodyText"],
            fontName="Helvetica",
            fontSize=10.2,
            leading=14.5,
            spaceAfter=5,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Small",
            parent=styles["BodyText"],
            fontName="Helvetica",
            fontSize=8.5,
            leading=11,
            textColor=colors.HexColor("#4A5568"),
        )
    )
    return styles


def add_page_number(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#666666"))
    canvas.drawRightString(doc.pagesize[0] - 18 * mm, 10 * mm, f"Pagina {doc.page}")
    canvas.restoreState()


def parse_markdown(md_text: str, styles):
    story = []
    bullet_items = []
    numbered_items = []

    def flush_lists():
        nonlocal bullet_items, numbered_items
        if bullet_items:
            story.append(
                ListFlowable(
                    [ListItem(Paragraph(clean_inline(item), styles["Body"])) for item in bullet_items],
                    bulletType="bullet",
                    leftIndent=14,
                    bulletFontName="Helvetica",
                    bulletFontSize=8,
                )
            )
            story.append(Spacer(1, 4))
            bullet_items = []
        if numbered_items:
            story.append(
                ListFlowable(
                    [ListItem(Paragraph(clean_inline(item), styles["Body"])) for item in numbered_items],
                    bulletType="1",
                    leftIndent=16,
                )
            )
            story.append(Spacer(1, 4))
            numbered_items = []

    for raw_line in md_text.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

        if not stripped:
            flush_lists()
            story.append(Spacer(1, 4))
            continue

        if stripped.startswith("# "):
            flush_lists()
            story.append(Paragraph(clean_inline(stripped[2:]), styles["Section1"]))
            continue
        if stripped.startswith("## "):
            flush_lists()
            story.append(Paragraph(clean_inline(stripped[3:]), styles["Section1"]))
            continue
        if stripped.startswith("### "):
            flush_lists()
            story.append(Paragraph(clean_inline(stripped[4:]), styles["Section2"]))
            continue
        if stripped.startswith("- "):
            bullet_items.append(stripped[2:])
            continue
        if re.match(r"^\d+\.\s+", stripped):
            numbered_items.append(re.sub(r"^\d+\.\s+", "", stripped))
            continue

        flush_lists()
        story.append(Paragraph(clean_inline(stripped), styles["Body"]))

    flush_lists()
    return story


def metadata_table(csv_path: Path, styles):
    rows = []
    with csv_path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(
                [
                    Paragraph(clean_inline(row["URL"]), styles["Small"]),
                    Paragraph(clean_inline(row["Status"]), styles["Small"]),
                    Paragraph(clean_inline(row["Primary keyword"]), styles["Small"]),
                    Paragraph(clean_inline(row["SEO title"]), styles["Small"]),
                ]
            )

    data = [
        [
            Paragraph("<b>URL</b>", styles["Small"]),
            Paragraph("<b>Status</b>", styles["Small"]),
            Paragraph("<b>Primary keyword</b>", styles["Small"]),
            Paragraph("<b>SEO title</b>", styles["Small"]),
        ]
    ] + rows

    table = Table(data, colWidths=[42 * mm, 20 * mm, 48 * mm, 72 * mm], repeatRows=1)
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#183153")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#CBD5E0")),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7FAFC")]),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    return table


def build_pdf(input_md: Path, output_pdf: Path, metadata_csv: Path):
    styles = build_styles()
    doc = SimpleDocTemplate(
        str(output_pdf),
        pagesize=A4,
        leftMargin=18 * mm,
        rightMargin=18 * mm,
        topMargin=18 * mm,
        bottomMargin=16 * mm,
        title="EVM Dakwerken SEO + GEO Groei-aanpak",
        author="Codex",
    )

    story = []
    story.append(Spacer(1, 28))
    story.append(Paragraph("EVM Dakwerken SEO + GEO Groei-aanpak", styles["CoverTitle"]))
    story.append(Paragraph("Volledig plan voor SEO, Local SEO en GEO-optimalisatie", styles["CoverMeta"]))
    story.append(Spacer(1, 10))
    story.append(Paragraph("Gebaseerd op de live website en de uitgewerkte delivery pack in deze workspace.", styles["CoverMeta"]))
    story.append(Spacer(1, 24))
    story.extend(parse_markdown(input_md.read_text(encoding="utf-8"), styles))
    story.append(PageBreak())
    story.append(Paragraph("Metadata-overzicht", styles["Section1"]))
    story.append(
        Paragraph(
            "Onderstaande tabel toont de prioritaire metadata-set voor bestaande en nieuwe pagina's.",
            styles["Body"],
        )
    )
    story.append(metadata_table(metadata_csv, styles))

    doc.build(story, onFirstPage=add_page_number, onLaterPages=add_page_number)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_md", type=Path)
    parser.add_argument("output_pdf", type=Path)
    parser.add_argument("--metadata-csv", type=Path, required=True)
    args = parser.parse_args()
    args.output_pdf.parent.mkdir(parents=True, exist_ok=True)
    build_pdf(args.input_md, args.output_pdf, args.metadata_csv)


if __name__ == "__main__":
    main()
