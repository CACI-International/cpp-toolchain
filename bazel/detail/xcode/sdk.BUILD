load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@rules_cc//cc/toolchains/args:sysroot.bzl", "cc_sysroot")

directory(
    name = "sdk_link",
    srcs = glob(
        [
            "usr/include/**/*",
            "usr/lib/**/*",
            "System/Library/Frameworks/**/*",
        ],
    ),
)

cc_sysroot(
    name = "sdk",
    data = ["sdk_link"],
    sysroot = "sdk_link",
    visibility = ["//visibility:public"],
)
