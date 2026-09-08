# Docs App Integration Instructions

This document describes how to integrate the SendAfrica Get Started skill into the **docs app** repository (`docs/`).

## Goal

Add new documentation pages to the existing typed-content architecture that provide a complete onboarding path. These pages integrate seamlessly with the existing nav groups and content model — no new routing or infrastructure changes required.

## Architecture refresher

The docs app uses a typed content model:
- **Content modules** live in `lib/docs/content/*.ts` and export `DocPage` objects
- **Block types** are defined in `lib/docs/types.ts` (9 variants: h2, h3, p, list, code, tabs, table, callout, endpoint, divider)
- **Registry** in `lib/docs/registry.ts` composes pages into `docPages[]` and defines `navGroups[]`
- A single catch-all page `app/[[...slug]]/page.tsx` renders any registered page

## Files to create/modify

### 1. New content module: `lib/docs/content/get-started.ts`

Create a new file exporting three `DocPage` objects:

```typescript
// lib/docs/content/get-started.ts
import type { DocPage } from "../types";

export const getStartedOverview: DocPage = { ... };
export const getStartedSdks: DocPage = { ... };
export const getStartedCli: DocPage = { ... };
export const getStartedAgentMcp: DocPage = { ... };
```

#### `getStartedOverview` (slug: `get-started`)

- **title**: "Get Started"
- **description**: "Send your first SMS with SendAfrica in under five minutes — pick your surface (API, SDK, CLI, or Agent MCP) and follow along."
- **group**: `start` (belongs to the existing "Getting Started" nav group)
- **blocks**:
  1. `p` — intro paragraph
  2. `list` (ordered) — 5-step funnel: Get API key → Send first SMS → Check balance → Track delivery → Test sandbox
  3. `callout` (danger) — "The full API key is shown only once at creation"
  4. `table` — surface comparison (API, Python SDK, TypeScript SDK, Go SDK, CLI, Agent MCP)
  5. `h2` "Send your first SMS"
  6. `tabs` — four language tabs (curl, python, typescript, go)
  7. `table` — response fields explanation
  8. `h2` "Check your balance"
  9. `tabs` — curl/python/typescript/go variants
  10. `callout` (info) — "Success means provider submission, not handset delivery"
  11. `h2` "Track delivery"
  12. `tabs` — curl/python/typescript/go/log command variants
  13. `callout` (tip) — idempotency key recommendation
  14. `h2` "Test the sandbox"
  15. `code` (bash) — POST /v1/sandbox/messages example
  16. `callout` (info) — sandbox is safe, zero-credit, in-memory

#### `getStartedSdks` (slug: `get-started/sdks`)

- **title**: "SDK Quickstarts"
- **description**: "Install and use the official SendAfrica SDKs in Python, TypeScript, and Go — idiomatic wrappers with typed responses, retries, and webhook verification."
- **group**: `start`
- **blocks**:
  1. `p` — intro
  2. `table` — feature matrix (same as existing `sdks.ts` overview)
  3. `h2` "Python" → install + client setup + send + error handling
  4. `h2` "TypeScript" → install + client setup + send + SMS part analysis
  5. `h2` "Go" → install + client setup + send + error handling

#### `getStartedCli` (slug: `get-started/cli`)

- **title**: "Command Line Interface"
- **description**: "Install and use the sendafrica CLI to send SMS, manage contacts, campaigns, credits, and sender IDs from the terminal."
- **group**: `start`
- **blocks**:
  1. `p` — intro
  2. `callout` (warning) — CLI entry point note (the `cmd/sendafrica/main.go` is missing from the upstream repo; apply the fix from `docs/cli-entry-point-fix/main.go` via `./scripts/cli-fix.sh`)
  3. `h2` "Install" → `go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest`
  4. `h2` "First commands" → table of `sms-send`, `sms-bulk`, `sms-logs`, `credits-balance`, `contacts list`, `campaigns list`, `sender-ids list`, `config add-profile`
  5. `h2` "Authentication" → API key vs JWT, credential resolution chain, no `.env` loading
  6. `h2` "Output formats" → `table`, `json`, `yaml` via `--output` flag

