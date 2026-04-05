#!/usr/bin/env bash

set -euo pipefail

ports=(9099 8080 5001 9199)

find_adb() {
  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi

  local sdk_root=""
  if [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
    sdk_root="${ANDROID_SDK_ROOT}"
  elif [[ -n "${ANDROID_HOME:-}" ]]; then
    sdk_root="${ANDROID_HOME}"
  elif [[ -d "${HOME}/Library/Android/sdk" ]]; then
    sdk_root="${HOME}/Library/Android/sdk"
  fi

  if [[ -n "${sdk_root}" && -x "${sdk_root}/platform-tools/adb" ]]; then
    printf '%s\n' "${sdk_root}/platform-tools/adb"
    return 0
  fi

  return 1
}

adb_bin="$(find_adb || true)"
if [[ -z "${adb_bin}" ]]; then
  echo "adb not found. Install Android platform-tools or set ANDROID_SDK_ROOT." >&2
  exit 1
fi

connected_devices=()
while IFS= read -r device; do
  if [[ -n "${device}" ]]; then
    connected_devices+=("${device}")
  fi
done < <("${adb_bin}" devices | awk 'NR > 1 && $2 == "device" { print $1 }')

if [[ -n "${ANDROID_SERIAL:-}" ]]; then
  target_serial="${ANDROID_SERIAL}"
elif (( ${#connected_devices[@]} > 1 )); then
  echo "Multiple Android devices detected. Set ANDROID_SERIAL to choose a target:" >&2
  printf '  %s\n' "${connected_devices[@]}" >&2
  exit 1
elif (( ${#connected_devices[@]} == 1 )); then
  target_serial="${connected_devices[0]}"
else
  target_serial=""
fi

run_adb() {
  if [[ -n "${target_serial}" ]]; then
    "${adb_bin}" -s "${target_serial}" "$@"
  else
    "${adb_bin}" "$@"
  fi
}

if ! run_adb get-state >/dev/null 2>&1; then
  echo "No Android device detected over adb. Connect a device and authorize USB debugging." >&2
  exit 1
fi

echo "Using adb: ${adb_bin}"
if [[ -n "${target_serial}" ]]; then
  echo "Target device: ${target_serial}"
fi
echo "Configuring reverse tunnels for Firebase emulators..."

for port in "${ports[@]}"; do
  run_adb reverse "tcp:${port}" "tcp:${port}"
  echo "  tcp:${port} -> tcp:${port}"
done

echo
echo "Android device can now reach Mac localhost emulators through adb reverse."
echo "Set FIREBASE_EMULATOR_HOST=127.0.0.1 for Android physical-device runs."
