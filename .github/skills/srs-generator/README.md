SRS Generator Skill

This Copilot skill generates a complete Software Requirements Specification (SRS) in Markdown.

Usage

1. Open Copilot Chat and invoke the skill by name:
   /srs-generator

2. Answer the interactive prompts for project metadata, features, requirements, and other sections. The skill will ask follow-ups until required fields are filled.

3. Output is saved under `outputs/srs/YYYY-MM-DD/`:
   - `<project-slug>_SRS.md` (the SRS in Markdown)

Notes

- The SRS is written as Markdown for easy diffing, reviewing, and version control.

Example one-shot invocation from Copilot Chat or CLI:

```
/srs-generator Project: Acme Payments; Version: 0.1; Authors: Alice Smith; Date: today; Intro: Purpose: build a payments API; Features: FR-1 Payment processing high Inputs: payment request Outputs: confirmation Acceptance: payments accepted and recorded; done
```

After completion the skill will write `<project-slug>_SRS.md` in `outputs/srs/YYYY-MM-DD/`.
