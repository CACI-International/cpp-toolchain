load("//feature/std:standards.bzl", "STANDARDS_FEATURES")

filegroup(
    name = "bzl_srcs",
    srcs = [
        "doc.bzl",
        "//feature/std:standards.bzl",
    ],
    visibility = ["//:__subpackages__"],
)

FEATURES = [
    "//feature/misc:debug_symbols",
    "//feature/misc:hide_symbols",
    "//feature/misc:strip_unused_dynamic_libs",
    "//feature/misc:thinlto",
    "//feature/misc:coverage",
    "//feature/optimize:no_optimization",
    "//feature/optimize:debug_optimization",
    "//feature/optimize:size_optimization",
    "//feature/optimize:moderate_optimization",
    "//feature/optimize:max_optimization",
    "//feature/sanitizers:asan",
    "//feature/sanitizers:ubsan",
    "//feature/sanitizers:lsan",
    "//feature/sanitizers:default_sanitizers",
    "//feature/warnings:warnings_enabled",
    "//feature/warnings:warnings_disabled",
    "//feature/warnings:extra_warnings",
    "//feature/warnings:pedantic_warnings",
    "//feature/warnings:treat_warnings_as_errors",
    "//feature/static:static_position_independent_executable",
    "//feature/static:default_linkage",
] + ["//feature/std:" + std for std in STANDARDS_FEATURES]

[
    alias(
        name = feature.split(":")[-1],
        actual = feature,
        visibility = ["//visibility:public"],
    )
    for feature in FEATURES
]
