_BUILD = """\
load("@portable_cc_toolchain//:toolchain.bzl", "make_toolchains")

make_toolchains("portable_cc_toolchain", "{toolchain}")
"""

def _make_toolchains_impl(ctx):
    ctx.file("BUILD", _BUILD.format(toolchain = ctx.attr.toolchain))

_make_toolchains = repository_rule(
    implementation = _make_toolchains_impl,
    attrs = {
        "toolchain": attr.label(),
    },
)

def _toolchain_impl(ctx):
    root_module_direct_deps = []
    root_module_direct_dev_deps = []
    for module in ctx.modules:
        if module.is_root:
            toolchain = Label("//:default_toolchain")
            if len(module.tags.override) > 0:
                toolchain = module.tags.override[-1].toolchain

            _make_toolchains(
                name = "portable_cc_toolchains",
                toolchain = toolchain,
            )

            if ctx.root_module_has_non_dev_dependency:
                root_module_direct_deps = ["portable_cc_toolchains"]
            else:
                root_module_direct_dev_deps = ["portable_cc_toolchains"]

    return ctx.extension_metadata(
        root_module_direct_deps = root_module_direct_deps,
        root_module_direct_dev_deps = root_module_direct_dev_deps,
        reproducible = True,
    )

_override = tag_class(attrs = {"toolchain": attr.label()})

toolchain = module_extension(
    implementation = _toolchain_impl,
    tag_classes = {
        "override": _override,
    },
)
