#!/bin/bash
# Build the UN1CA SM8250 kernel for the Galaxy Note 20 series (Snapdragon).
#
# Put this file in the root of your fork of
#   https://github.com/UN1CA/kernel_samsung_sm8250
# and run it there (the GitHub workflow next to it does this for you).
#
#   DEVICE=c2q  -> Galaxy Note 20 Ultra (Snapdragon)          [default]
#   DEVICE=c1q  -> Galaxy Note 20 (Snapdragon)
#   REGION=kor  -> SM-N986N / SM-N981N (Korea, single SIM)    [default]
#   REGION=chn  -> SM-N9860 / SM-N9810 (Hong Kong / China, dual SIM)
#
# Output: boot.img and dtbo.img in the repo root.

set -euo pipefail

DEVICE="${DEVICE:-${C2Q_DEVICE:-c2q}}"
REGION="${REGION:-${C2Q_REGION:-kor}}"
CLANG_DIR="${CLANG_DIR:-$(pwd)/clang-r547379}"
# Board name of the stock boot.img. The bootloader does not check it, but
# keep it close to stock. Read yours with: unpack_bootimg --boot_img boot.img
BOARD="${BOARD:-SRPTB19B001}"

case "$DEVICE" in
    c1q|c2q) ;;
    *) echo "Unknown DEVICE: $DEVICE (use c1q or c2q)" >&2; exit 1 ;;
esac
DEV_UPPER="${DEVICE^^}"

case "$REGION" in
    kor) MACH="MACH_${DEV_UPPER}_KOR_SINGLE" ;;
    chn) MACH="MACH_${DEV_UPPER}_CHN_OPEN" ;;
    *) echo "Unknown REGION: $REGION (use kor or chn)" >&2; exit 1 ;;
esac

if [ -d "$CLANG_DIR/bin" ]; then
    export PATH="$CLANG_DIR/bin:$PATH"
fi

export ARCH=arm64
rm -rf out && mkdir out

# Note 20 series drivers that UN1CA never built for r8q need two fixes:
# 1) VL53L5 ToF sensor: include paths use $(src), which breaks O=out builds
sed -i 's|-I\$(src)/|-I$(srctree)/$(src)/|g' drivers/sensors/vl53l5/Makefile
# 2) Samsung touch (y79a_c), Broadcom DHD Wi-Fi and VL53L5 build with -Werror and trip
#    newer clang diagnostics; keep them as warnings instead of errors.
export KCFLAGS="${KCFLAGS:-} -Wno-error=vla-extension -Wno-error=vla -Wno-error=strict-prototypes -Wno-error=deprecated-non-prototype -Wno-error=unused-but-set-variable"

BUILD_VAR=(-j"$(nproc)" -C "$(pwd)" O="$(pwd)/out" ARCH=arm64 LLVM=1 LLVM_IAS=1)

echo "-----------------------------------------------"
echo "Configuring kernel for $DEVICE ($REGION)"
echo "-----------------------------------------------"
make "${BUILD_VAR[@]}" vendor/kona-perf_defconfig vendor/samsung/kona-sec-common.config vendor/samsung/$DEVICE.config

# <device>.config selects the Korean board; switch region if requested
for m in KOR_SINGLE CHN_OPEN CHN_HK USA_SINGLE JPN_SINGLE CAN_SINGLE; do
    m="MACH_${DEV_UPPER}_$m"
    ./scripts/config --file out/.config -d "$m"
done
./scripts/config --file out/.config -e "$MACH"
make "${BUILD_VAR[@]}" olddefconfig

# Sanity checks: make sure we really build the right device, never r8q
grep -q "^CONFIG_SEC_${DEV_UPPER}_PROJECT=y" out/.config || { echo "CONFIG_SEC_${DEV_UPPER}_PROJECT missing" >&2; exit 1; }
grep -q "^CONFIG_${MACH}=y" out/.config || { echo "CONFIG_${MACH} missing" >&2; exit 1; }
if grep -q "^CONFIG_SEC_R8Q_PROJECT=y" out/.config; then echo "r8q project leaked into config" >&2; exit 1; fi

echo "-----------------------------------------------"
echo "Building kernel"
echo "-----------------------------------------------"
make "${BUILD_VAR[@]}"

# DTB: base kona dtbs, DTBO: device overlays for the selected region
cat out/arch/arm64/boot/dts/vendor/qcom/*.dtb > out/arch/arm64/boot/dts/vendor/qcom/dtb
ls out/arch/arm64/boot/dts/samsung/$DEVICE/*.dtbo >/dev/null 2>&1 || { echo "No $DEVICE dtbo built" >&2; exit 1; }
mv out/arch/arm64/boot/dtbo.img dtbo.img

echo "-----------------------------------------------"
echo "Building boot.img"
echo "-----------------------------------------------"
CMDLINE="console=null androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 printk.devkmsg=on firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7"

python3 mkbootimg/mkbootimg.py \
    --header_version 2 \
    --kernel out/arch/arm64/boot/Image \
    --ramdisk boot/ramdisk \
    --dtb out/arch/arm64/boot/dts/vendor/qcom/dtb \
    --cmdline "$CMDLINE" \
    --base 0x00000000 \
    --kernel_offset 0x00008000 \
    --ramdisk_offset 0x02000000 \
    --second_offset 0x00000000 \
    --dtb_offset 0x01f00000 \
    --tags_offset 0x01e00000 \
    --board "$BOARD" \
    --pagesize 4096 \
    --os_version 16.0.0 \
    --os_patch_level "$(date +%Y-%m)" \
    --output boot.img

# Must fit the conservative boot size used by target/<device>/config.sh (64 MiB)
BOOT_SIZE=$(stat -c%s boot.img)
if [ "$BOOT_SIZE" -gt 67108864 ]; then
    echo "boot.img is $BOOT_SIZE bytes, larger than 64 MiB" >&2
    exit 1
fi

echo "Done ($DEVICE/$REGION): boot.img ($BOOT_SIZE bytes), dtbo.img ($(stat -c%s dtbo.img) bytes)"
