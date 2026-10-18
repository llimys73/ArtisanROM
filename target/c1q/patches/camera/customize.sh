# Add Polarr libs
ADD_TO_WORK_DIR "a73xqxx" "system" "system/etc/public.libraries-polarr.txt" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "system" "system/lib64/libBestComposition.polarr.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "system" "system/lib64/libFeature.polarr.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "system" "system/lib64/libPolarrSnap.polarr.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "system" "system/lib64/libTracking.polarr.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "system" "system/lib64/libYuv.polarr.so" 0 0 644 "u:object_r:system_lib_file:s0"

# Add camera libs
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib64/libSceneDetector_v1.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
EVAL "echo \"libSceneDetector_v1.camera.samsung.so\" >> \"$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt\""
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libSwIsp_core.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libhigh_dynamic_range.arcsoft.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libhigh_res.arcsoft.so" 0 0 644 "u:object_r:system_lib_file:s0"
EVAL "echo \"libhigh_res.arcsoft.so\" >> \"$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt\""
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libhumantracking.arcsoft.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libhumantracking_util.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/liblow_light_hdr.arcsoft.so" 0 0 644 "u:object_r:system_lib_file:s0"
HEX_PATCH "$WORK_DIR/system/system/lib64/libsecimaging_pdk.camera.samsung.so" \
    "000000006400000046000000000000000b00000001000000070000000000000000000000" \
    "000000006400000046000000000000000b00000001000000050000000000000000000000"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsuperresolution.arcsoft.so" 0 0 644 "u:object_r:system_lib_file:s0"
EVAL "echo \"libsuperresolution.arcsoft.so\" >> \"$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt\""
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsuperresolution_wrapper_v2.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
EVAL "echo \"libsuperresolution_wrapper_v2.camera.samsung.so\" >> \"$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt\""
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libveengine.arcsoft.so" 0 0 644 "u:object_r:system_lib_file:s0"

LOG "- Patching /vendor/ueventd.rc"
EVAL "cat \"$MODPATH/ueventd.rc.diff\" >> \"$WORK_DIR/vendor/ueventd.rc\""

# c1q: vendor blobs come from the c1q firmware, not r8q. Only apply a vendor
# hex patch when the r8q byte pattern is actually present, otherwise skip it.
TRY_VENDOR_HEX_PATCH()
{
    if [ -f "$1" ] && xxd -p -c 0 "$1" | grep -q "$(tr "[:upper:]" "[:lower:]" <<< "${2// /}")"; then
        HEX_PATCH "$1" "$2" "$3"
    else
        LOG "- Pattern \"$2\" not found in ${1//$WORK_DIR/}, skipping (c1q vendor differs from r8q)"
    fi
}

# Force disable ScenarioManager::IsSupported3rdPartyYuvCapture()
# Before: [bne #0xdabb8]
# After: [b #0xdabb8]
TRY_VENDOR_HEX_PATCH "$WORK_DIR/vendor/lib/unihal_main@2.1.so" "01280dd1" "01280de0"

# Before: [b.ne 0x5099f4]
# After: [b 0x5099f4]
TRY_VENDOR_HEX_PATCH "$WORK_DIR/vendor/lib64/unihal_main@2.1.so" "a101005468e640b9" "0d00001468e640b9"

# Force disable Snaplite in Shot suggestions
# Before: [blt #0x1f890]
# After: [b #0x1f890]
TRY_VENDOR_HEX_PATCH "$WORK_DIR/vendor/lib/libshotsuggestion_engines.so" "0ddb" "0de0"

# Before: [b.lt 0x40dedc]
# After: [b 0x40dedc]
TRY_VENDOR_HEX_PATCH "$WORK_DIR/vendor/lib64/libshotsuggestion_engines.so" "eb010054" "0f000014"

unset -f TRY_VENDOR_HEX_PATCH
