#!/bin/bash

set -euo pipefail
shopt -s extglob

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOL="$(basename "$0")"
TARGET="$(
    # Determine the tool prefix
    case $TOOL in
        arm64-apple-macos-*)
            echo arm64-apple-macos
            ;;
        arm64e-apple-macos-*)
            echo arm64e-apple-macos
            ;;
        x86_64-apple-macos-*)
            echo x86_64-apple-macos
            ;;
        arm64-apple-ios-*)
            echo arm64-apple-ios
            ;;
        arm64e-apple-ios-*)
            echo arm64e-apple-ios
            ;;
        *)
            # Use the host if unspecified
            cat ${BINDIR}/../libexec/wut/host
            ;;
    esac
)"

verify_target() {
    case $TARGET in
        arm64?(-apple)-@(macos|darwin))
            TARGET=arm64-apple-macos
            MIN_VERSION=11.0
            SDK_NAME=macosx
            ;;
        arm64e?(-apple)-@(macos|darwin))
            TARGET=arm64e-apple-macos
            MIN_VERSION=11.0
            SDK_NAME=macosx
            ;;
        x86_64?(-apple)-@(macos|darwin))
            TARGET=x86_64-apple-macos
            MIN_VERSION=10.13
            SDK_NAME=macosx
            ;;
        arm64?(-apple)-ios)
            TARGET=arm64-apple-ios
            MIN_VERSION=12.5
            SDK_NAME=iphoneos
            ;;
        arm64e?(-apple)-ios)
            TARGET=arm64e-apple-ios
            MIN_VERSION=12.5
            SDK_NAME=iphoneos
            ;;
        *)
            echo "invalid target: $TARGET" >&2
            exit 1
            ;;
    esac

    RUNTIME="${BINDIR}/../libexec/wut/runtime/$TARGET"
    SYSROOT=$(xcrun --sdk $SDK_NAME --show-sdk-path)
}

unsupported () {
    echo "invalid flag for this toolchain: $1" >&2
    exit 1
}

compiler_args() {
    # Handle flags
    LINK=true
    while(($#)) ; do
        case $1 in
            -c|-S|-E|-M|-MM)
                # We aren't linking, so don't use any link flags
                LINK=false
                ;;
            --target=*)
                TARGET=${1#--target=}
                ;;
            -target)
                TARGET=$2
                shift 1
                ;;
            -fuse-ld*)
                unsupported $1
                ;;
            --sysroot|--sysroot=*)
                unsupported $1
                ;;
            -gcc-toolchain)
                unsupported $1
                ;;
            *)
                ;;
        esac
        shift 1
    done

    verify_target

    LINK_FLAGS=""
    if [ "$LINK" = true ]; then
        LINK_FLAGS="-fuse-ld=lld -L${RUNTIME}/lib"
    fi

    echo "--target=$TARGET --sysroot=$SYSROOT -isystem ${RUNTIME}/include -m${SDK_NAME}-version-min=${MIN_VERSION} $LINK_FLAGS"
}

linker_args() {
    case $TARGET in
        arm64e*)
            ARCH=arm64e
            ;;
        arm64*)
            ARCH=arm64
            ;;
        x86_64*)
            ARCH=x86_64
            ;;
    esac

    # Check for incompatible flags
    for ARG in "$@"; do
        case $ARG in
            -syslibroot*)
                unsupported $ARG
                ;;
            -arch*)
                unsupported $ARG
                ;;
            *)
                ;;
        esac
    done

    verify_target

    echo "-syslibroot $SYSROOT -lSystem -L${RUNTIME} -arch $ARCH -platform_version $OS $MIN_VERSION 0.0"
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

    echo "--extra-arg-before=--target=$TARGET --extra-arg-before=--sysroot=$SYSROOT --extra-arg-before=-isystem --extra-arg-before=${RUNTIME}/include --extra-arg-before=-m${SDK_NAME}-version-min=${MIN_VERSION}"
}

case $TOOL in
    c++|clang++|*-c++|*-clang++)
        ARGS=$(compiler_args "$@")
        $BINDIR/../libexec/wut/llvm/bin/clang++ $ARGS "$@"
        ;;
    cc|clang|*-cc|*-clang)
        ARGS=$(compiler_args "$@")
        $BINDIR/../libexec/wut/llvm/bin/clang $ARGS "$@"
        ;;
    ld|*-ld)
        ARGS=$(linker_args "$@")
        $BINDIR/../libexec/wut/llvm/bin/ld64.lld $ARGS "$@"
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
