# ytd-summarise

Security: Transcripts may contain copyrighted material. Do not commit generated transcripts or downloaded media. The `transcripts/` directory is gitignored by default.

Downloads and transcribes a YouTube video, then writes a structured summary with a TL;DR.

---

## Prerequisites

| Dependency | Install | Purpose |
|---|---|---|
| **yt-dlp** | `pip install yt-dlp` | Downloads audio from YouTube |
| **Whisper** (optional) | `pip install openai-whisper` | Local AI transcription |
| **ffmpeg** | `brew install ffmpeg` / `apt install ffmpeg` | Required by yt-dlp for audio extraction |

> **Whisper is optional.** If Whisper is not installed, `transcribe.sh` falls back to YouTube's auto-generated subtitles. Auto-subtitles require no local compute but may be less accurate.

---

## Setup

Recommended (no venv, uses pipx):

```bash
# Install system deps
brew install ffmpeg deno node pipx
pipx ensurepath

# Install apps in isolated environments
pipx install yt-dlp
pipx install openai-whisper

# Verify
yt-dlp --version
pipx list | grep whisper
```

Alternative (use a project venv):

```bash
python3 -m venv .github/skills/ytd-summarise/.venv
source .github/skills/ytd-summarise/.venv/bin/activate
python -m pip install --upgrade pip
pip install yt-dlp openai-whisper
```

Notes:
- If your system blocks global pip installs (PEP 668), use the pipx approach or the project venv above.
- Having a JavaScript runtime and EJS challenge solver (deno or node + yt-dlp's remote components) may be required to fetch some YouTube formats/subtitles. If yt-dlp reports "n challenge" or signature errors, install deno/node and follow the yt-dlp EJS wiki.


---

## Invoking the skill

In GitHub Copilot Chat or CLI:

```
/yt-summarise https://www.youtube.com/watch?v=<video-id>
```

Or describe what you want:

```
Summarise this video: https://youtu.be/<video-id>
```

---

## What happens

1. `transcribe.sh` is called with the YouTube URL
2. `yt-dlp` downloads the audio track
3. Whisper transcribes the audio (or YouTube auto-subtitles are fetched if Whisper is unavailable)
4. A `.md` file is written to `transcripts/` with video metadata and the full transcript
5. Copilot inserts a `## TL;DR` section (2–3 sentences) immediately above `## Transcript`
6. Key takeaways and (for tutorials) step summaries are listed in the chat response

---

## Output format

Transcript files are saved to `transcripts/` relative to **the current working directory** (run from the repo root):

```
transcripts/
└── <video-id>_<safe-title>.md
```

File structure after Copilot inserts the TL;DR:

```markdown
# Video Title

**Channel:** Channel Name
**URL:** https://www.youtube.com/watch?v=<id>

---

## TL;DR

One paragraph summary inserted by Copilot after transcription.

## Transcript

Full transcript text...
```

---

## Manual smoke test

Run from the repo root:

```bash
source .github/skills/ytd-summarise/.venv/bin/activate
bash .github/skills/ytd-summarise/transcribe.sh "https://www.youtube.com/watch?v=<video-id>"
```

The transcript file will be created in `transcripts/` under the repo root.

---

## Notes

- `transcribe.sh` always writes to `$(pwd)/transcripts/` — always run from the repo root for consistent paths.
- Whisper model quality can be configured in `transcribe.sh` (default: `base`). Use `small` or `medium` for better accuracy at the cost of speed.
- Long videos (>30 min) may take several minutes to transcribe locally with Whisper.
