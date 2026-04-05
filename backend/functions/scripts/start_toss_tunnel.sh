#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
functions_dir="$(cd "${script_dir}/.." && pwd)"
repo_root="$(cd "${functions_dir}/.." && pwd)"
repo_root="$(cd "${repo_root}/.." && pwd)"
env_file="${functions_dir}/.env"
firebaserc_file="${repo_root}/.firebaserc"

if ! command -v ssh >/dev/null 2>&1; then
  echo "ssh is required to open the localhost.run tunnel." >&2
  exit 1
fi

if [[ ! -f "${env_file}" ]]; then
  echo "Missing ${env_file}. Create it from backend/functions/.env.example first." >&2
  exit 1
fi

if [[ ! -f "${firebaserc_file}" ]]; then
  echo "Missing ${firebaserc_file}. Cannot resolve the Firebase project id." >&2
  exit 1
fi

project_id="$(
  sed -n 's/.*"default":[[:space:]]*"\([^"]*\)".*/\1/p' "${firebaserc_file}" \
    | head -n 1
)"

if [[ -z "${project_id}" ]]; then
  echo "Could not read the default Firebase project id from ${firebaserc_file}." >&2
  exit 1
fi

if ! grep -q '^APP_BASE_URL=' "${env_file}"; then
  echo "APP_BASE_URL entry is missing in ${env_file}." >&2
  exit 1
fi

echo "Opening Toss dev tunnel for project ${project_id}."
echo "This process must stay running while Toss sandbox checkout is under test."
echo

tunnel_announced=false

ssh \
  -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=30 \
  -R 80:127.0.0.1:5001 \
  nokey@localhost.run \
  -- --output json 2>&1 | while IFS= read -r line; do
    printf '%s\n' "${line}"

    if [[ "${tunnel_announced}" == false ]]; then
      tunnel_origin=""

      if [[ "${line}" =~ \"url\"[[:space:]]*:[[:space:]]*\"(https://[^\"]+)\" ]]; then
        tunnel_origin="${BASH_REMATCH[1]}"
      elif [[ "${line}" =~ \"url\"[[:space:]]*:[[:space:]]*\"(https:\\/\\/[^\"]+)\" ]]; then
        tunnel_origin="${BASH_REMATCH[1]//\\//\/}"
      elif [[ "${line}" =~ tunneled\ with\ tls\ termination,\ (https://[a-zA-Z0-9.-]+) ]]; then
        tunnel_origin="${BASH_REMATCH[1]}"
      fi

      if [[ -n "${tunnel_origin}" ]]; then
      bridge_url="${tunnel_origin}/${project_id}/us-central1/tossPaymentBridge"
      perl -0pi -e "s#^APP_BASE_URL=.*#APP_BASE_URL=${bridge_url}#m" "${env_file}"

      echo
      echo "Updated APP_BASE_URL in ${env_file}"
      echo "Bridge URL: ${bridge_url}"
      echo "If the Firebase emulator is already running, restart 'npm run serve' to reload the new APP_BASE_URL."
      echo

      tunnel_announced=true
      fi
    fi
  done
