# Landing Page Integration Instructions

This document describes how to integrate the SendAfrica Get Started skill into the **landing page** repository (`sendafrica-landing-update`).

## Goal

Add a new `/developers/get-started` route that serves as the primary onboarding destination for new developers. It should be linked from the existing `/developers` page as a prominent CTA.

## Files to create/modify

### 1. New page: `src/app/developers/get-started/page.tsx`

Create a new Next.js App Router page that mirrors the landing page's styling patterns (using `PageHero`, `FeatureGrid`, `CtaSection`, etc. from `src/components/site/sections.tsx`).

Key sections the page should include:

1. **`PageHero`** — "Get started with SendAfrica SMS in 5 minutes" + CTA buttons ("Read the API docs", "Send a test SMS")
2. **API key setup** — Explain where to create an API key (dashboard → Settings → API Keys), with the "shown only once" warning
3. **Tabbed code samples** — Four tabs showing how to send your first SMS:
   - cURL (REST API)
   - Python SDK (`pip install sendafrica`)
   - TypeScript SDK (`npm install sendafrica`)
   - Go SDK (`go get github.com/SendAfrica/GO-SDK`)
4. **CLI quick start** — `go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest` + `sendafrica sms-send` example
5. **Agent MCP quick start** — Link to MCP config snippet + the `sendafrica-agent mcp` command
6. **Key facts card** — API base URL, auth header format, response envelope, SMS billing, rate limits
7. **`FaqSection`** + **`CtaSection`** — Reuse existing components

**Reference data to use from `src/components/site/data.ts`:**
- `features` array (8 feature cards)
- `plans` array (Free plan card)

### 2. Link from existing `/developers` page

In `src/app/developers/page.tsx`, add a prominent CTA after the "Endpoint groups" table:

```tsx
<div className="mt-8 flex gap-4">
  <Link href="/developers/get-started" className="btn btn-primary">
    Get started guide
  </Link>
</div>
```

### 3. Add to Navbar (optional)

If you want the Get Started page discoverable from the main navigation, add a link in `src/components/site/Navbar.tsx`:

```tsx
{ label: "Get Started", href: "/developers/get-started" }
```

## Content blocks (copy-paste ready)

The following content blocks can be dropped into the new page component. They use the existing `PageHero`, `SectionHeading`, and `CtaSection` components from the landing page codebase.

### Hero section

```tsx
<PageHero
  title="Send your first SMS in 5 minutes"
  highlight="Get started with"
  sub="Create a free SendAfrica account, get an API key, and send your first SMS message."
>
  <div className="flex gap-4">
    <Link href="/developers" className="btn btn-primary">
      Read the API docs
    </Link>
    <Link href="https://app.sendafrica.online" className="btn btn-ghost">
      Get an API key
    </Link>
  </div>
</PageHero>
```

### API key setup (facts callout)

```tsx
<callout variant="warning" title="API key shown once">
  Your full API key (<code>SA-...</code>) is displayed <strong>only once</strong> at creation.
  Store it in your environment variables or secrets manager immediately. If you
  lose it, revoke it and create a new one.
</callout>
```

### Send your first SMS — tabbed code samples

Use the existing `CodeTabs` pattern (or create one matching the landing page's style) with four tabs:

**cURL:**
```bash
curl -X POST https://api.sendafrica.online/v1/sms/ \
  -H "X-API-Key: $SENDAFRICA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"to": "0712345678", "message": "Hello from SendAfrica!"}'
```

**Python:**
```python
from sendafrica import SendAfrica
client = SendAfrica(api_key="SA-xxxxx")
result = client.sms.send(to="0712345678", message="Hello from SendAfrica!")
print(result.message_id, result.status, result.credits_used)
```

**TypeScript:**
```typescript
import { SendAfricaClient } from "sendafrica";
const client = new SendAfricaClient({ apiKey: process.env.SENDFRICA_API_KEY! });
const result = await client.sendSms({ to: "0712345678", message: "Hello from SendAfrica!" });
console.log(result.messageId, result.status, result.creditsUsed);
```

**Go:**
```go
package main
import (
  "context"; "fmt"; "log"
  sendafrica "github.com/SendAfrica/GO-SDK"
)
func main() {
  client := sendafrica.NewClient("SA-xxxxx")
  result, err := client.SMS.Send(context.Background(), sendafrica.SendSMSRequest{
    To: "0712345678", Message: "Hello from SendAfrica!",
  })
  if err != nil { log.Fatal(err) }
  fmt.Println(result.MessageID, result.Status, result.CreditsUsed)
}
```

### Key facts table

| Concept | Value |
|---|---|
| API base URL | `https://api.sendafrica.online` (all routes under `/v1`) |
| Auth header | `X-API-Key: SA-...` |
| Response envelope | `{ success, data, error, request_id, timestamp }` |
| SMS billing | 1 credit / part. GSM-7: 160 / 153. UTF-16: 70 / 67 |
| Rate limits | Free 60, Pro 600, Enterprise 6 000 req/min |

### Rate limits table

| Plan | Requests / minute |
|---|---|
| Free | 60 |
| Pro | 600 |
| Enterprise | 6 000 |

### CTA at the bottom

```tsx
<CtaSection />
```

## Verification steps

1. Run `npm run dev` and visit `http://localhost:3000/developers/get-started`
2. Confirm the page renders with the same styling as `/developers`
3. Click the "Get started guide" link from `/developers` — it should navigate to the new page
4. Run `npm run lint` and `npm run typecheck` to ensure no errors

## Landing page routes that should be linked from this page

| Destination | URL |
|---|---|
| Full API documentation | `https://docs.sendafrica.online` |
| Dashboard (get API key) | `https://app.sendafrica.online` |
| Contact sales | `/contact` |
| View pricing | `/pricing` |
