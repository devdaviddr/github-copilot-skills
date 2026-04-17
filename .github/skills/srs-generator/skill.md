---
name: srs-generator
description: Prompt-driven SRS (Software Requirements Specification) generator. Collects required project information and produces a comprehensive SRS in Markdown.
---

When a user requests an SRS, follow this flow:

1. Collect minimal identifying info (prompt until provided):
   - Project name
   - Version
   - Primary author(s)
   - Target audience / stakeholders
   - Preferred timezone and date (default: today)

2. For each major SRS section, ask concise follow-ups until content is complete. Required sections:
   - 0. Revision history (auto-add initial entry using provided author/date/version)
   - 1. Introduction
     * Purpose
     * Scope
     * Definitions / Acronyms (ask for glossary entries)
     * References
   - 2. Overall description
     * Product perspective
     * User classes and characteristics
     * Operating environment
     * Design and implementation constraints
     * Assumptions and dependencies
   - 3. System features / Functional requirements
     * For each feature ask: ID (e.g., FR-1), title, short description, user story / rationale, inputs, outputs, priority, dependencies, acceptance criteria
     * Allow user to add as many features as needed; confirm when done
   - 4. External interface requirements
     * User interfaces, APIs, hardware interfaces, communication protocols
   - 5. Non-functional requirements
     * Performance, security, reliability, maintainability, scalability, localization, accessibility, legal/privacy
   - 6. Data model / Entities (optional but recommended)
     * Key entities, attributes, relationships, sample data formats
   - 7. Use cases / User scenarios (optional)
   - 8. Acceptance criteria and test notes for top-priority features
   - 9. Appendices / Glossary

3. Validate totals and conflicts: ensure each high-priority feature has acceptance criteria. If essential fields are missing, ask for them explicitly.

4. Build the SRS as Markdown only. Use canonical section headings exactly as below and fill content from the collected inputs:

# <Project Name> — Software Requirements Specification

**Version:** <version>  
**Authors:** <authors>  
**Date:** <date>  

---

## Revision History

| Version | Date | Author | Notes |
|---------|------|--------|-------|
| <version> | <date> | <author> | Initial draft |

## Table of Contents

(Generate a TOC listing major headings)

1. Introduction
   1.1 Purpose
   1.2 Scope
   1.3 Definitions, acronyms and abbreviations
   1.4 References

2. Overall description

3. System features

4. External interface requirements

5. Non-functional requirements

6. Data model / Entities

7. Use cases / User scenarios

8. Acceptance criteria

9. Appendices / Glossary


5. Save the Markdown file to a timestamped directory under the repository root: `outputs/srs/YYYY-MM-DD/`.
   - Markdown filename: `<project-slug>_SRS.md` (slug: lowercase, alnum and dashes only)

6. When finished, present a brief confirmation listing the saved path and ask whether the user wants revisions, additional features, or a Git commit.

7. Keep prompts concise; only ask one question at a time. When asking for lists (features, glossary entries), allow multi-line input or repeated prompts until the user signals completion.

Example invocation (one-shot):

- User: "/srs-generator Project: Acme Payments; Version: 0.1; Authors: Alice, Bob; Date: today; Intro: Purpose: build a payments API; Features: FR-1: Payment processing (priority: high) — Inputs: payment request; Outputs: confirmation; Acceptance: unit+integration tests; done"

Interactive notes:
- Accept the word `done` when the user has finished adding repeated items (features, glossary entries, use cases).
- Confirm each feature summary after it's entered and re-prompt for missing acceptance criteria or priority.
- Always report the exact saved path for the Markdown file when finished.
