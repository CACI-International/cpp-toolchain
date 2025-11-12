load("@rules_cc//cc/toolchains/impl:documented_api.bzl", "cc_args", "cc_args_list")
load("target.bzl", "APPLE_OS", "LINUX_TARGETS")

exports_files(
    ["target.bzl"],
    visibility = ["//:__subpackages__"],
)

cc_args_list(
    name = "default",
    args = [
        "sysroot",
        "no_absolute_paths",
        "color",
        "reproducible_build",
    ] + select({
        "@platforms//os:linux": ["static_runtime"],
        "@platforms//os:windows": ["windows"],
        "//conditions:default": [],
    }) + select({
        "//detail/compilation_mode:opt": ["opt"],
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "sysroot",
    actual = select({"//platform:{}-config".format(target): "@sysroot-{}//:sysroot".format(target) for target in LINUX_TARGETS} | {
        "@platforms//os:macos": "@xcode-macosx//:sdk",
        "@platforms//os:ios": "@xcode-iphoneos//:sdk",
        "@platforms//os:watchos": "@xcode-watchos//:sdk",
        "@platforms//os:tvos": "@xcode-appletvos//:sdk",
        "@platforms//os:visionos": "@xcode-xros//:sdk",
        "@platforms//os:windows": "@winsysroot//:sysroot",
    }),
)

cc_args(
    name = "windows",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["-fms-extensions"],
)

cc_args(
    name = "no_absolute_paths",
    actions = ["@rules_cc//cc/toolchains/actions:compile_actions"],
    args = ["-no-canonical-prefixes"],
)

cc_args(
    name = "static_runtime",
    actions = ["@rules_cc//cc/toolchains/actions:link_actions"],
    args = [
        "-static-libgcc",
        "-static-libstdc++",
    ],
)

cc_args(
    name = "color",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["-fdiagnostics-color=always"],
)

cc_args_list(
    name = "reproducible_build",
    args = ["reproducible_compile_args"] + select({
        "//platform:{}-config".format(target): ["@sysroot-{}//:reproducible_build".format(target)]
        for target in LINUX_TARGETS
    } | {
        "@platforms//os:" + os: ["reproducible_link_args_apple"]
        for os in APPLE_OS
    } | {
        "@platforms//os:windows": [],
    }),
)

cc_args(
    name = "reproducible_compile_args",
    actions = ["@rules_cc//cc/toolchains/actions:compile_actions"],
    args = [
        "-Wno-builtin-macro-redefined",
        '-D__DATE__="redacted"',
        '-D__TIMESTAMP__="redacted"',
        '-D__TIME__="redacted"',
        "-ffile-compilation-dir=.",
    ],
)

cc_args(
    name = "reproducible_link_args_apple",
    actions = ["@rules_cc//cc/toolchains/actions:link_actions"],
    args = ["-Wl,-oso_prefix,."],
)

cc_args_list(
    name = "opt",
    args = [
        "ndebug",
        "function_sections",
    ] + select({
        "@platforms//os:linux": ["gc_sections"],
        "//conditions:default": [],
    }),
)

cc_args(
    name = "ndebug",
    actions = ["@rules_cc//cc/toolchains/actions:compile_actions"],
    args = ["-DNDEBUG"],
)

cc_args(
    name = "function_sections",
    actions = ["@rules_cc//cc/toolchains/actions:compile_actions"],
    args = [
        "-ffunction-sections",
        "-fdata-sections",
    ],
)

cc_args(
    name = "gc_sections",
    actions = ["@rules_cc//cc/toolchains/actions:link_actions"],
    args = ["-Wl,--gc-sections"],
)
