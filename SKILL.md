---
name: sendafrica-get-started
description: "Use when onboarding to SendAfrica, integrating the public REST API or SDKs, sending or tracking SMS, managing contacts/campaigns/sender IDs, configuring signed webhooks, or using the SendAfrica Agent MCP tools."
---

# SendAfrica developer and agent guide

Use this skill to understand the SendAfrica product before changing an integration, writing examples, or operating the Agent. The implementation source of truth is the API workspace under `API/`; use `API/docs/developer.md`, `API/API_REFERENCE.md`, `API/docs/api-updates.md`, and the relevant `API/apps/*/routes.go` when a contract is uncertain.

## Product model

SendAfrica is an account-scoped SMS platform. A developer authenticates with an API key, sends messages through the public API or an SDK, spends credits per SMS part, and observes asynchronous delivery through message logs or signed webhooks.

The main public resources are:

- SMS: single send, bulk send, message logs, delivery state, and inbound/provider callbacks.
- Credits: current balance and transaction history.
- Contacts: lists, contacts, phone numbers, CSV import/export, duplicate checks, and optional Google Contacts sync.
- Campaigns: create, update, schedule against a contact list, inspect recipients, cancel, and delete.
- Sender IDs: requirements, account-owned requests, approval status, usable IDs, and the account default.
- Rates: public country lookup and rate card; use live rates for international pricing.
- Notifications: account-scoped notification listing and read state.
- Webhooks: account API-key webhook endpoints, delivery summaries, delivery records, activation, deletion, and one-time secret regeneration.

## Integration workflow

1. Read the relevant API documentation and inspect the current route/service implementation if docs disagree.
2. Use an API key for server-to-server work. Send it in `X-API-Key`; an opaque `Authorization: Bearer <api-key>` is also supported for account-scoped API-key-compatible routes.
3. Use `Idempotency-Key` for retries of side-effecting sends and campaign creation. Preserve the same key when retrying the same logical operation.
4. Validate destination format and estimate SMS parts before a large send. The server is authoritative for encoding and billing.
5. Check the credit balance before a batch. Treat provider acceptance as submission, not handset delivery.
6. Reconcile delivery with `GET /v1/sms/logs` or a verified SendAfrica webhook. Process webhook events durably and idempotently before returning 2xx.
7. Confirm high-impact actions with the user or calling application before execution: sending SMS, bulk sends, campaign creation/scheduling, importing contacts, and sender-ID requests.

Completion means the integration uses a current public contract, handles the response envelope and errors, protects credentials, and has a delivery-observation path.

## Public API facts

| Item | Current contract |
|---|---|
| Base URL | `https://api.sendafrica.online` |
| Version | `/v1` |
| Format | HTTPS + JSON; requests with bodies use `Content-Type: application/json` |
| Success envelope | `{ success: true, data, meta?, request_id, timestamp }` |
| Error envelope | `{ success: false, error: { code, message }, request_id, timestamp }` |
| API-key header | `X-API-Key: <key>` |
| Rate limits | Free 60, Pro 600, Enterprise 6,000 requests/minute |
| SMS billing | 1 credit per SMS part; GSM-7 160/153, Unicode UTF-16 70/67 |

Useful public routes include `POST /v1/sms/`, `POST /v1/sms/send`, `POST /v1/sms/bulk`, `GET /v1/sms/logs`, `GET /v1/credits/balance`, `GET /v1/credits/history`, `GET/POST /v1/contact-lists`, `GET/POST /v1/campaigns`, `GET /v1/rates`, and `GET/POST /v1/sender-ids`. Confirm exact request fields in the current API reference before generating code.

`status: "Success"` means the provider accepted submission. It does not mean the handset received the message. Delivery is asynchronous; late failures may cause an exact-once credit refund.

## Agent/MCP behavior

The SendAfrica Agent exposes account-safe tools for capability discovery, balance and usage, SMS, delivery lookup, contacts, campaigns, sender IDs, email-related agent features, documentation search, and model discovery. Treat the tool implementation and `Agent/sendafrica_agent/capabilities.py` as the source of truth for the installed version; do not assume a fixed tool count.

The Agent must:

- Keep read-only lookups parallel when safe.
- Request explicit confirmation before side effects, including every single SMS, bulk SMS, campaign, contact import, sender-ID request, and email send.
- Show recipient count, message, sender, estimated parts/credits, and schedule in the confirmation summary.
- Never claim delivery from submission success.
- Keep account and contact scope intact; never infer access to another account.
- Use structured errors and preserve request IDs when reporting failures.

Local MCP uses the installed Agent's stdio entry point. Remote MCP, when enabled by deployment configuration, uses its documented SSE endpoint and a separately provisioned MCP credential. Do not place either credential in examples or source files.

## Security boundary

This skill is intentionally public-integration-only. Never expose, copy, infer, or place in generated output:

- API keys, JWTs, refresh tokens, MCP tokens, webhook secrets, provider credentials, environment values, or database credentials.
- Internal admin routes, admin-only reports, profit/margin/provider-cost data, cross-account data, or privileged operational workflows.
- Raw personal data from contacts, message bodies, phone numbers, logs, or webhook payloads unless the user explicitly supplied it and it is necessary for the task.

Use placeholders such as `<SENDAFRICA_API_KEY>` and `<WEBHOOK_SECRET>`. Redact credentials and personal data in logs and examples. Store secrets in environment variables or a secrets manager, send them only over HTTPS, and remember that newly created API keys and webhook secrets are shown once. If a request asks for an internal-admin detail or secret, decline that part and provide the nearest public, account-scoped alternative.

## Supporting material

- `reference.md` — compact public endpoint, error, SDK, CLI, MCP, webhook, and safety reference.
- `guide.md` — user-facing onboarding walkthrough; keep examples aligned with this file and the API docs.
- `templates/` — starter projects; never add real credentials.
- `scripts/` — onboarding and scaffolding helpers.

## Maintenance rule

When the API changes, update this skill from the implementation and public API docs, then check every example for stale routes, auth claims, tool names, and accidental secrets. Keep privileged implementation details out of this skill even when they appear in repository source.

License: MIT
