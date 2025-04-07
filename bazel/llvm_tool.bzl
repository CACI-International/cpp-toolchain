load("@host_platform//:constraints.bzl", "HOST_CONSTRAINTS")
load("//detail:host.bzl", "HOST_TARGET")

def _llvm_tool_rule_impl(ctx):
    link = ctx.actions.declare_file(ctx.file.tool.basename)
    ctx.actions.symlink(
        output = link,
        target_file = ctx.file.tool,
        is_executable = True,
    )
    return [DefaultInfo(
        files = depset([link]),
        runfiles = ctx.runfiles(files = ctx.files.data),
        executable = link,
    )]

_llvm_tool_rule = rule(
    implementation = _llvm_tool_rule_impl,
    attrs = {
        "tool": attr.label(allow_single_file = True),
        "data": attr.label(),
    },
    executable = True,
)

def llvm_tool(name = None, tool = None, *kwargs):
    if tool == None:
        tool = name
    _llvm_tool_rule(
        name = name,
        tool = Label("@llvm-{}//:bin/{}".format(HOST_TARGET, tool)),
        data = Label("@llvm-{}//:data".format(HOST_TARGET)),
        target_compatible_with = HOST_CONSTRAINTS,
        *kwargs
    )

def llvm_tool_file(tool):
    return Label("@llvm-{}//:bin/{}".format(HOST_TARGET, tool))
