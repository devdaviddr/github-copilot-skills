# YouTube Summarise Skill

This directory contains a Copilot skill that:

1. Downloads YouTube audio from a URL using `yt-dlp`
2. Transcribes audio to text with `whisper`
3. Saves the full transcript under `transcripts/` with naming pattern `videoID_videoTitle.txt`
4. Appends a generated summary to the end of the transcript file

## Files
- `skill.md`: skill definition and instructions for the agent
- `transcribe.sh`: automation script for downloading, transcribing, and saving
- `transcripts/`: generated transcripts and summaries

## Usage

1. Ensure dependencies are installed:
   - `yt-dlp`
   - `python3` with `openai-whisper` (via venv if needed)
2. Run:
   ```bash
   cd .github/skills/ytd-summarise
   chmod +x transcribe.sh
   . .venv/bin/activate  # if using virtual environment
   ./transcribe.sh "URL"
   ```
3. Check generated file in `transcripts/`:
   - `videoID_videoTitle.txt`
   - includes full transcript, then `---` and `Summary:` section

## Behavior
- If the video title contains unsafe filename chars, they are sanitized.
- If transcription fails, script exits with an error message.
- Summary is derived from first few transcript lines (quick approximation).

## Notes
- `transcribe.sh` may include longer transcript content in chat output for debugging.
- This is a demo pipeline; the summary algorithm can be improved with an LLM or stricter sentence selection.