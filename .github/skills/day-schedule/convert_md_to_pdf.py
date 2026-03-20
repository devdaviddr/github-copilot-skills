#!/usr/bin/env python3
"""Convert Markdown to PDF."""

import argparse
import pathlib
import sys

try:
    import markdown
except ImportError:
    print("Missing dependency: markdown. Install via pip install markdown.")
    sys.exit(1)

try:
    import weasyprint
except ImportError:
    print("Missing dependency: weasyprint. Install via pip install weasyprint.")
    sys.exit(1)


def md_to_pdf(input_path: pathlib.Path, output_path: pathlib.Path) -> None:
    md_text = input_path.read_text(encoding='utf-8')
    html = markdown.markdown(md_text, extensions=['extra', 'toc', 'tables'])

    # Minimal stylesheet for readable PDF
    css = weasyprint.CSS(string='''
        body { font-family: Arial, sans-serif; line-height: 1.4; padding: 1em; }
        h1, h2, h3, h4 { color: #2a2a2a; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 1em; }
        th, td { border: 1px solid #cccccc; padding: 0.35em; }
        th { background: #f0f0f0; }
    ''')

    doc = weasyprint.HTML(string=html, base_url=input_path.parent.as_uri())
    doc.write_pdf(str(output_path), stylesheets=[css])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Convert Markdown file to PDF.')
    parser.add_argument('input_md', type=pathlib.Path, help='Input markdown file path')
    parser.add_argument('output_pdf', type=pathlib.Path, help='Output PDF file path')
    args = parser.parse_args()

    if not args.input_md.exists():
        print(f"Input file does not exist: {args.input_md}")
        sys.exit(1)

    args.output_pdf.parent.mkdir(parents=True, exist_ok=True)
    md_to_pdf(args.input_md, args.output_pdf)
    print(f"Saved PDF to {args.output_pdf}")
