# SendAfrica Get Started

A skill project that accelerates onboarding for both developers (agents) and users onto the SendAfrica platform: **REST API**, **SDKs** (Python / TypeScript / Go), the **CLI**, and the **Agent MCP server**.

> **SendAfrica** is an SMS automation platform for Tanzania and supported international destinations. This skill helps you go from zero to your first sent, tracked SMS — across every surface the platform offers.

## Quick start

```bash
# 1. Clone this repo
git clone https://github.com/SendAfrica/sendafrica-get-started.git
cd sendafrica-get-started

# 2. Run the interactive checklist (recommended)
./scripts/get-started.sh

# 3. Or scaffold a starter project
./scripts/scaffold.sh python my-sms-app
```

## What's inside

| Path | Purpose |
|---|---|
| `SKILL.md` | Kilo skill definition |
| `agents/openai.yaml` | Agent interface config for Kilo |
| `guide.md` | Full step-by-step onboarding guide |
| `reference.md` | One-page reference: auth, endpoints, errors, rate limits, SMS parts, MCP tools |
| `templates/` | Ready-to-run starter projects in Python, TypeScript, Go, and curl |
| `scripts/get-started.sh` | Interactive checklist that validates each step |
| `scripts/scaffold.sh` | Project generator — copies a template into a new directory |
| `scripts/cli-fix.sh` | Applies the missing CLI entry point fix |
| `docs/` | Integration instructions for landing page, docs app, and CLI |

## Supported surfaces

| Surface | How to use |
|---|---|
| **REST API** | `curl` examples in `templates/curl/` |
| **Python SDK** | `pip install sendafrica` — `client.sms.send(...)` |
| **TypeScript SDK** | `npm install sendafrica` — `await client.sendSms(...)` |
| **Go SDK** | `go get github.com/SendAfrica/GO-SDK` — `client.SMS.Send(ctx, ...)` |
| **CLI** | `go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest` |
| **Agent MCP** | `uv run sendafrica-agent mcp` (stdio) or `/sse` (remote) |

## Key facts

- **API base**: `https://api.sendafrica.online` (all routes under `/v1`)
- **Auth**: `X-API-Key: SA-...` header or `Authorization: Bearer SA-...`
- **Billing**: 1 credit per SMS part. GSM-7: 160 chars (single) / 153 (multipart). UTF-16: 70 / 67.
- **Rate limits**: Free 60 req/min, Pro 600, Enterprise 6 000.
- **SMS `status: "Success"`** means provider submission accepted, **not** handset delivery. Reconcile via message logs.
- **Sandbox**: `POST /v1/sandbox/messages` — provider-free, credit-free testing.

## Prerequisites

You need a SendAfrica account and an API key (`SA-...` format, created in the dashboard under **Settings → API Keys**). The full key is shown **only once** at creation.

## License

MIT — see [LICENSE](LICENSE).
