#!/usr/bin/env python3
"""Build readable PDF artifacts from the long-form Markdown docs."""

from __future__ import annotations

import html
import re
import textwrap
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
)


ROOT = Path(__file__).resolve().parents[1]
DOCS = [
    (
        ROOT / "docs" / "mcp-for-purebasic.md",
        ROOT / ".build" / "docs-pdf" / "mcp-for-purebasic.pdf",
        "MCP for PureBasic",
    ),
    (
        ROOT / "docs" / "tutorial-building-with-purebasic-jsonrpc.md",
        ROOT / ".build" / "docs-pdf" / "tutorial-building-with-purebasic-jsonrpc.pdf",
        "Building With PureBasic JSON-RPC",
    ),
]


def clean_inline(text: str) -> str:
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1 (\2)", text)
    text = text.replace("**", "")
    text = text.replace("__", "")
    text = text.replace("`", "")
    return html.escape(text)


def wrap_code(text: str, width: int = 92) -> str:
    wrapped: list[str] = []
    for line in text.splitlines():
        if not line:
            wrapped.append("")
            continue
        chunks = textwrap.wrap(
            line,
            width=width,
            replace_whitespace=False,
            drop_whitespace=False,
            break_long_words=True,
            break_on_hyphens=False,
        )
        wrapped.extend(chunks or [""])
    return "\n".join(wrapped)


def build_styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "DocTitle",
            parent=base["Title"],
            fontName="Helvetica-Bold",
            fontSize=24,
            leading=30,
            alignment=TA_CENTER,
            spaceAfter=18,
        ),
        "h1": ParagraphStyle(
            "Heading1",
            parent=base["Heading1"],
            fontName="Helvetica-Bold",
            fontSize=20,
            leading=25,
            spaceBefore=14,
            spaceAfter=8,
        ),
        "h2": ParagraphStyle(
            "Heading2",
            parent=base["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=15,
            leading=19,
            spaceBefore=12,
            spaceAfter=6,
        ),
        "h3": ParagraphStyle(
            "Heading3",
            parent=base["Heading3"],
            fontName="Helvetica-Bold",
            fontSize=12,
            leading=16,
            spaceBefore=10,
            spaceAfter=5,
        ),
        "body": ParagraphStyle(
            "Body",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=10.5,
            leading=15,
            spaceAfter=7,
        ),
        "bullet": ParagraphStyle(
            "Bullet",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=10.5,
            leading=15,
            leftIndent=18,
            firstLineIndent=0,
            spaceAfter=4,
        ),
        "quote": ParagraphStyle(
            "Quote",
            parent=base["BodyText"],
            fontName="Helvetica-Oblique",
            fontSize=10.5,
            leading=15,
            leftIndent=18,
            rightIndent=18,
            textColor=colors.HexColor("#333333"),
            spaceBefore=4,
            spaceAfter=8,
        ),
        "code": ParagraphStyle(
            "Code",
            parent=base["Code"],
            fontName="Courier",
            fontSize=8.2,
            leading=10.5,
            leftIndent=8,
            rightIndent=8,
            borderWidth=0.5,
            borderColor=colors.HexColor("#cccccc"),
            borderPadding=6,
            backColor=colors.HexColor("#f7f7f7"),
            spaceBefore=4,
            spaceAfter=8,
        ),
    }


def parse_markdown(markdown: str, title: str) -> list:
    styles = build_styles()
    story: list = [Paragraph(clean_inline(title), styles["title"])]
    paragraph: list[str] = []
    code_lines: list[str] = []
    in_code = False

    def flush_paragraph() -> None:
        nonlocal paragraph
        if paragraph:
            story.append(Paragraph(clean_inline(" ".join(paragraph)), styles["body"]))
            paragraph = []

    def flush_code() -> None:
        nonlocal code_lines
        code = wrap_code("\n".join(code_lines))
        story.append(Preformatted(html.escape(code), styles["code"]))
        code_lines = []

    for raw_line in markdown.splitlines():
        line = raw_line.rstrip()

        if line.startswith("```"):
            if in_code:
                flush_code()
                in_code = False
            else:
                flush_paragraph()
                in_code = True
            continue

        if in_code:
            code_lines.append(line)
            continue

        if not line.strip():
            flush_paragraph()
            story.append(Spacer(1, 3))
            continue

        heading = re.match(r"^(#{1,6})\s+(.*)$", line)
        if heading:
            flush_paragraph()
            level = len(heading.group(1))
            text = heading.group(2)
            if text == title:
                continue
            if level == 1:
                story.append(PageBreak())
                story.append(Paragraph(clean_inline(text), styles["h1"]))
            elif level == 2:
                story.append(Paragraph(clean_inline(text), styles["h2"]))
            else:
                story.append(Paragraph(clean_inline(text), styles["h3"]))
            continue

        if line.startswith("> "):
            flush_paragraph()
            story.append(Paragraph(clean_inline(line[2:]), styles["quote"]))
            continue

        if re.match(r"^\s*[-*]\s+", line):
            flush_paragraph()
            text = re.sub(r"^\s*[-*]\s+", "", line)
            story.append(Paragraph(clean_inline(text), styles["bullet"], bulletText="-"))
            continue

        numbered = re.match(r"^\s*(\d+)\.\s+(.*)$", line)
        if numbered:
            flush_paragraph()
            story.append(
                Paragraph(
                    clean_inline(numbered.group(2)),
                    styles["bullet"],
                    bulletText=f"{numbered.group(1)}.",
                )
            )
            continue

        if line.startswith("|"):
            flush_paragraph()
            story.append(Preformatted(html.escape(wrap_code(line)), styles["code"]))
            continue

        if re.match(r"^-{3,}$", line):
            flush_paragraph()
            story.append(Spacer(1, 12))
            continue

        paragraph.append(line.strip())

    flush_paragraph()
    if in_code:
        flush_code()
    return story


def add_page_number(canvas, doc) -> None:
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#666666"))
    canvas.drawCentredString(letter[0] / 2.0, 0.45 * inch, f"Page {doc.page}")
    canvas.restoreState()


def build_pdf(source: Path, output: Path, title: str) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    doc = SimpleDocTemplate(
        str(output),
        pagesize=letter,
        rightMargin=0.72 * inch,
        leftMargin=0.72 * inch,
        topMargin=0.72 * inch,
        bottomMargin=0.72 * inch,
        title=title,
        author="PureBasic JSON-RPC contributors",
    )
    story = parse_markdown(source.read_text(encoding="utf-8"), title)
    doc.build(story, onFirstPage=add_page_number, onLaterPages=add_page_number)
    print(f"Built PDF: {output}")


def main() -> int:
    pdf_dir = ROOT / ".build" / "docs-pdf"
    pdf_dir.mkdir(parents=True, exist_ok=True)
    for existing in pdf_dir.glob("*.pdf"):
        existing.unlink()
    for source, output, title in DOCS:
        if not source.exists():
            raise SystemExit(f"Missing Markdown source: {source}")
        build_pdf(source, output, title)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
