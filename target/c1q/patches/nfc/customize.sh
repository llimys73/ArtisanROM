# c1q only ships the NXP SN100U NFC chip (kernel: CONFIG_NFC_FEATURE_SN100U),
# so the Samsung SLSI config is dropped and the empty-prop fallbacks point to NXP.
LOG_STEP_IN "- Setting up libnfc-nci configuration"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci-NXP_SN100U.conf" 0 0 644 "u:object_r:system_file:s0"
LOG "- Renaming /system/system/etc/libnfc-nci-NXP_SN100U.conf to /system/system/etc/libnfc-nci-sn110t.conf"
EVAL "mv \"$WORK_DIR/system/system/etc/libnfc-nci-NXP_SN100U.conf\" \"$WORK_DIR/system/system/etc/libnfc-nci-sn110t.conf\""
SET_METADATA "system" "system/etc/libnfc-nci-sn110t.conf" 0 0 644 "u:object_r:system_file:s0"

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
