load("@host_platform//:constraints.bzl", "HOST_CONSTRAINTS")

def _get_host():
    if "@platforms//os:linux" in HOST_CONSTRAINTS:
        if "@platforms//cpu:x86_64" in HOST_CONSTRAINTS:
            return "x86_64-unknown-linux-gnu"
        if "@platforms//cpu:aarch64" in HOST_CONSTRAINTS:
            return "aarch64-unknown-linux-gnu"
        if "@platforms//cpu:arm" in HOST_CONSTRAINTS:
            return "armv7-unknown-linux-gnueabihf"
    if "@platforms//os:osx" in HOST_CONSTRAINTS:
        if "@platforms//cpu:x86_64" in HOST_CONSTRAINTS:
            return "x86_64-apple-macos"
        if "@platforms//cpu:aarch64" in HOST_CONSTRAINTS:
            return "arm64-apple-macos"
    if "@platforms//os:windows" in HOST_CONSTRAINTS:
        if "@platforms//cpu:x86_64" in HOST_CONSTRAINTS:
            return "x86_64-pc-windows-msvc"
        if "@platforms//cpu:aarch64" in HOST_CONSTRAINTS:
            return "aarch64-pc-windows-msvc"
    fail("Could not determine host target triple")

HOST_TARGET = _get_host()
