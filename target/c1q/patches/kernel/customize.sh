# c1q kernel: UN1CA kernel_samsung_sm8250 built with the c1q config.
# UN1CA only publishes r8q builds, so the c1q boot.img/dtbo.img must come from
# your own fork's GitHub release (see target/c1q/kernel-build/).
#   export C1Q_KERNEL_REPO="https://github.com/<you>/kernel_samsung_sm8250/releases/download/c1q-kor"
# NEVER point this at the r8q release: an r8q kernel will not boot on c1q.
# Simplest option: put a prebuilt boot.img + dtbo.img for c1q in
#   target/c1q/kernel-prebuilt/
# and they are used directly, no download needed.
PREBUILT_DIR="$SRC_DIR/target/c1q/kernel-prebuilt"
if [ -f "$PREBUILT_DIR/boot.img" ] && [ -f "$PREBUILT_DIR/dtbo.img" ]; then
    LOG "- Using prebuilt kernel from target/c1q/kernel-prebuilt"
    EVAL "mkdir -p \"$WORK_DIR/kernel\""
    EVAL "cp -f \"$PREBUILT_DIR/boot.img\" \"$PREBUILT_DIR/dtbo.img\" \"$WORK_DIR/kernel/\""
    unset PREBUILT_DIR
    return 0
fi
unset PREBUILT_DIR

KERNEL_REPO="${C1Q_KERNEL_REPO:-}"

if [ ! "$KERNEL_REPO" ]; then
    LOGE "No kernel: add boot.img/dtbo.img to target/c1q/kernel-prebuilt or set C1Q_KERNEL_REPO (see PORTING-c1q.md)."
    return 1
fi

LOG "- Downloading kernel"
if [ -f "$WORK_DIR/kernel/boot.img" ]; then
    EVAL "rm -f \"$WORK_DIR/kernel/boot.img\""
fi
if [ -f "$WORK_DIR/kernel/dtbo.img" ]; then
    EVAL "rm -f \"$WORK_DIR/kernel/dtbo.img\""
fi
DOWNLOAD_FILE "$KERNEL_REPO/boot.img" "$WORK_DIR/kernel/boot.img"
DOWNLOAD_FILE "$KERNEL_REPO/dtbo.img" "$WORK_DIR/kernel/dtbo.img"

unset KERNEL_REPO
