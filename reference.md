# SendAfrica Get Started — Quick Reference

Everything you need on a single page. Bookmark this.

## Core endpoints

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/v1/sms/` | API Key | Send single SMS |
| `POST` | `/v1/sms/bulk` | API Key / JWT | Send to up to 100 recipients |
| `GET` | `/v1/sms/logs` | API Key / JWT | Delivery status for sent messages |
| `GET` | `/v1/credits/balance` | API Key / JWT | Current credit balance |
| `GET` | `/v1/credits/history` | API Key / JWT | Transaction history |
| `GET` | `/v1/sender-ids/usable` | API Key / JWT | Platform defaults + approved custom IDs |
| `POST` | `/v1/sender-ids` | API Key / JWT | Request a custom sender ID (always confirmation-gated) |
| `GET` | `/v1/rates` | None (public) | Destination rate card |
| `GET` | `/v1/packages` | None (public) | Pricing packages |
| `GET` | `/v1/sandbox/capabilities` | API Key | Sandbox test surface discovery |

## Auth patterns

```bash
# API Key (developer / server-to-server)
curl -H "X-API-Key: $SENDAFRICA_API_KEY" https://api.sendafrica.online/v1/credits/balance

# Or equivalently (opaque Bearer)
curl -H "Authorization: Bearer $SENDAFRICA_API_KEY" https://api.sendafrica.online/v1/credits/balance

