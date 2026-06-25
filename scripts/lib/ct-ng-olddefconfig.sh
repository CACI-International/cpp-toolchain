#!/bin/bash
# Update all defconfigs using crosstool-ng olddefconfig

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

BUILD_DIR=${BUILD_DIR:-"build"}
GCC_DIR="toolchain/gcc"

TARGETS=($(ls -1 "$GCC_DIR/targets/" 2>/dev/null))
[ ${#TARGETS[@]} -eq 0 ] && { echo "Error: No targets found" >&2; exit 1; }

ensure_cmake_configured "$GCC_DIR" >/dev/null
cmake_build_target crosstool-ng >/dev/null

CT_NG="$(pwd)/$BUILD_DIR/crosstool-ng-prefix/bin/ct-ng"

for TARGET in "${TARGETS[@]}"; do
    TARGET_DIR="$GCC_DIR/targets/$TARGET"
    [ ! -f "$TARGET_DIR/defconfig" ] && continue
    
    WORK_DIR="$BUILD_DIR/$TARGET-defconfig-update"
    mkdir -p "$WORK_DIR"
    
    cp "$TARGET_DIR/defconfig" "$WORK_DIR/defconfig"
    
    (
        cd "$WORK_DIR"
        "$CT_NG" defconfig >/dev/null 2>&1
        "$CT_NG" olddefconfig >/dev/null 2>&1
        "$CT_NG" savedefconfig >/dev/null 2>&1
    ) || continue
    
    cp "$WORK_DIR/defconfig" "$TARGET_DIR/defconfig"
    echo "✓ $TARGET"
done