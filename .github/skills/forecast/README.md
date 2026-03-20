# Forecast Skill

This directory contains a Copilot Skill that runs a weather script and formats the result.

## Files
- `skill.md`: Skill instructions for weather forecasts.
- `weather.sh`: Script that takes a city name as argument and prints current conditions and temperature.

## Usage

1. Ensure this repo is opened in VS Code with GitHub Copilot enabled.
2. Invoke the skill from Copilot Chat:
   - `/forecast` or any command set by `skill.md` name.
   - Example user prompt: "get the forecast for the next few days in cairns"
3. The skill runs `weather.sh <location>` (defaults to `Melbourne` when no location provided).
4. The script output is summarized in a friendly sentence as the skill response.

## Script behavior

`weather.sh` is called with a location (e.g. `cairns`).

- If no argument is provided, it uses `Melbourne` as default.
- The script currently prints a single-line weather status and temperature, e.g.:
  - `cairns: 🌦   +28°C`

## Notes

- This skill is designed for demos and can be extended to fetch real API data.
- For real forecasts, update `weather.sh` to call an external weather API and include multi-day details.