# JWT (dashboard sessions only) — obtained via POST /v1/auth/login
curl -H "Authorization: Bearer $JWT_TOKEN" https://api.sendafrica.online/v1/sms/logs
```

### Auth parity

| Surface | API Key | JWT |
|---|---|---|
| Send SMS | ✅ | ✅ |
| Credits balance/history | ✅ | ✅ |
| Contacts & campaigns | ✅ | ✅ |
| Sender ID requests | ✅ | ✅ |
| Payments / vouchers | ✅ | ✅ |
| Notifications | ✅ | ✅ |
| Support chat | ✅ | ✅ |
| **Logout, password change** | ❌ | ✅ only |
| **Email/phone verification** | ❌ | ✅ only |
| **API key management** | ❌ | ✅ only |
| **Admin routes** (`/v1/admin/*`) | ❌ | ✅ (`is_admin = true`) |
| **Sandbox** | ✅ | ❌ |

## Error codes

| HTTP | `error.code` | Agent action |
|---|---|---|
| 400 | `validation_error` | Reject input — check field format |
| 400 | `invalid_request` | Malformed JSON body |
| 401 | `unauthorized` | No key / key expired — check key |
| 401 | `invalid_token` | Token malformed or blacklisted |
| 402 | `insufficient_credits` | Surface a top-up prompt — don't retry |
| 403 | `forbidden` | Authenticated but not allowed |
| 404 | `not_found` | Resource doesn't exist |
| 409 | `email_exists` | Registration with duplicate email |
| 429 | `rate_limit_exceeded` | Wait `Retry-After` seconds, then retry once |
| 500 | `server_error` | Retry with backoff + same `Idempotency-Key` |

## Rate limits

| Plan | Requests / minute |
|---|---|
| Free | 60 |
| Pro | 600 |
| Enterprise | 6 000 |

Headers on every response: `X-RateLimit-Limit`, `X-RateLimit-Remaining`.

## SMS part accounting

| Encoding | Single part | Multipart segment |
|---|---|---|
| GSM-7 (septets) | 160 | 153 |
| UTF-16 (code units) | 70 | 67 |

- GSM-7 extended characters (`^`, `{`, `}`, `[`, `]`, `\`, `~`, `|` €) consume **2 septets**.
- Smart punctuation is normalized before counting.
- Emoji and supplementary characters use UTF-16 and consume 2 code units each.
- **1 credit = 1 part.**
- Tanzania Tier 1 = 1 credit per part. International credits from the rate card.

## SDK quickstarts

### Python (`sendafrica`)

```bash
pip install sendafrica
```

```python
from sendafrica import SendAfrica
client = SendAfrica(api_key="SA-xxxxx")

# Send SMS
result = client.sms.send(to="0712345678", message="Hello", sender="MyBrand")

# Preview parts/credits without sending
analysis = client.sms.analyze("Hello")
# { encoding: "GSM-7", length: 5, septets: 5, parts: 1, credits: 1 }

# Bulk send
results = client.sms.send_many([
    {"to": "0711111111", "message": "Hello"},
    {"to": "0722222222", "message": "Hi there"},
])

# Balance
balance = client.credits.balance()

# Webhook verification
from sendafrica.webhooks import verify_webhook_signature
verify_webhook_signature(payload, signature, secret)
```

Error handling: `AuthenticationError`, `ValidationError`, `InsufficientCreditsError`, `RateLimitError` (has `.retry_after`), `NotFoundError`, `ServerError`, `APIConnectionError`, `WebhookSignatureError`.

### TypeScript (`sendafrica`)

```bash
npm install sendafrica
```

```typescript
import { SendAfricaClient, getSmsPartInfo } from "sendafrica";

const client = new SendAfricaClient({ apiKey: process.env.SENDFRICA_API_KEY! });

const result = await client.sms.send(
  { to: "0712345678", message: "Hello", from: "MyBrand" },
  { idempotencyKey: "order-1234" },
);

const info = getSmsPartInfo("Hello");
// { encoding: "GSM-7", length: 5, parts: 1, creditsRequired: 1 }

const balance = await client.credits.balance();
```

Errors: `SendAfricaError` (with `.code`, `.httpStatus`, `.isInsufficientCredits`, `.isRateLimited`, `.isUnauthorized`), `SendAfricaNetworkError`, `InvalidPhoneNumberError`.

### Go (`github.com/SendAfrica/GO-SDK`)

```bash
go get github.com/SendAfrica/GO-SDK
```

```go
import (
    "context"
    sendafrica "github.com/SendAfrica/GO-SDK"
)

client := sendafrica.NewClient("SA-xxxxx",
    sendafrica.WithMaxRetries(3),
    sendafrica.WithBearerToken(os.Getenv("JWT_TOKEN")), // JWT-only mode
    sendafrica.WithWebhookSecret(os.Getenv("WH_SECRET")),
)

result, err := client.SMS.Send(context.Background(), sendafrica.SendSMSRequest{
    To: "0712345678", Message: "Hello", Sender: "MyBrand",
})

balance, _ := client.Credits.Balance(context.Background())

// HMAC webhook verification
event, err := client.Webhooks.Parse(payload, signature, "")

// Error classification
var apiErr *sendafrica.APIError
if errors.As(err, &apiErr) {
    if apiErr.IsInsufficientCredits() { ... }
    if apiErr.IsRateLimited() { ... }
    if apiErr.IsUnauthorized() { ... }
}
```

### CLI (`sendafrica-cli`)

```bash
go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest

# All commands support --output table|json|yaml
sendafrica sms-send --to 0712345678 --message "Hello" --from MyBrand
sendafrica sms-bulk --to 0711111111,0722222222 --message "Hello"
sendafrica sms-logs --status delivered
sendafrica credits-balance
sendafrica contacts list
sendafrica campaigns create --name "Sale" --message "50% off" --from MyBrand
sendafrica sender-ids list
sendafrica config add-profile myprofile --api-key SA-xxxxx
```

Profile management: `config add-profile`, `config use`, `config list`, `config delete`, `config show` (masks secrets).

No `.env` loading by default — credentials from env vars (`SENDAFRICA_API_KEY`, `SENDAFRICA_JWT_TOKEN`), config file (`~/.config/sendafrica-cli/config.json`, 0600 perms), or flags. API key takes priority over JWT.

## Agent MCP tools

The SendAfrica Agent (`sendafrica-agent`) exposes these FastMCP tools:

### SMS tools (SendAfrica)

| Tool | Parameters | Description | Confirmation |
|---|---|---|---|
| `get_agent_capabilities` | — | Version, transports, tool safety, SMS behavior | None |
| `get_account_balance` | — | SMS credit balance | None |
| `get_usage_summary` | `period="this_month"` | Count of sent/delivered/failed SMS | None |
| `list_contacts` | `list_id="1"`, `query=""` | Search/list phonebook contacts | None |
| `get_delivery_status` | `message_id=""` | Query delivery status for one message | None |
| `send_sms` | `to`, `message`, `sender_id=""`, `idempotency_key=""` | Send one SMS | None |
| `send_bulk_sms` | `recipients[]`, `message`, `sender_id=""`, `idempotency_key=""`, `confirmed` | Bulk send | >10 recipients |
| `create_campaign` | `name`, `message`, `contact_group_id`, `scheduled_at=""`, `confirmed`, `idempotency_key=""` | Schedule campaign | Always |

### Sender ID tools

| Tool | Parameters | Description | Confirmation |
|---|---|---|---|
| `get_sender_id_requirements` | — | Registration requirements, eligibility, rules | None |
| `list_sender_ids` | — | List registered sender IDs | None |
| `get_sender_id` | `sender_id` | Inspect a specific sender ID | None |
| `list_usable_sender_ids` | `provider=""` | Platform defaults + approved custom IDs | None |
| `request_sender_id` | `name`, `purpose`, `sample_message`, `country="TZ"`, `documents`, `confirmed` | Submit registration request | Always |

### Email tools (MailAfrica)

| Tool | Parameters | Description | Confirmation |
|---|---|---|---|
| `send_email` | `to[]`, `subject`, `body`, `from_address=""`, `confirmed` | Send transactional email | >5 recipients |
| `list_inbound_emails` | `address_id=1`, `limit=20` | List received inbound emails | None |
| `get_email_balance` | — | MailAfrica wallet & credit balance | None |

### Documentation & gateway tools

| Tool | Parameters | Description |
|---|---|---|
| `search_documentation` | `query`, `target="all"` | Search docs & SDK code samples |
| `get_documentation_topic` | `topic_id` | Full guide & SDK snippets for a topic |
| `list_models` | — | Cached Ngamia model discovery |

### MCP connection configs

**Local stdio:**
```json
{
  "mcpServers": {
    "sendafrica": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/SendAfrica-Agent", "sendafrica-agent", "mcp"],
      "env": {
        "SENDAFRICA_API_KEY": "SA-your-key-here",
        "MAILAFRICA_API_KEY": "MA-your-key-here"
      }
    }
  }
}
```

**Remote SSE:**
- URL: `https://agent.sendafrica.online/sse`
- Auth: `Authorization: Bearer <AGENT_MCP_AUTH_TOKEN>` or `X-MCP-Token`
- Token is separate from account API keys; fails closed (503) if not configured

## Sandbox

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/v1/sandbox/capabilities` | Supported scenarios, statuses, endpoints |
| `POST` | `/v1/sandbox/messages` | Create a simulated SMS |
| `GET` | `/v1/sandbox/messages` | List this account's sandbox messages |
| `GET` | `/v1/sandbox/messages/{id}` | Inspect one message + encoding + events |
| `POST` | `/v1/sandbox/messages/{id}/delivery` | Simulate delivery status transition |
| `DELETE` | `/v1/sandbox/messages` | Reset this account's sandbox data (in-memory) |

Scenarios: `accepted` → initial `sent`, `rejected` → initial `rejected`, `transport_error` → initial `failed`.
Delivery statuses: `sent`, `delivered`, `failed`, `expired`, `rejected`.
Terminal transitions are monotonic; conflicting callbacks are ignored with `Sandbox-Transition: ignored` header.

## Key patterns to remember

- **Idempotency**: Always pass `Idempotency-Key` on writes. Safe to retry — same key returns cached response instead of double-sending/double-charging.
- **Submission ≠ delivery**: `status: "Success"` means provider accepted, not handset-delivered. Read message logs.
- **Sender IDs are free but must be approved**: Omit `from` to use platform default `SENDAFRICA`. Custom names via `POST /v1/sender-ids`, wait for `approved` status.
- **SMS `Success` is per-submission**: Provider delivery failures still consume credits. The platform automatically refunds on gateway failure.
- **Never commit API keys to source**: Load from environment variables or a secrets manager.
- **Sandbox for everything**: Use sandbox endpoints for integration tests, CI, and dashboard prototyping — zero provider calls, zero credit deductions.
