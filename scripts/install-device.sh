#!/usr/bin/env bash
# Install or update TimeIt on a connected device (Android via adb; iOS via ideviceinstaller when present).
# Usage:
#   ./scripts/install-device.sh
#   ./scripts/install-device.sh --apk path/to/app-release.apk
#   ./scripts/install-device.sh --ipa path/to/TimeIt.ipa
# If TimeIt is already installed, the package is updated in place. Otherwise it installs fresh.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_PACKAGE="com.nuclearfessel.timeit"
IOS_BUNDLE_ID="com.nuclearfessel.timeit"
APK=""
IPA=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apk) APK="$2"; shift 2 ;;
    --ipa) IPA="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

resolve_apk() {
  if [[ -n "$APK" ]]; then
    [[ -f "$APK" ]] || { echo "APK not found: $APK" >&2; exit 1; }
    echo "$APK"
    return
  fi
  for c in \
    "$ROOT/app/build/app/outputs/flutter-apk/app-release.apk" \
    "$ROOT/app/build/app/outputs/flutter-apk/app-debug.apk"
  do
    if [[ -f "$c" ]]; then echo "$c"; return; fi
  done
  echo "No APK found. Build one (flutter build apk) or pass --apk." >&2
  exit 1
}

install_android() {
  local apk_path="$1"
  command -v adb >/dev/null || { echo "adb not found." >&2; exit 1; }
  if ! adb devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'; then
    echo "No Android device/emulator online." >&2
    exit 1
  fi
  if adb shell pm path "$ANDROID_PACKAGE" >/dev/null 2>&1; then
    echo "Android: TimeIt is already installed — updating."
  else
    echo "Android: TimeIt is not installed — installing."
  fi
  echo "Using $apk_path"
  adb install -r "$apk_path"
  echo "Android install/update complete for $ANDROID_PACKAGE."
}

install_ios() {
  local ipa_path="$1"
  [[ -f "$ipa_path" ]] || { echo "IPA not found: $ipa_path" >&2; exit 1; }
  if ! command -v ideviceinstaller >/dev/null; then
    echo "ideviceinstaller not found. Install libimobiledevice, or use Xcode. Same bundle id updates in place." >&2
    exit 1
  fi
  if ideviceinstaller list 2>/dev/null | grep -q "$IOS_BUNDLE_ID"; then
    echo "iOS: TimeIt is already installed — updating."
  else
    echo "iOS: TimeIt is not installed — installing."
  fi
  echo "Using $ipa_path"
  ideviceinstaller -i "$ipa_path"
  echo "iOS install/update complete for $IOS_BUNDLE_ID."
}

DID=0
if command -v adb >/dev/null && adb devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'; then
  install_android "$(resolve_apk)"
  DID=1
fi

if [[ -n "$IPA" ]]; then
  install_ios "$IPA"
  DID=1
fi

if [[ "$DID" -eq 0 ]]; then
  cat <<EOF
No device install ran.
- Android: connect a device/emulator, build an APK, then re-run (or pass --apk).
- iOS: on a Mac, pass --ipa path/to/TimeIt.ipa (same bundle id updates an existing install).
EOF
  exit 1
fi
