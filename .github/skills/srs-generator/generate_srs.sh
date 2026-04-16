#!/usr/bin/env bash
set -euo pipefail

MD_FILE="$1"
PDF_FILE="$2"

if [[ ! -f "$MD_FILE" ]]; then
  echo "Error: markdown file not found: $MD_FILE" >&2
  exit 2
fi

if command -v pandoc >/dev/null 2>&1; then
  echo "Converting $MD_FILE -> $PDF_FILE using pandoc..."

  # If a TeX engine exists, prefer it. Otherwise try tectonic, or fall back to HTML output.
  if command -v xelatex >/dev/null 2>&1 || command -v pdflatex >/dev/null 2>&1 || command -v lualatex >/dev/null 2>&1; then
    # Prefer xelatex for better font handling; pandoc will choose pdflatex if xelatex isn't present
    pandoc "$MD_FILE" -s -o "$PDF_FILE" --pdf-engine=xelatex || pandoc "$MD_FILE" -s -o "$PDF_FILE"
  elif command -v tectonic >/dev/null 2>&1; then
    echo "Using tectonic as PDF engine"
    pandoc "$MD_FILE" -s -o "$PDF_FILE" --pdf-engine=tectonic
  else
    echo "No TeX engine found. Attempting to install tectonic via Homebrew (if available), or falling back to HTML output."
    if command -v brew >/dev/null 2>&1; then
      echo "Homebrew available — installing tectonic..."
      brew install tectonic --quiet || echo "Warning: failed to install tectonic via Homebrew" >&2
    fi

    if command -v tectonic >/dev/null 2>&1; then
      pandoc "$MD_FILE" -s -o "$PDF_FILE" --pdf-engine=tectonic
    else
      HTML_FILE="${PDF_FILE%.pdf}.html"
      echo "No PDF engine available; producing HTML at $HTML_FILE"
      pandoc "$MD_FILE" -s -o "$HTML_FILE"
      echo "Markdown saved at $MD_FILE; HTML saved at $HTML_FILE; PDF not created." >&2
      exit 3
    fi
  fi

  echo "PDF written: $PDF_FILE"
  exit 0
else
  echo "Pandoc not found on PATH. Markdown saved at $MD_FILE; PDF not created." >&2
  exit 2
fi
