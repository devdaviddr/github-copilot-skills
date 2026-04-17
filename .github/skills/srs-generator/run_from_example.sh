#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
EX="$SKILL_DIR/example_inputs.txt"
if [[ ! -f "$EX" ]]; then
  echo "example_inputs.txt not found in $SKILL_DIR" >&2
  exit 2
fi

# Extract metadata from the first line (semicolon-separated key: value entries)
FIRST_LINE=$(sed -n '1p' "$EX")
extract() { echo "$FIRST_LINE" | sed -n "s/.*$1: *\([^;]*\).*/\1/p" | sed 's/^ *//;s/ *$//'; }
PROJECT=$(extract 'Project')
VERSION=$(extract 'Version')
AUTHORS=$(extract 'Authors')
DATE_LINE=$(extract 'Date')
AUDIENCE=$(extract 'Audience')
TZ=$(extract 'Timezone')

# fallback
PROJECT=${PROJECT:-"Document"}
VERSION=${VERSION:-"0.1"}
AUTHORS=${AUTHORS:-""}
DATE_LINE=${DATE_LINE:-$(date +%F)}

slug=$(echo "$PROJECT" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
OUTDIR="$(pwd)/outputs/srs/$(date +%F)"
mkdir -p "$OUTDIR"
MD="$OUTDIR/${slug}_SRS.md"

# Write header
cat > "$MD" <<EOF
# $PROJECT — Software Requirements Specification

**Version:** $VERSION  
**Authors:** $AUTHORS  
**Date:** $DATE_LINE  

---

## Revision History

| Version | Date | Author | Notes |
|---------|------|--------|-------|
| $VERSION | $DATE_LINE | $AUTHORS | Initial draft |

## Table of Contents

(Generate a TOC listing major headings)

EOF

# Process body: skip first line and transform simple section markers into headings
sed '1d' "$EX" \
  | sed -E '
    s/^Intro:\s*/## Introduction\n\n### Purpose\n/; 
    s/^Overall description:\s*/## Overall description\n/; 
    s/^System features:\s*/## System features\n/; 
    s/^FR-([0-9]+):/### FR-\1:/; 
    s/^External interfaces:\s*/## External interface requirements\n/; 
    s/^Non-functional requirements:\s*/## Non-functional requirements\n/; 
    s/^Data model \/ Entities:\s*/## Data model \/ Entities\n/; 
    s/^Use cases:\s*/## Use cases \/ User scenarios\n/; 
    s/^Acceptance criteria and test notes:\s*/## Acceptance criteria\n/; 
    s/^Appendices \/ Glossary:\s*/## Appendices \/ Glossary\n/; 
  ' >> "$MD"

echo "Generated files:"
echo "- $MD"

exit 0
