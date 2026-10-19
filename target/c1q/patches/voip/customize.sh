# Port note: some files/binary patches come from the S20 FE (r8q) port and may
# not exist or match on this device's firmware. Skip those instead of failing.
OPT_IF() { if "$@"; then return 0; fi; LOGW "- Skipped (not applicable to this firmware): ${4:-$2}"; return 1; }
OPT() { OPT_IF "$@" || true; }

OPT HEX_PATCH "$WORK_DIR/system/system/bin/audioserver" \
    "08f0a752880300b90d000014" \
    "08f0a7521f2003d50d000014"

unset -f OPT OPT_IF
