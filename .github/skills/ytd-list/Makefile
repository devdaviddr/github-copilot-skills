# Makefile for ytd-list skill
PY=python
WRAPPER=.github/skills/ytd-list/run_ytd_list.sh

.PHONY: help install-yt-dlp run-api run-yt-dlp run

help:
	@echo "Targets: install-yt-dlp, run (pass ARGS='--channel-url ...'), run-api, run-yt-dlp"

install-yt-dlp:
	@echo "Installing yt-dlp (user)"
	@pip install --user yt-dlp

run:
	@echo "Running wrapper with ARGS='$(ARGS)'"
	@$(WRAPPER) $(ARGS)

run-api:
	@echo "Run API script (requires YT_API_KEY env or --api-key)"
	@$(PY) .github/skills/ytd-list/fetch_videos.py $(ARGS)

run-yt-dlp:
	@echo "Run yt-dlp script"
	@$(PY) .github/skills/ytd-list/fetch_videos_yt_dlp.py $(ARGS)
