load("toolchain.bzl", "portable_cc_toolchain")

portable_cc_toolchain(
    name = "default_toolchain",
    apple_os_versions = {
        "macos": "11",
    },
    dbg_features = [
        "//feature:asan",
        "//feature:ubsan",
        "//feature:lsan",
        "//feature:no_optimization",  # in a future version, this could be debug_optimization
    ],
    enabled_features = [
        "//feature:c17",
        "//feature:cpp17",
        "//feature:warnings_enabled",
        "//feature:debug_symbols",
        "//feature:strip_unused_dynamic_libs",
    ],
    fastbuild_features = [
        "//feature:no_optimization",
    ],
    opt_features = [
        "//feature:moderate_optimization",
    ],
    visibility = ["//visibility:public"],
)
