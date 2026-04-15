---
name: yt-summarise
description: Downloads and transcribes a YouTube video, then summarises its content.
  Use when the user pastes a YouTube URL and asks for a summary, key points, or transcript.
---

## YouTube Summariser

Run `transcribe.sh` with the YouTube URL as the argument.
The script outputs a `.md` file in the `transcripts/` directory containing the video metadata and transcript.

Once complete:
1. Write a **TL;DR** — a single punchy paragraph (2-3 sentences max) capturing the core message
2. Insert the TL;DR into the `.md` file immediately after the `---` divider and before the `## Transcript` heading, under a `## TL;DR` heading
3. Present the TL;DR to the user in your response
4. List the key takeaways as bullet points
5. If it's a tutorial, list the steps covered
6. Mention the approximate video length
