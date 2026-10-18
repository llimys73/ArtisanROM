# Set default SIM count to 1 (SM-N981N is single SIM)
# Before: [mov w1, #0x2]
# After: [mov w1, #0x1]
if [ "$TARGET_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" != "1" ]; then
    LOG "- Dual SIM build, skipping"
elif xxd -p -c 0 "$WORK_DIR/vendor/bin/secril_config_svc" | grep -q "41008052"; then
    HEX_PATCH "$WORK_DIR/vendor/bin/secril_config_svc" "41008052" "21008052"
else
    LOG "- Pattern not found in /vendor/bin/secril_config_svc, skipping (c1q vendor differs from r8q)"
fi
