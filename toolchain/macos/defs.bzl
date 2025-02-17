load("//:config.bzl", "MIN_IOS_VERSION", "MIN_MACOS_ARM64_VERSION", "MIN_MACOS_X86_VERSION")

TARGETS = [
    "arm64-apple-macos",
    "arm64e-apple-macos",
    "x86_64-apple-macos",
    "arm64-apple-ios",
    "arm64e-apple-ios",
]
