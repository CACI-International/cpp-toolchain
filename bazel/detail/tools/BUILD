load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")
load("//detail:host.bzl", "HOST_TARGET")

alias(
    name = "tools",
    actual = select({
        "@platforms//os:macos": ":macos_tools",
        "//conditions:default": ":default_tools",
    }),
    visibility = ["//visibility:public"],
)

COMMON_TOOLS = {
    "@rules_cc//cc/toolchains/actions:assembly_actions": ":clang-wrapper",
    "@rules_cc//cc/toolchains/actions:c_compile": ":clang-wrapper",
    "@rules_cc//cc/toolchains/actions:cpp_compile_actions": ":clang++-wrapper",
    "@rules_cc//cc/toolchains/actions:link_actions": ":clang++-wrapper",
    "@rules_cc//cc/toolchains/actions:objcopy_embed_data": ":llvm-objcopy",
    "@rules_cc//cc/toolchains/actions:strip": ":llvm-strip",
}

cc_tool_map(
    name = "default_tools",
    tools = COMMON_TOOLS | {
        "@rules_cc//cc/toolchains/actions:ar_actions": ":llvm-ar",
    },
    visibility = ["//visibility:private"],
)

cc_tool_map(
    name = "macos_tools",
    tools = COMMON_TOOLS | {
        "@rules_cc//cc/toolchains/actions:ar_actions": ":llvm-libtool-darwin",
    },
    visibility = ["//visibility:private"],
)

TOOL = [
    "ld.lld",
    "ld64.lld",
    "llvm-ar",
    "llvm-libtool-darwin",
    "llvm-objcopy",
    "llvm-objdump",
    "llvm-cov",
    "llvm-strip",
    "clang-tidy",
]

[
    cc_tool(
        name = tool,
        src = "@llvm-{}//:bin/{}".format(HOST_TARGET, tool),
        data = ["@llvm-{}//:data".format(HOST_TARGET)],
        visibility = ["//visibility:private"],
    )
    for tool in TOOL
]

[
    (
        expand_template(
            name = tool + "-impl",
            out = tool,
            data = ["@llvm-{}//:bin/{}".format(HOST_TARGET, tool)],
            substitutions = {
                "TOOL": "$(execpath @llvm-{}//:bin/{})".format(HOST_TARGET, tool),
            },
            template = "wrapper.sh",
        ),
        cc_tool(
            name = tool + "-wrapper",
            src = tool + "-impl",
            data = ["@llvm-{}//:data".format(HOST_TARGET)],
            visibility = ["//visibility:private"],
        ),
    )
    for tool in [
        "clang",
        "clang++",
    ]
]
