# CLI Entry Point Fix

## Problem

The SendAfrica CLI repository (`github.com/camelt/sendafrica-cli`) is missing its Go main package at `cmd/sendafrica/main.go`. This means:

- `go build ./cmd/sendafrica` fails with `no Go files in .../cmd/sendafrica`
- `go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest` fails
- The CLI cannot be compiled or distributed

## Root cause

The README and `AGENTS.md` both reference `cmd/sendafrica/main.go` as the entry point:

- README: `cmd/sendafrica/main.go` — CLI entry point, calls `cmd.Execute()`
- README install: `go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest`
- AGENTS.md: `cmd/sendafrica/main.go` — CLI entry point

But the file does not exist in the repository.

## Fix

The missing entry point file is provided at:

```
skill/docs/cli-entry-point-fix/main.go
```

It should be placed at:

```
cmd/sendafrica/main.go
```

### The file contents

```go
package main

import (
	"fmt"
	"os"

	"github.com/camelt/sendafrica-cli/internal/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

### Module path

The `go.mod` in the CLI repo declares:

```
module github.com/camelt/sendafrica-cli
```

**Note:** The README references `github.com/sendafrica/sendafrica-cli` (with the `sendafrica` org), but the actual `go.mod` uses `github.com/camelt/sendafrica-cli`. The install command should be:

```bash
go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest
```

### Apply the fix automatically

Run the scaffold script from the skill project:

```bash
./scripts/cli-fix.sh /path/to/sendafrica-cli
```

This creates `cmd/sendafrica/main.go` if it doesn't exist.

### Apply the fix manually

```bash
cd /path/to/sendafrica-cli
mkdir -p cmd/sendafrica
cp /path/to/skill/docs/cli-entry-point-fix/main.go cmd/sendafrica/main.go
go build ./cmd/sendafrica
go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest
```

## Verification

```bash
# Build the binary
go build -o sendafrica ./cmd/sendafrica

# Run with --help
./sendafrica --help

# Or install globally
go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest
sendafrica --help
```

## Important CLI details to know

### Auth model

The CLI supports two auth modes:
- **API Key**: Set via `SENDAFRICA_API_KEY` env var or `--api-key` flag
- **JWT**: Set via `SENDAFRICA_JWT_TOKEN` env var or `--token` flag

**API key takes priority** over JWT when both are set.

**JWT-only endpoints** (these will error if only an API key is configured):
- `logout`
- `api-keys create/get/list/delete`
- `change-password`
- `verify-phone` / `send-phone-otp`
- `me --update`

### No `.env` loading

The CLI deliberately does **not** load `.env` files. Credentials come from:
1. CLI flags (highest priority)
2. Environment variables (`SENDAFRICA_API_KEY`, `SENDAFRICA_JWT_TOKEN`, `SENDAFRICA_API_URL`)
3. Config file at `~/.config/sendafrica-cli/config.json` (0600 perms, 0700 dir)

### Output formats

All commands support `--output table|json|yaml` (or `-o`).

### Profile management

```bash
sendafrica config add-profile production --api-key SA-xxxxx
sendafrica config add-profile dev --token eyJ...
sendafrica config use production
sendafrica config list
sendafrica config show  # shows resolved config with secrets masked
```

### Key commands

| Command | Endpoint | Auth |
|---|---|---|
| `sendafrica sms-send --to 0712345678 --message "Hi"` | `POST /v1/sms/` | API Key |
| `sendafrica sms-bulk --to 0711111111,0722222222 --message "Hi"` | `POST /v1/sms/bulk` | API Key/JWT |
| `sendafrica sms-logs --status delivered` | `GET /v1/sms/logs` | API Key/JWT |
| `sendafrica credits-balance` | `GET /v1/credits/balance` | API Key/JWT |
| `sendafrica contacts list` | `GET /v1/contact-lists` | API Key/JWT |
| `sendafrica campaigns create --name Sale --message "Hi" --from MyBrand` | `POST /v1/campaigns` | API Key/JWT |
| `sendafrica sender-ids list` | `GET /v1/sender-ids` | API Key/JWT |
| `sendafrica sender-ids requirements` | `GET /v1/sender-ids/requirements` | API Key/JWT |
| `sendafrica notifications list` | `GET /v1/notifications` | API Key/JWT |
| `sendafrica support-chat --message "How many credits?"` | `POST /v1/support/chat` | API Key/JWT |
| `sendafrica rates` | `GET /v1/rates` | None (public) |
| `sendafrica packages` | `GET /v1/packages` | None (public) |
