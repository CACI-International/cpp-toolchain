load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")
load("//detail/args:target.bzl", "target_args")
load("//feature:doc.bzl", "FEATURES")

def portable_cc_toolchain(
        name,
        args = [],
        known_features = [],
        enabled_features = [],
        fastbuild_features = [],
        dbg_features = [],
        opt_features = [],
        apple_os_versions = {},
        **kwargs):
    target_args(
        name + "_target_args",
        apple_os_versions,
    )

    cc_toolchain(
        name = name,
        args = [
            name + "_target_args",
            Label("//detail/args:default"),
        ] + args,
        enabled_features = [
            "@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features",
        ] + select({
            Label("//detail/compilation_mode:fastbuild"): fastbuild_features,
            Label("//detail/compilation_mode:dbg"): dbg_features,
            Label("//detail/compilation_mode:opt"): opt_features,
        }) + enabled_features,
        known_features = [
            "@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features",
        ] + [Label(f) for f in FEATURES.keys()] + known_features,
        tool_map = Label("//detail/tools"),
        supports_param_files = False,  # we use a shell script wrapper to replace placeholder variables, maybe this can support param files in the future
        supports_header_parsing = True,
    )

_HOSTS = [
    ["@platforms//os:linux", "@platforms//cpu:x86_64"],
    ["@platforms//os:linux", "@platforms//cpu:aarch64"],
    ["@platforms//os:macos", "@platforms//cpu:x86_64"],
    ["@platforms//os:macos", "@platforms//cpu:arm64"],
]

_TARGETS = [
    ["@platforms//os:linux", "@platforms//cpu:x86_64"],
    ["@platforms//os:linux", "@platforms//cpu:armv7"],
    ["@platforms//os:linux", "@platforms//cpu:aarch64"],
    ["@platforms//os:macos"],
]

def _supported_combination(host, target):
    if "@platforms//os:linux" in host and "@platforms//os:macos" in target:
        return False
    return True

def make_toolchains(name, portable_cc_toolchain):
    for host in _HOSTS:
        for target in _TARGETS:
            if _supported_combination(host, target):
                toolchain_name = name + \
                                 "_".join([x.removeprefix("@platforms//os:").removeprefix("@platforms//cpu:") for x in host]) + \
                                 "_".join([x.removeprefix("@platforms//os:").removeprefix("@platforms//cpu:") for x in target])
                native.toolchain(
                    name = toolchain_name,
                    toolchain = portable_cc_toolchain,
                    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
                    exec_compatible_with = host,
                    target_compatible_with = target,
                )
