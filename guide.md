# SendAfrica Get Started Guide

This guide walks you through every step of onboarding to the SendAfrica platform — from creating your first account to sending your first tracked SMS, across the REST API, official SDKs, CLI, and the Agent (MCP).

## Prerequisites

- A SendAfrica account: [https://app.sendafrica.online](https://app.sendafrica.online)
- An API key in `SA-<64 hex chars>` format (created in the dashboard: **Settings → API Keys → Create**)
- The full key is shown **only once** at creation. Store it securely.
- At least one of: Python 3.9+, Node 18+, Go 1.22+, or curl

## Fact sheet

| Concept | Value |
|---|---|
| API base URL | `https://api.sendafrica.online` (all routes under `/v1`) |
| Auth header | `X-API-Key: SA-...` (or `Authorization: Bearer SA-...`) |
| Response envelope | `{ success, data, error, meta, request_id, timestamp }` |
| SMS billing | 1 credit / part. GSM-7: 160 single / 153 multipart. UTF-16: 70 / 67 |
| Rate limits | Free 60, Pro 600, Enterprise 6 000 req/min |
| Sandbox | `POST /v1/sandbox/messages` — API key only, in-memory, zero credits |
| Agent MCP (stdio) | `uv run sendafrica-agent mcp` |
| Agent MCP (remote SSE) | `https://agent.sendafrica.online/sse` (needs `AGENT_MCP_AUTH_TOKEN`) |

---

## Step 1 — Get your API key

1. Sign up at [https://app.sendafrica.online](https://app.sendafrica.online) and verify your email (a 6-digit OTP is sent automatically).
2. Log in to the dashboard and go to **Settings → API Keys**.
3. Click **Create API Key**, give it a name, and copy the key.
4. Store it in your environment:

```bash
export SENDAFRICA_API_KEY="SA-your-key-here"
```

> **Warning**: The full key is shown **only once** at creation. If you lose it, revoke it from the dashboard and create a new one.

---

## Step 2 — Send your first SMS

### Via REST API (curl)

```bash
curl -X POST https://api.sendafrica.online/v1/sms/ \
  -H "X-API-Key: $SENDAFRICA_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: order-1234" \
  -d '{
    "to": "0712345678",
    "message": "Hello from SendAfrica! Your order is ready.",
    "from": "MyBrand"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message_id": "<MESSAGE_ID>",
    "status": "Success",
    "cost": "TZS 35.00",
    "credits_used": 1
  },
  "request_id": "dfffa252-4781-43ff-8e1a-bf01a754d66a",
  "timestamp": "2026-06-11T16:24:05Z"
}
```

### Via Python SDK

```bash
pip install sendafrica
```

```python
from sendafrica import SendAfrica

client = SendAfrica(api_key="SA-xxxxx")

result = client.sms.send(
    to="0712345678",
    message="Hello from SendAfrica! Your order is ready.",
    sender="MyBrand",
)

print(result.message_id)   # "SA-..."
print(result.status)       # "Success"
print(result.credits_used) # 1
```

### Via TypeScript SDK

```bash
npm install sendafrica
```

```typescript
import { SendAfricaClient } from "sendafrica";

const client = new SendAfricaClient({
  apiKey: process.env.SENDFRICA_API_KEY!,
});

const result = await client.sms.send(
  { to: "0712345678", message: "Hello from SendAfrica! Your order is ready.", from: "MyBrand" },
  { idempotencyKey: "order-1234" },
);

console.log(result.messageId, result.status, result.creditsUsed);
```

### Via Go SDK

```bash
go get github.com/SendAfrica/GO-SDK
```

```go
package main

import (
    "context"
    "fmt"
    "log"

    sendafrica "github.com/SendAfrica/GO-SDK"
)

func main() {
    client := sendafrica.NewClient("SA-xxxxx")

    result, err := client.SMS.Send(context.Background(), sendafrica.SendSMSRequest{
        To:      "0712345678",
        Message: "Hello from SendAfrica! Your order is ready.",
        Sender:  "MyBrand",
    })
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(result.MessageID, result.Status, result.CreditsUsed)
}
```

### Via CLI

```bash
go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest

sendafrica sms-send \
  --to "0712345678" \
  --message "Hello from SendAfrica!" \
  --from "MyBrand"
```

> **Note**: The CLI entry point (`cmd/sendafrica/main.go`) was missing from the repo. The fix is included in `docs/cli-entry-point-fix/main.go` and applied by `./scripts/cli-fix.sh`.

---

## Step 3 — Check your balance

```bash
# REST API
curl https://api.sendafrica.online/v1/credits/balance \
  -H "X-API-Key: $SENDAFRICA_API_KEY"
# => { "success": true, "data": { "account_id": "...", "balance": 5000 } }

# Python
balance = client.credits.balance()
print(balance.balance)

# TypeScript
const balance = await client.credits.balance();
console.log(balance.balance);

# Go
bal, _ := client.Credits.Balance(context.Background())
fmt.Println(bal.Balance)

# CLI
sendafrica credits-balance
```

---

## Step 4 — Track delivery

A successful send responds with `status: "Success"`, which means the gateway **accepted** the message — not that the phone received it. Delivery state arrives later via message logs:

```bash
curl "https://api.sendafrica.online/v1/sms/logs?status=delivered&per_page=10" \
  -H "X-API-Key: $SENDAFRICA_API_KEY"
```

```python
logs = client.sms.logs(status="delivered", search="order")
for log in logs.items:
    print(log.id, log.status, log.delivered_at)
```

```typescript
const logs = await client.sms.logs({ status: "delivered", perPage: 10 });
for (const log of logs) {
  console.log(log.id, log.status, log.deliveredAt);
}
```

```go
logs, _ := client.SMS.Logs(context.Background(), sendafrica.MessageLogQuery{
    Status:  "delivered",
    PerPage: 10,
})
for _, log := range logs.Items {
    fmt.Println(log.ID, log.Status, log.DeliveredAt)
}
```

```bash
sendafrica sms-logs --status delivered
```

---

## Step 5 — Test without credits (Sandbox)

The sandbox lets you exercise the full integration flow without calling real providers or deducting credits:

```bash
# Create a simulated message
curl -X POST https://api.sendafrica.online/v1/sandbox/messages \
  -H "X-API-Key: $SENDAFRICA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "+264811234567",
    "message": "Your order has been received.",
    "scenario": "accepted"
  }'

# Simulate delivery transition
curl -X POST \
  "https://api.sendafrica.online/v1/sandbox/messages/$MESSAGE_ID/delivery" \
  -H "X-API-Key: $SENDAFRICA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"status":"delivered"}'
```

See the full sandbox quickstart in the docs at [SendAfrica Sandbox Guide](https://docs.sendafrica.online/sandbox).

---

## Step 6 — Connect via Agent MCP (for AI assistants)

The SendAfrica Agent exposes 13 MCP tools. Connect Claude, Cursor, or Gemini:

### Local stdio MCP

Add to your MCP client configuration (e.g., Claude Desktop `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "sendafrica": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/SendAfrica-Agent", "sendafrica-agent", "mcp"],
      "env": {
        "SENDAFRICA_API_KEY": "<SENDAFRICA_API_KEY>"
      }
    }
  }
}
```

### Remote SSE MCP

```
# Requires AGENT_MCP_AUTH_TOKEN
https://agent.sendafrica.online/sse
Authorization: Bearer <your-mcp-token>
```

Available tools include `send_sms`, `send_bulk_sms`, `get_account_balance`, `get_delivery_status`, `list_contacts`, `create_campaign`, `send_email`, `list_inbound_emails`, `search_documentation`, `list_models`, and more. See `reference.md` for the full table.

---

## Next steps

| Goal | Resource |
|---|---|
| Build a full SMS integration | `templates/` starter projects |
| Bulk campaigns | Agent `create_campaign` tool or API `POST /v1/campaigns` |
| Custom sender IDs | `POST /v1/sender-ids` → wait for `approved` → use `from` field |
| Webhook delivery tracking | SDK webhook verification helpers |
| Phone OTP verification | [OTP Guide on docs.sendafrica.online](https://docs.sendafrica.online/guides/otp) |
| Error handling patterns | See `reference.md` for the error code table |
| Sandbox testing | [Sandbox Quickstart](https://docs.sendafrica.online/sandbox/quickstart) |

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `401` / `invalid_api_key` | API key missing or revoked | Check at https://app.sendafrica.online/settings/api-keys |
| `402` / `insufficient_credits` | Not enough credits | Top up via dashboard or mobile money voucher |
| `403` / `invalid_phone` | Phone not a valid TZ mobile | Use `07xxxxxxxx` or `+2557xxxxxxxx` |
| `429` / `rate_limit_exceeded` | Hit your plan limit | Wait, or upgrade plan |
| SMS sends but from wrong sender | Custom sender ID not approved yet | Request via `POST /v1/sender-ids`, wait for `approved` |
| `Success` status but not delivered | Provider accepted, not yet on handset | Poll message logs for `delivered` |
