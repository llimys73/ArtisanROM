# Port note: some files/binary patches come from the S20 FE (r8q) port and may
# not exist or match on this device's firmware. Skip those instead of failing.
OPT_IF() { if "$@"; then return 0; fi; LOGW "- Skipped (not applicable to this firmware): ${4:-$2}"; return 1; }
OPT() { OPT_IF "$@" || true; }

# c1q only ships the NXP SN100U NFC chip (kernel: CONFIG_NFC_FEATURE_SN100U),
# so the Samsung SLSI config is dropped and the empty-prop fallbacks point to NXP.
LOG_STEP_IN "- Setting up libnfc-nci configuration"
if OPT_IF ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci-NXP_SN100U.conf" 0 0 644 "u:object_r:system_file:s0"; then
    LOG "- Renaming /system/system/etc/libnfc-nci-NXP_SN100U.conf to /system/system/etc/libnfc-nci-sn110t.conf"
    EVAL "mv \"$WORK_DIR/system/system/etc/libnfc-nci-NXP_SN100U.conf\" \"$WORK_DIR/system/system/etc/libnfc-nci-sn110t.conf\""
    SET_METADATA "system" "system/etc/libnfc-nci-sn110t.conf" 0 0 644 "u:object_r:system_file:s0"
fi
LOG_STEP_OUT

LOG "- Patching /vendor/etc/init/init.nfc.samsung.rc"
EVAL "echo \"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"on property:ro.boot.hardware.sku=\\\"\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"    setprop ro.boot.hardware.sku \\\"sn110t\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"on property:ro.boot.nfc.feature.chipname=\\\"\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"    setprop ro.boot.nfc.feature.chipname \\\"NXP\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"on property:ro.boot.product.hardware.sku=\\\"\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"    setprop ro.boot.product.hardware.sku \\\"sn110t\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"on property:ro.vendor.nfc.feature.chipname=\\\"\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""
EVAL "echo \"    setprop ro.vendor.nfc.feature.chipname \\\"NXP\\\"\" >> \"$WORK_DIR/vendor/etc/init/init.nfc.samsung.rc\""

unset -f OPT OPT_IF
