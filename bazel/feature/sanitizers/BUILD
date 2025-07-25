load("@rules_cc//cc/toolchains/impl:documented_api.bzl", "cc_args", "cc_feature", "cc_feature_set")

cc_feature(
    name = "ubsan",
    args = ["ubsan_args"],
    feature_name = "ubsan",
    visibility = ["//feature:__pkg__"],
)

cc_args(
    name = "ubsan_args",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = [
        "-fsanitize=undefined",
        # disable vptr sanitizing, it causes infinite recursion if RTTI is used
        "-fno-sanitize=vptr",
    ] + select({
        "@platforms//os:macos": [
            # function call sanitizer seems to often fail on macOS due to missing typeinfos
            "-fno-sanitize=function",
        ],
        "//conditions:default": [],
    }),
)

cc_feature(
    name = "asan",
    args = ["asan_args"],
    feature_name = "asan",
    visibility = ["//feature:__pkg__"],
)

cc_args(
    name = "asan_args",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = [
        "-fsanitize=address",
        "-fno-omit-frame-pointer",
        "-fsanitize-address-use-after-return=always",
        "-fsanitize-address-use-after-scope",
    ],
)

cc_feature(
    name = "lsan",
    args = ["lsan_args"],
    feature_name = "lsan",
    visibility = ["//feature:__pkg__"],
)

cc_args(
    name = "lsan_args",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = [
        "-fsanitize=leak",
    ],
)

cc_feature_set(
    name = "default_sanitizers",
    all_of = select({
        "//platform:musl": ["ubsan"],
        "//conditions:default": [
            "ubsan",
            "asan",
            "lsan",
        ],
    }),
    visibility = ["//feature:__pkg__"],
)
