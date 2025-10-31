load("//feature/std:standards.bzl", "STANDARDS_FEATURES")

def _std_doc(std):
    if std.startswith("cpp"):
        language = "C++"
    else:
        language = "C"
    version = std.removeprefix("cpp").removeprefix("c")
    return "Use {}{} language standard".format(language, version)

FEATURES = {
    "//feature:debug_symbols": "Generage debug information",
    "//feature:hide_symbols": "Set hidden symbol visibility",
    "//feature:strip_unused_dynamic_libs": "Don't link against dynamic libraries that aren't referenced by any symbols",
    "//feature:thinlto": "Link with ThinLTO (incremental link time optimization)",
    "//feature:coverage": "Compile with instrumentation for code coverage",
    "//feature:no_optimization": "Disable all optimizations",
    "//feature:debug_optimization": "Optimize for debugging",
    "//feature:size_optimization": "Optimize for smallest binary size",
    "//feature:moderate_optimization": "Enable standard optimizations",
    "//feature:max_optimization": "Enable maximum optimizations",
    "//feature:asan": "Instrument with AddressSanitizer",
    "//feature:ubsan": "Instrument with UndefinedBehaviorSanitizer",
    "//feature:lsan": "Instrument with LeakSanitizer",
    "//feature:default_sanitizers": "Instrument with the sanitizers supported by the default_linkage feature",
    "//feature:warnings_enabled": "Emit warnings",
    "//feature:warnings_disabled": "Disable warnings",
    "//feature:extra_warnings": "Emit extra warnings",
    "//feature:pedantic_warnings": "Emit pedantic warnings",
    "//feature:treat_warnings_as_errors": "Treat warnings as errors",
    "//feature:static_position_independent_executable": "Link static PIE executables",
    "//feature:default_linkage": "Default linkage for the platform: static PIE on musl, regular linkage elsewhere",
} | {
    "//feature:" + std: _std_doc(std)
    for std in STANDARDS_FEATURES
}

def _generate_features_doc(ctx):
    doc = """\
# Features

| Feature | Target | Description |
| ------- | ------ | ----------- |
"""
    for feature, description in ctx.attr._features.items():
        doc += "| `{}` | `{}` | {} |\n".format(feature.split(":")[-1].replace("cpp", "c++"), feature, description)
    f = ctx.actions.declare_file(ctx.attr.out)
    ctx.actions.write(f, doc)
    return [DefaultInfo(files = depset([f]))]

generate_features_doc = rule(
    implementation = _generate_features_doc,
    attrs = {
        "out": attr.string(),
        "_features": attr.string_dict(default = FEATURES),
    },
)
