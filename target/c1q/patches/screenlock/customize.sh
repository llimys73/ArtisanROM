# Port note: some files/binary patches come from the S20 FE (r8q) port and may
# not exist or match on this device's firmware. Skip those instead of failing.
OPT_IF() { if "$@"; then return 0; fi; LOGW "- Skipped (not applicable to this firmware): ${4:-$2}"; return 1; }
OPT() { OPT_IF "$@" || true; }

OPT SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/locksettings/LockSettingsService.smali" "return" \
    'isEnablePrevCredential()Z' \
    'false'

unset -f OPT OPT_IF
