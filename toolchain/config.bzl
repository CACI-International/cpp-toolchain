LLVM_VERSION = "17.0.6"

MIN_IOS_VERSION = "12.5"
MIN_MACOS_X86_VERSION = "10.13"
MIN_MACOS_ARM64_VERSION = "11.0"

APPLE_TARGETS = [
    "arm64-apple-macos",
    "arm64e-apple-macos",
    "x86_64-apple-macos",
    "arm64-apple-ios",
    "arm64e-apple-ios",
]

LINUX_TARGETS = [
    "aarch64-unknown-linux-gnu",
    "armv7-unknown-linux-gnueabihf",
    "x86_64-unknown-linux-gnu",
]

LLVM_TOOLS = [
    "llvm-ar",
    "llvm-ranlib",
    "llvm-size",
    "llvm-nm",
    "llvm-strip",
    "llvm-objcopy",
    "llvm-objdump",
    "llvm-cxxfilt",
    "llvm-addr2line",
    "llvm-strings",
    "llvm-symbolizer",
    "llvm-cov",

    # Linux tooling, but may be useful on macOS
    "llvm-readelf",
    "llvm-readobj",

    # Apple tooling, but may be useful on Linux
    "llvm-install-name-tool",
    "llvm-lipo",
    "llvm-libtool-darwin,",
    "llvm-otool",
]
