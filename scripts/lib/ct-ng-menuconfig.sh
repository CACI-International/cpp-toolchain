#!/bin/bash
# Interactive configuration using crosstool-ng menuconfig

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

BUILD_DIR=${BUILD_DIR:-"build"}
GCC_DIR="toolchain/gcc"
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target>" >&2
    exit 1
fi

TARGET_DIR="$GCC_DIR/targets/$TARGET"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target '$TARGET' not found in $GCC_DIR/targets/" >&2
    exit 1
fi

ensure_cmake_configured "$GCC_DIR" >/dev/null
cmake_build_target crosstool-ng >/dev/null

CT_NG="$(pwd)/$BUILD_DIR/crosstool-ng-prefix/bin/ct-ng"

# Run menuconfig workflow
WORK_DIR="$BUILD_DIR/$TARGET-menuconfig"
mkdir -p "$WORK_DIR"

(
    cd "$WORK_DIR"
    cp "$TARGET_DIR/defconfig" defconfig
    "$CT_NG" defconfig >/dev/null
    "$CT_NG" menuconfig
    "$CT_NG" savedefconfig >/dev/null
    cp defconfig "$TARGET_DIR/defconfig"
)

echo "✓ Updated $TARGET_DIR/defconfig"