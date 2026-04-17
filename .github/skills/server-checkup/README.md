# server-checkup skill

SSH into a server and report a full health summary.

## Prerequisites

- **sshpass** must be installed on your local machine:
  ```bash
  brew install hudochenkov/sshpass/sshpass
  ```
- The target server must be reachable over SSH.

## Configuration

Connection credentials must be provided via environment variables or a local `.env` file.

Copy the example file and fill in your values:

```bash
cp .github/skills/server-checkup/.env.example .github/skills/server-checkup/.env
```

Then edit `.github/skills/server-checkup/.env`:

```bash
SERVER_HOST=your.host.address
SERVER_USER=your_user
SERVER_PASS=your_password
```

Or export them directly:

```bash
export SERVER_HOST=10.0.0.5
export SERVER_USER=admin
export SERVER_PASS=mypassword
```

## Copilot command

```
/server-checkup
```

Or ask naturally:

> "Check the server health"
> "Run a server checkup"
> "Is the server okay?"

## Manual smoke test

```bash
bash .github/skills/server-checkup/checkup.sh
```

## Output sections

The script collects and reports:

- **Uptime & Load** — how long the server has been running and current load averages
- **Memory** — RAM used vs available
- **Disk** — usage per mounted filesystem
- **CPU** — current utilisation and core count
- **Failed Services** — any systemd units in a failed state
- **Network** — active interfaces and IP addresses
- **Recent Logins** — last 5 login events

Copilot then interprets the raw output and produces a structured health report with an overall status verdict and recommendations if issues are found.

## Security note

Credentials should not be stored in the script. Use `.github/skills/server-checkup/.env` or environment variables instead.

This script is intended for **local, private use only**. Do not commit credentials to a public repository. For shared environments, prefer SSH key-based authentication.
