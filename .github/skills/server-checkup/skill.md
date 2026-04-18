---
name: server-checkup
description: SSHes into the configured server and reports a full health summary including CPU, memory, disk, uptime, and failed services. Use when the user asks to check the server, check server health, or run a server checkup.
---

## Server Checkup

Before running, ask the user one question:

> "Would you like to include Docker container health in the checkup? (yes/no)"

- If **yes**: run `checkup.sh --docker`
- If **no** or no answer given: run `checkup.sh` with no arguments

The script will SSH into the server and collect health metrics.

Once the script completes, parse its output sections and produce a structured health report:

### Report format

**Overall Status** — a single emoji + word verdict:
- ✅ Healthy — no issues detected
- ⚠️ Warning — degraded but running
- 🔴 Critical — action required

Then report each section:

1. **Uptime & Load** — state how long the server has been up and whether the load average is high relative to CPU count (warn if 1-min load > number of CPUs)
2. **Memory** — show used/total and flag if less than 10% is free
3. **Disk** — list all mounted filesystems; flag any partition over 80% used
4. **CPU** — note current CPU utilisation if available
5. **Failed Services** — list any failed systemd units; if none, say "All services running"
6. **Network** — list active interfaces and their IPs
7. **Recent Logins** — show who logged in recently
8. **Docker Containers** *(only if `--docker` was passed)* — show running containers with CPU/memory usage; list any stopped or dead containers and flag them as warnings

End with a **Recommendations** section if any warnings or critical issues were found, otherwise say "No action needed."

### Saving the report

The script prints three lines at the end:
```
RAW_OUTPUT_FILE=/path/to/outputs/server-checkup/TIMESTAMP_raw.txt
REPORT_FILE=/path/to/outputs/server-checkup/TIMESTAMP_checkup.md
RECS_FILE=/path/to/outputs/server-checkup/TIMESTAMP_recommendations.md
```

After producing the structured report above, write it as a markdown file to the path given by `REPORT_FILE`. The file must begin with a metadata header:

```markdown
# Server Health Report
**Host:** <SERVER_HOST>
**Checked:** <timestamp from filename>
**Docker checked:** yes/no

---
```

Followed by the full structured report (status verdict + all sections + recommendations).

If the report contains any recommendations, prompt the user in chat with the exact question:

> "Recommendations were detected. Would you like to save an action report with step-by-step remediation suggestions to RECS_FILE? (yes/no)"

- If the user answers `yes`: write a second markdown file to the path printed by `RECS_FILE`. This file must start with a header:

```markdown
# Recommendations Action Report
**Host:** <SERVER_HOST>
**Generated:** <timestamp from filename>

---
```

Then include a concise actionable list derived from the `Recommendations` section of the main report. Each item should be a short bullet with an optional one-line command or suggested next step. Example:

- Disable the unused Wake-on-LAN service: `sudo systemctl disable wol@enp5s0.service`
- Clean up old Docker images: `docker image prune -af`

- If the user answers `no`: do not write the recommendations file.

Finally, tell the user which files were created and show their relative paths (for example: `outputs/server-checkup/2026-04-17_09-42-49_checkup.md` and `outputs/server-checkup/2026-04-17_09-42-49_recommendations.md`).
