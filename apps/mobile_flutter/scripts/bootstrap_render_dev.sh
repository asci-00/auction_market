#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_FILE="${APP_DIR}/dart_defines.dev.json"

cat >"${TARGET_FILE}" <<'EOF'
{
  "APP_ENV": "dev",
  "APP_BACKEND_TRANSPORT": "http",
  "APP_API_BASE_URL": "https://auction-market-dev-api.onrender.com",
  "USE_FIREBASE_EMULATORS": "false",
  "FIREBASE_EMULATOR_HOST": "",
  "TOSS_CLIENT_KEY": ""
}
EOF

echo "Wrote ${TARGET_FILE}"
echo "Fill TOSS_CLIENT_KEY when you need real Toss sandbox checkout."
