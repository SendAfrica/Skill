---
name: sendafrica-get-started
description: "Step-by-step guide, starter templates, and scaffold scripts for getting started with the SendAfrica API, SDKs, CLI, and Agent (MCP)."
---

# Skill: SendAfrica Get Started

This skill accelerates onboarding for both **developers** (agents) and **users** onto the SendAfrica platform: REST API, official SDKs (Python / TypeScript / Go), the `sendafrica` CLI, and the SendAfrica Agent MCP server.

## What this skill provides

1. **Interactive checklist** — `scripts/get-started.sh` walks an agent or human through the full funnel: account → API key → first SMS (any surface) → balance check → delivery lookup → sandbox test. Each step prints a `✅` on success and a `❌` with a remediation hint on failure.

2. **Starter templates** — Ready-to-run code in `templates/` for every supported surface:
   - `templates/python/` — pip-installable project with error handling + webhook verification
   - `templates/typescript/` — npm project (dual CJS/ESM) with SMS part analysis
   - `templates/go/` — go module with context-aware client and typed errors
   - `templates/curl/` — single-file shell script for testing without SDK setup

3. **Scaffold script** — `scripts/scaffold.sh` copies a chosen template into a new project directory with `README.md`, `.env.example`, and `.gitignore` pre-configured.

4. **Quick reference** — `reference.md` consolidates auth patterns, endpoint map, error codes, rate limits, SMS part accounting, and MCP tool list on one page.

5. **Integration instructions** — `docs/` contains step-by-step guides for adding get-started content to:
   - The **landing page** (`sendafrica-landing-update`) — new `/developers/get-started` route
   - The **docs app** (`docs`) — new typed content modules under the "Getting Started" nav group
   - The **CLI** — fix for the missing `cmd/sendafrica/main.go` entry point

6. **CLI fix** — `docs/cli-entry-point-fix.md` documents and provides the missing entry point file so `go build` and `go install` work.

## How to use this skill

```bash
# Run the interactive checklist (recommended first step)
./scripts/get-started.sh

# Or scaffold a new project in your preferred language
./scripts/scaffold.sh python my-sms-app
./scripts/scaffold.sh typescript my-sms-app
./scripts/scaffold.sh go my-sms-app
```

## Prerequisites

- A SendAfrica account (`https://app.sendafrica.online`)
- An API key (`SA-...` format, created in the dashboard under Settings → API Keys)
- At least one of: Python 3.9+, Node 18+, Go 1.22+, or curl

## Key facts baked into this skill

| Concept | Value |
|---|---|
| API base URL | `https://api.sendafrica.online` (all routes under `/v1`) |
| Response envelope | `{ success, data, error, meta, request_id, timestamp }` |
| Auth header | `X-API-Key: SA-...` (or `Authorization: Bearer SA-...`) |
| SMS billing | 1 credit / part; GSM-7: 160 single / 153 multipart; UTF-16: 70 / 67 |
| Rate limits | Free 60, Pro 600, Enterprise 6000 req/min |
| Sandbox base | `https://api.sendafrica.online/v1/sandbox` (API key only, in-memory, no credits) |
| Agent MCP transports | stdio (local), `/sse` (remote, needs `AGENT_MCP_AUTH_TOKEN`) |
| SDKs | Python `sendafrica`, npm `sendafrica`, Go `github.com/SendAfrica/GO-SDK` |

## License

MIT
