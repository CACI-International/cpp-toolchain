#!/bin/bash
set -eu
args=()
for i in "$@"; do
    args+=("${i//__BAZEL_EXECUTION_ROOT__/$PWD}")
done

if [ -z ${EXT_BUILD_ROOT+x} ]; then
    "{{TOOL}}" "${args[@]}"
else
    # workaround for rules_foreign_cc
    "$EXT_BUILD_ROOT/{{TOOL}}" "${args[@]}"
fi
