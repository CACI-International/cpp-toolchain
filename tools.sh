#!/bin/bash

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOL="$(basename "$0")"

case $TOOL in
    x86_64-unknown-linux-gnu-*)
        TARGET=x86_64-unknown-linux-gnu
        PREFIX="${TARGET}-"
        ;;
    aarch64-unknown-linux-gnu-*)
        TARGET=aarch64-unknown-linux-gnu
        PREFIX="${TARGET}-"
        ;;
    *)
        TARGET=$(cat ${BINDIR}/../scripts/host)
        PREFIX=""
        ;;
esac

SYSROOT=$BINDIR/../gcc/$TARGET/$TARGET/sysroot
COMPILER_FLAGS="--target=$TARGET --sysroot=$SYSROOT -gcc-toolchain $BINDIR/../gcc/$TARGET -fuse-ld=lld"

case $TOOL in
    ${PREFIX}c++)
        $BINDIR/../llvm/bin/clang++ $COMPILER_FLAGS $@
        ;;
    ${PREFIX}cc)
        $BINDIR/../llvm/bin/clang $COMPILER_FLAGS $@
        ;;
    ${PREFIX}ld)
        $BINDIR/../llvm/bin/ld.lld --sysroot=$SYSROOT $@
        ;;
    ${PREFIX}ar)
        $BINDIR/../llvm/bin/llvm-ar $@
        ;;
    ${PREFIX}ranlib)
        $BINDIR/../llvm/bin/llvm-ranlib $@
        ;;
    ${PREFIX}strip)
        $BINDIR/../llvm/bin/llvm-strip $@
        ;;
    ${PREFIX}nm)
        $BINDIR/../llvm/bin/llvm-nm $@
        ;;
    ${PREFIX}objcopy)
        $BINDIR/../llvm/bin/llvm-objcopy $@
        ;;
    ${PREFIX}objdump)
        $BINDIR/../llvm/bin/llvm-objdump $@
        ;;
    ${PREFIX}c++filt)
        $BINDIR/../llvm/bin/llvm-cxxfilt $@
        ;;
    ${PREFIX}addr2line)
        $BINDIR/../llvm/bin/llvm-addr2line $@
        ;;
    ${PREFIX}strings)
        $BINDIR/../llvm/bin/llvm-strings $@
        ;;
    ${PREFIX}readelf)
        $BINDIR/../llvm/bin/llvm-readelf $@
        ;;
    ${PREFIX}size)
        $BINDIR/../llvm/bin/llvm-readelf $@
        ;;
    *)
        echo "Invalid tool" >&2
        exit -1
        ;;
esac
