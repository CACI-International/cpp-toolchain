load("@rules_cc//cc/toolchains:args.bzl", "cc_args")

cc_args(
    name = "sdk",
    actions = [
        "@rules_cc//cc/toolchains/actions:assembly_actions",
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    allowlist_absolute_include_directories = ["{{XCODE_PATH}}"],
    args = ["--sysroot={{XCODE_PATH}}"],
    visibility = ["//visibility:public"],
)
