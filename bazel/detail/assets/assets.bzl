load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_attrs = {
    "url": attr.string(mandatory = True),
    "integrity": attr.string(),
    "build_file": attr.label(mandatory = True),
    "env_override": attr.string(mandatory = True),
}

def _override(ctx, asset):
    suffix = asset["name"].split("-")[0].upper()

    override = ctx.getenv("PORTABLE_CC_TOOLCHAIN_" + suffix)
    if override == None:
        return {
            "url": asset["url"],
            "integrity": asset["integrity"],
        }
    else:
        override = override.replace("\\", "/")  # handle Windows paths too
        if not override.startswith('/'):
            override = '/' + override
        return {
            "url": "file://" + override,
        }

def _assets(ctx):
    assets = json.decode(ctx.read(Label("//detail/assets:assets.json")))

    for asset in assets:
        attrs = _override(ctx, asset)

        http_archive(
            name = asset["name"],
            build_file = "//detail/assets:{}.BUILD".format(asset["name"].split("-")[0]),
            **attrs
        )
    return ctx.extension_metadata(
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
        reproducible = True,
    )

assets = module_extension(
    implementation = _assets,
    environ = ["PORTABLE_CC_TOOLCHAIN_LLVM", "PORTABLE_CC_TOOLCHAIN_SYSROOT"],
)
