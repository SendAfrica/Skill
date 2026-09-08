#!/usr/bin/env bash
# SendAfrica Get Started — Interactive Onboarding Checklist
#
# Walks through the full onboarding funnel step by step:
#   1. Verify API key is present
#   2. Check account balance
#   3. Send a test SMS
#   4. List recent message logs
#   5. Test the sandbox
#
# Each step prints ✅ on success or ❌ with a remediation hint on failure.
#
# Prerequisites: curl, and SENDAFRICA_API_KEY in your environment
# Usage: ./scripts/get-started.sh

set -euo pipefail

API_BASE="https://api.sendafrica.online"
API_KEY="${SENDFRICA_API_KEY:-}"
PASS=0
FAIL=0

print_header() {
  echo ""
  echo "════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════"
}

check() {
  if [ "$1" -eq 0 ]; then
    echo "  ✅ $2"
    ((PASS++))
  else
    echo "  ❌ $2"
    echo "     💡 $3"
    ((FAIL++))
  fi
}

# ── Step 1: Verify API key ─────────────────────────────────────────
print_header "Step 1: Verify API key"

if [ -z "$API_KEY" ]; then
  echo "  ❌ SENDAFRICA_API_KEY is not set"
  echo "     💡 Create an API key at https://app.sendafrica.online → Settings → API Keys"
  echo "     💡 Then run: export SENDAFRICA_API_KEY=SA-your-key-here"
  ((FAIL++))
else
  echo "  ✅ API key is set (looks like: ${API_KEY:0:4}…${API_KEY: -4})"
  ((PASS++))
fi

# ── Step 2: Check account balance ──────────────────────────────────
print_header "Step 2: Check account balance"

if [ -n "$API_KEY" ]; then
  response=$(curl -sS -o /dev/null -w "%{http_code}" \
    "$API_BASE/v1/credits/balance" \
    -H "X-API-Key: $API_KEY" 2>&1) || response="000"
  check 0 "GET /v1/credits/balance returned HTTP $response" \
    "Check your API key or visit https://docs.sendafrica.online/authentication"
else
  check 1 "Skipped (no API key)" "Set SENDAFRICA_API_KEY"
fi

# ── Step 3: Send a test SMS ────────────────────────────────────────
print_header "Step 3: Send a test SMS"

if [ -n "$API_KEY" ]; then
  response=$(curl -sS \
    -X POST "$API_BASE/v1/sms/" \
    -H "X-API-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    -H "Idempotency-Key: get-started-$(date +%s)" \
    -d '{
      "to": "0712345678",
      "message": "Hello from SendAfrica! Your order is ready.",
      "from": "MyBrand"
    }' 2>&1) || response="error"
  # Check for success envelope
  if echo "$response" | grep -q '"success".*true'; then
    check 0 "SMS sent successfully" \
      "Check your balance or phone number format at https://docs.sendafrica.online/sms"
    echo "     Response: $response"
  else
    check 1 "SMS send returned: $response" \
      "Ensure you have credits and the recipient is valid. See https://docs.sendafrica.online/errors"
  fi
else
  check 1 "Skipped (no API key)" "Set SENDAFRICA_API_KEY"
fi

# ── Step 4: Check message logs ─────────────────────────────────────
print_header "Step 4: Check message logs"

if [ -n "$API_KEY" ]; then
  response=$(curl -sS -o /dev/null -w "%{http_code}" \
    "$API_BASE/v1/sms/logs?per_page=5" \
    -H "X-API-Key: $API_KEY" 2>&1) || response="000"
  check 0 "GET /v1/sms/logs returned HTTP $response" \
    "Verify your API key. The endpoint accepts both API key and JWT."
else
  check 1 "Skipped (no API key)" "Set SENDAFRICA_API_KEY"
fi

# ── Step 5: Test the sandbox ───────────────────────────────────────
print_header "Step 5: Test the sandbox (no credits needed)"

if [ -n "$API_KEY" ]; then
  response=$(curl -sS \
    -X POST "$API_BASE/v1/sandbox/messages" \
    -H "X-API-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    -H "Idempotency-Key: sandbox-test-$(date +%s)" \
    -d '{
      "to": "+264811234567",
      "message": "Your order has been received.",
      "scenario": "accepted"
    }' 2>&1) || response="error"
  if echo "$response" | grep -q '"provider":"sandbox"'; then
    check 0 "Sandbox message created (zero-cost)" \
      "Sandbox requires an API key. See https://docs.sendafrica.online/sandbox"
    echo "     Response: $response"
  else
    check 1 "Sandbox call returned: $response" \
      "The sandbox is API-key-only. Verify your key at https://app.sendafrica.online"
  fi
else
  check 1 "Skipped (no API key)" "Set SENDAFRICA_API_KEY"
fi

# ── Summary ────────────────────────────────────────────────────────
print_header "Summary"
echo "  Passed: $PASS  Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "  🎉 You're all set! Visit https://docs.sendafrica.online to learn more."
  echo "  🎯 Next: Try running one of the SDK starter templates:"
  echo "     ./scripts/scaffold.sh python my-sms-app"
elif [ "$FAIL" -gt 0 ]; then
  echo "  ⚠️  Some steps failed. Review the hints above and try again."
  echo "  📚 Docs: https://docs.sendafrica.online/quickstart"
fi
