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

DEFAULT_TOOLS = {
    "@rules_cc//cc/toolchains/actions:assembly_actions": ":clang",
    "@rules_cc//cc/toolchains/actions:c_compile": ":clang",
    "@rules_cc//cc/toolchains/actions:cpp_compile_actions": ":clang++",
    "@rules_cc//cc/toolchains/actions:link_actions": ":clang++",
    "@rules_cc//cc/toolchains/actions:ar_actions": ":llvm-ar",
    "@rules_cc//cc/toolchains/actions:objcopy_embed_data": ":llvm-objcopy",
    "@rules_cc//cc/toolchains/actions:strip": ":llvm-strip",
}

cc_tool_map(
    name = "default_tools",
    tools = DEFAULT_TOOLS,
    visibility = ["//visibility:private"],
)

cc_tool_map(
    name = "macos_tools",
    tools = DEFAULT_TOOLS | {
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
    "clang",
    "clang++",
    "clang-cl",
]

EXE_EXT = ".exe" if "windows" in HOST_TARGET else ""

[
    cc_tool(
        name = tool,
        src = "@llvm-{}//:bin/{}{}".format(HOST_TARGET, tool, EXE_EXT),
        capabilities = select({
            "@platforms//os:windows": [
                # "@rules_cc//cc/toolchains/capabilities:supports_dynamic_linker",
                # "@rules_cc//cc/toolchains/capabilities:supports_interface_shared_libraries",
                # "@rules_cc//cc/toolchains/capabilities:targets_windows",
                # "@rules_cc//cc/toolchains/capabilities:has_configured_linker_path",
                # "@rules_cc//cc/toolchains/capabilities:copy_dynamic_libraries_to_binary",
            ],
            "//conditions:default": [],
        }),
        data = ["@llvm-{}//:data".format(HOST_TARGET)],
        visibility = ["//visibility:private"],
    )
    for tool in TOOL
]
