#!/usr/bin/env bash
# SendAfrica CLI Fix — Apply the missing entry point
#
# The SendAfrica CLI repository (github.com/camelt/sendafrica-cli) is missing
# its Go main package at cmd/sendafrica/main.go. This script creates the
# missing entry point file so the CLI can be built and installed.
#
# Usage:
#   ./scripts/cli-fix.sh <path-to-cli-repo>
#
# Example:
#   ./scripts/cli-fix.sh /path/to/sendafrica-cli

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ENTRIES_DIR="$(dirname "$SCRIPT_DIR")/docs/cli-entry-point-fix"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <path-to-cli-repo>"
  echo ""
  echo "Example: $0 /path/to/sendafrica-cli"
  exit 1
fi

CLI_REPO="$1"

if [ ! -d "$CLI_REPO" ]; then
  echo "ERROR: CLI repo not found at: $CLI_REPO"
  exit 1
fi

if [ ! -d "$CLI_REPO/internal/cmd" ]; then
  echo "ERROR: This does not look like the SendAfrica CLI repo (no internal/cmd/ dir)"
  echo "Expected directory structure:"
  echo "  cmd/sendafrica/main.go     (missing)"
  echo "  internal/"
  echo "    cmd/                      (root.go, auth.go, sms.go, etc.)"
  echo "    api/                      (types.go)"
  echo "    client/                   (client.go)"
  echo "    config/                   (config.go)"
  echo "    output/                   (formatter.go)"
  exit 1
fi

ENTRY_DIR="$CLI_REPO/cmd/sendafrica"
ENTRY_FILE="$ENTRY_DIR/main.go"

if [ -f "$ENTRY_FILE" ]; then
  echo "Entry point already exists at: $ENTRY_FILE"
  exit 0
fi

mkdir -p "$ENTRY_DIR"
cp "$CLI_ENTRIES_DIR/main.go" "$ENTRY_FILE"

echo "  ✅ Created entry point: $ENTRY_FILE"
echo ""
echo "  Next steps:"
echo "    cd $CLI_REPO"
echo "    go build ./cmd/sendafrica"
echo "    go install github.com/camelt/sendafrica-cli/cmd/sendafrica@latest"
echo ""
echo "  Note: The CLI module path in go.mod is 'github.com/camelt/sendafrica-cli'."
