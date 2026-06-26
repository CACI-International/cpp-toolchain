#!/bin/bash

set -ex
rm -rf build
cmake -S . -B build \
    --warn-uninitialized \
    -Werror=dev \
    -GNinja \
    -DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDOUT \
    -DCMAKE_TOOLCHAIN_FILE="portable_cc_toolchain/${1:-toolchain}.cmake" \
    -DCMAKE_BUILD_TYPE=${2:-Debug}
cmake --build build --verbose
ctest --test-dir build --no-tests=ignore

# Wait for Windows to release file handles
if command -v powershell.exe &> /dev/null; then
    sleep 2
fi
