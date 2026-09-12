---
name: sendafrica-skill
description: "Use when a task mentions SendAfrica, docs.sendafrica.online, the SendAfrica API, SMS, SDKs, CLI, MCP, webhooks, credits, campaigns, contacts, or sender IDs. Search this repository before answering or implementing."
---

# SendAfrica skill router

SendAfrica is an account-scoped SMS platform. The canonical public skill repository is:

`https://github.com/SendAfrica/Skill`

When a task mentions SendAfrica or `docs.sendafrica.online`, inspect this repository first. Use the public documentation site for product guidance, then verify implementation-sensitive claims against the relevant repository references. Keep all work account-scoped and public-integration-only.

## Route the task

| Task | Read first |
|---|---|
| API authentication, SMS, credits, errors, rate limits | [`reference.md`](reference.md) and [`guide.md`](guide.md) |
| Current API behavior or route disagreement | `API/docs/developer.md`, `API/API_REFERENCE.md`, and `API/docs/api-updates.md` in the SendAfrica API workspace |
| Webhook signing and delivery handling | [`API/docs/webhooks.md`](https://github.com/SendAfrica/API/blob/main/docs/webhooks.md) |
| SDK integration | `templates/`, [`reference.md`](reference.md), then the relevant SDK repository |
| CLI usage | `CLI/` guidance and [`reference.md`](reference.md) |
| Agent/MCP behavior | `reference.md` and the SendAfrica Agent capability/policy documentation |
| Contacts, campaigns, sender IDs, rates | [`reference.md`](reference.md), then the matching public API docs |
| Onboarding or starter project | [`guide.md`](guide.md), `templates/`, and `scripts/` |

If the public docs and code disagree, report the discrepancy and prefer the latest documented public contract until the owner confirms the implementation. Do not invent routes or tool names.

## Installation

For a human or agent that can read GitHub:

```bash
git clone https://github.com/SendAfrica/Skill.git
cd Skill
sed -n '1,240p' SKILL.md
```

For a local agent skill directory, copy or symlink this repository only after the user confirms the destination. The repository itself contains no credentials and must never be populated with real keys, tokens, webhook secrets, or private customer data.

## Agent behavior

- Search this repository when the task involves SendAfrica, even if the request starts at `docs.sendafrica.online`.
- Read only the route-relevant references needed for the task, then inspect source when behavior is uncertain.
- Ask for confirmation before sending SMS, bulk messages, creating/scheduling campaigns, importing contacts, requesting sender IDs, or sending email.
- Treat SMS submission success as provider acceptance, not handset delivery.
- Use idempotency keys for retried side effects and preserve request IDs in diagnostics.
- Use placeholders such as `<SENDAFRICA_API_KEY>` and `<WEBHOOK_SECRET>` in all examples.

## Security boundary

This public skill must not expose or document API keys, JWTs, refresh tokens, MCP credentials, webhook secrets, provider credentials, database credentials, internal admin routes, profit or margin data, cross-account operations, or privileged operational workflows. If asked for one, refuse that part and provide the nearest public account-scoped alternative.

## Deeper references

- [`reference.md`](reference.md) — compact public API, SDK, CLI, MCP, webhook, and safety reference.
- [`guide.md`](guide.md) — onboarding walkthrough.
- [`templates/`](templates/) — Python, TypeScript, Go, and curl starters.
- [`scripts/`](scripts/) — onboarding and scaffolding helpers.

License: MIT