#### `getStartedAgentMcp` (slug: `get-started/agent-mcp`)

- **title**: "Agent MCP Quickstart"
- **description**: "Connect your AI assistant (Claude, Cursor, Gemini) to the SendAfrica Agent via FastMCP for conversational SMS, sender ID, and email actions."
- **group**: `start`
- **blocks**:
  1. `p` — intro
  2. `h2` "What the Agent can do" → list of 13 tools
  3. `table` — tool reference table (same as in `reference.md`)
  4. `callout` (danger) — confirm-before-send guardrails: bulk SMS >10, campaign creation, email >5
  5. `h2` "Local stdio MCP" → JSON config snippet for Claude Desktop
  6. `h2` "Remote SSE MCP" → URL + auth header explanation
  7. `callout` (tip) — `get_agent_capabilities` is the first tool to call for feature discovery

### 2. Update the registry: `lib/docs/registry.ts`

Import the new module and add pages to `docPages[]`:

```typescript
// Add to imports (alphabetical, after "getting-started")
import * as getStarted from "./content/get-started";

// Add to navGroups (if needed — existing "start" group suffices)
// { key: "start", label: "Getting Started", icon: "rocket" }  ← already exists

// Add to docPages array, after the existing Getting Started pages:
getStarted.getStartedOverview,
getStarted.getStartedSdks,
getStarted.getStartedCli,
getStarted.getStartedAgentMcp,
```

Suggested position: after `gettingStarted.phoneNumbers` and before `senderIds.senderIds`.

### 3. Update `GROUP_SUMMARIES` (in `app/llms.txt/route.ts`)

If the LLM index uses a `GROUP_SUMMARIES` mapping, add an entry for the new pages under the `start` group (or it auto-picks up since they share the `start` group).

## Content authoring template

Use this template when writing new `DocPage` objects for this skill:

```typescript
export const myPage: DocPage = {
  slug: "get-started/my-page",
  title: "Page Title",
  description: "One-line description for SEO and LLM indexing.",
  group: "start",  // Use "start" for Getting Started nav group
  blocks: [
    { type: "p", text: "Intro paragraph with **bold** and [links](/docs/slug)." },
    { type: "h2", text: "Section name" },
    {
      type: "tabs",
      tabs: [
        {
          label: "Python",
          lang: "python",
          filename: "example.py",
          code: `from sendafrica import SendAfrica\nclient = SendAfrica(api_key="SA-xxxxx")\nresult = client.sms.send(to="0712345678", message="Hello")`,
        },
      ],
    },
    {
      type: "callout",
      variant: "info",  // info | tip | warning | danger
      title: "Tip title",
      text: "Helpful note text.",
    },
  ],
};
```

## Verification steps

1. Run `npm run dev` and verify the new pages render at their slugs:
   - `http://localhost:3000/get-started`
   - `http://localhost:3000/get-started/sdks`
   - `http://localhost:3000/get-started/cli`
   - `http://localhost:3000/get-started/agent-mcp`
2. Check that pages appear in the sidebar under "Getting Started"
3. Append `.md` to a URL (e.g. `/get-started.md`) and verify the raw Markdown export works
4. Check `/llms.txt` and `/llms-full.txt` include the new pages
5. Run `npm run lint && npm run build`
6. Validate OpenAPI JSON: `python3 -m json.tool public/openapi.json >/dev/null`

## Cross-references to include

When writing the content modules, reference these existing pages for deeper context:

| Link text | Target slug |
|---|---|
| Authentication overview | `/authentication` |
| Rate limits & idempotency | `/rate-limits` |
| Phone numbers & SMS parts | `/phone-numbers` |
| SMS API reference | `/api/sms` |
| SDKs overview | `/sdks` |
| Python SDK | `/sdks/python` |
| TypeScript SDK | `/sdks/typescript` |
| Go SDK | `/sdks/go` |
| Agent overview | `/agent` |
| MCP tools reference | `/agent/tools` |
| Sandbox overview | `/sandbox` |
| Sandbox quickstart | `/sandbox/quickstart` |
| AI integration (for coding agents) | `/ai-integration` |
| Error codes & response format | `/errors` |
| API updates & migration | `/api-updates` |
