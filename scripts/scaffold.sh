#!/usr/bin/env bash
# SendAfrica Scaffold — Generate a Starter Project
#
# Copies a template into a new project directory with README, .env.example,
# and .gitignore pre-configured.
#
# Usage:
#   ./scripts/scaffold.sh <language> <project-name>
#
# Examples:
#   ./scripts/scaffold.sh python my-sms-app
#   ./scripts/scaffold.sh typescript my-sms-app
#   ./scripts/scaffold.sh go my-sms-app
#   ./scripts/scaffold.sh curl my-sms-app

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$PROJECT_ROOT/templates"

usage() {
  echo "Usage: $0 <language> <project-name>"
  echo ""
  echo "Languages: python | typescript | go | curl"
  echo ""
  echo "Examples:"
  echo "  $0 python my-sms-app"
  echo "  $0 typescript my-sms-app"
  echo "  $0 go my-sms-app"
  echo "  $0 curl my-sms-app"
  exit 1
}

if [ $# -lt 2 ]; then
  usage
fi

LANGUAGE="$1"
PROJECT_NAME="$2"
TEMPLATE_DIR="$TEMPLATES_DIR/$LANGUAGE"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "ERROR: Unknown language '$LANGUAGE'"
  echo "Available: python, typescript, go, curl"
  exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
  echo "ERROR: Directory '$PROJECT_NAME' already exists"
  exit 1
fi

echo "Scaffolding SendAfrica $LANGUAGE project: $PROJECT_NAME"
cp -r "$TEMPLATE_DIR" "$PROJECT_NAME"

# Rename module/package if applicable
case "$LANGUAGE" in
  python)
    echo "  ✅ Created Python project: $PROJECT_NAME"
    echo "  Next steps:"
    echo "    cd $PROJECT_NAME"
    echo "    pip install sendafrica"
    echo "    cp .env.example .env"
    echo "    python main.py"
    ;;
  typescript)
    echo "  ✅ Created TypeScript project: $PROJECT_NAME"
    echo "  Next steps:"
    echo "    cd $PROJECT_NAME"
    echo "    npm install"
    echo "    cp .env.example .env.local"
    echo "    npm run dev"
    ;;
  go)
    echo "  ✅ Created Go project: $PROJECT_NAME"
    echo "  Next steps:"
    echo "    cd $PROJECT_NAME"
    echo "    go mod tidy"
    echo "    export SENDAFRICA_API_KEY=SA-your-key-here"
    echo "    go run main.go"
    ;;
  curl)
    echo "  ✅ Created curl project: $PROJECT_NAME"
    echo "  Next steps:"
    echo "    cd $PROJECT_NAME"
    echo "    export SENDAFRICA_API_KEY=SA-your-key-here"
    echo "    ./send.sh"
    ;;
esac
