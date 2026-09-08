#!/usr/bin/env bash
# Quick start: send an SMS with curl
# Requires: curl, and SENDAFRICA_API_KEY in your environment

set -euo pipefail

API_KEY="${SENDAFRICA_API_KEY:-}"
if [ -z "$API_KEY" ]; then
  echo "ERROR: Set SENDAFRICA_API_KEY in your environment first."
  exit 1
fi

# 1. Check your balance
echo "=== Balance ==="
curl -sS "https://api.sendafrica.online/v1/credits/balance" \
  -H "X-API-Key: $API_KEY"

echo ""
echo ""

# 2. Send your first SMS
echo "=== Send SMS ==="
curl -sS -X POST "https://api.sendafrica.online/v1/sms/" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: order-1234" \
  -d '{
    "to": "0712345678",
    "message": "Hello from SendAfrica! Your order is ready.",
    "from": "MyBrand"
  }'

echo ""
echo ""

# 3. Check message logs for delivery status
echo "=== Message Logs ==="
curl -sS "https://api.sendafrica.online/v1/sms/logs?per_page=5" \
  -H "X-API-Key: $API_KEY"
