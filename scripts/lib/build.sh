#!/bin/bash
# Build a CMake target

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

BUILD_DIR=${BUILD_DIR:-"build"}
TARGET=$1
shift || true

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target> [cmake-args...]" >&2
    exit 1
fi

ensure_cmake_configured toolchain
cmake_build_target "$TARGET" "$@"
