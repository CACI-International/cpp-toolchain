#!/bin/bash

set -euo pipefail
shopt -s extglob

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOL="$(basename "$0")"

default_target() {
    # Determine the tool prefix
    case $TOOL in
        x86_64-unknown-linux-gnu-*)
            echo x86_64-unknown-linux-gnu
            ;;
        aarch64-unknown-linux-gnu-*)
            echo aarch64-unknown-linux-gnu
            ;;
        armv7-unknown-linux-gnueabihf-*)
            echo armv7-unknown-linux-gnueabihf
            ;;
        *)
            # Use the host if unspecified
            cat ${BINDIR}/../libexec/wut/host
            ;;
    esac
}

TARGET="$(default_target)"

verify_target() {
    case $TARGET in
        x86_64?(-unknown|-pc)-linux?(-gnu))
            TARGET=x86_64-unknown-linux-gnu
            ;;
        aarch64?(-unknown|-pc)-linux-gnu)
            TARGET=aarch64-unknown-linux-gnu
            ;;
        armv7?(-unknown|-pc)-linux-gnueabihf)
            TARGET=armv7-unknown-linux-gnueabihf
            ;;
        *)
            echo "invalid target: $TARGET" >&2
            exit 1
            ;;
    esac

    SYSROOT="$BINDIR/../libexec/wut/gcc/$TARGET/$TARGET/sysroot"
}

unsupported () {
    echo "invalid flag for this toolchain: $1" >&2
    exit 1
}

compiler_args() {
    # Handle flags
    while(($#)) ; do
        case $1 in
            --target=*)
                TARGET=${1#--target=}
                ;;
            -target)
                TARGET=$2
                shift 1
                ;;
            *)
                ;;
        esac
        shift 1
    done

    verify_target

    echo "--config $BINDIR/../libexec/wut/$TARGET.cfg"
}

linker_args() {
    # Check for incompatible flags
    for ARG in "$@"; do
        case $ARG in
            --sysroot|--sysroot=*)
                unsupported $ARG
                ;;
            *)
                ;;
        esac
    done

    verify_target

    echo "--sysroot=$SYSROOT"
}

tidy_args() {
    # clang-tidy arguments
    while (($#)); do
        case $1 in
            --)
                shift 1
                break
                ;;
            *)
                ;;
        esac
        shift 1
    done

    # compiler arguments
    while (($#)); do
        case $1 in
            --target=*)
                TARGET=${1#--target=}
                ;;
            -target)
                TARGET=$2
                shift 1
                ;;
            *)
                ;;
        esac
        shift 1
    done

    verify_target

    echo "--extra-arg-before=--config --extra-arg-before=$BINDIR/../libexec/wut/$TARGET.cfg"
}

case $TOOL in
    c++|clang++|*-c++|*-clang++)
        ARGS=$(compiler_args c++ "$@")
        $BINDIR/../libexec/wut/llvm/bin/clang++ $ARGS "$@"
        ;;
    cc|clang|*-cc|*-clang)
        ARGS=$(compiler_args c "$@")
        $BINDIR/../libexec/wut/llvm/bin/clang $ARGS "$@"
        ;;
    ld|*-ld)
        ARGS=$(linker_args "$@")
        $BINDIR/../libexec/wut/llvm/bin/ld.lld $ARGS "$@"
        ;;
    clang-tidy|*-clang-tidy)
        ARGS=$(tidy_args "$@")
        $BINDIR/../libexec/wut/llvm/bin/clang-tidy $ARGS "$@"
        ;;
    *)
        echo "Invalid tool" >&2
        exit 1
        ;;
esac
