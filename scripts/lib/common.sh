#!/bin/bash
# Common functions for build scripts

# Ensure CMake is configured, reconfiguring if needed
# Usage: ensure_cmake_configured <source_dir> [build_dir]
ensure_cmake_configured() {
    local source_dir=$1
    local build_dir=${2:-${BUILD_DIR:-"build"}}
    local cache="$build_dir/CMakeCache.txt"
    
    if [ ! -f "$cache" ] || \
       [ -n "$(find toolchain -name '*.cmake' -o -name 'CMakeLists.txt' -newer "$cache" 2>/dev/null)" ]; then
        cmake -S "$source_dir" -B "$build_dir"
    fi
}

# Build a CMake target
# Usage: cmake_build_target <target> [args...]
cmake_build_target() {
    local target=$1
    shift || true
    local build_dir=${BUILD_DIR:-"build"}
    
    cmake --build "$build_dir" --target "$target" "$@"
}