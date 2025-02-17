load("@aspect_bazel_lib//lib:tar.bzl", "mtree_mutate", "mtree_spec", "tar")

def tar_package(name, out, src):
    mtree_spec(
        name = name + "_mtree_spec",
        srcs = [src],
    )

    src_label = native.package_relative_label(src)
    mtree_mutate(
        name = name + "_mtree_mutate",
        mtree = name + "_mtree_spec",
        owner = "1000",
        ownername = "default",
        mtime = "946684800",
        strip_prefix = src_label.package + "/" + src_label.name,
    )

    tar(
        name = name,
        mtree = name + "_mtree_mutate",
        out = out + ".tar.xz",
        compress = "xz",
        srcs = [src],
    )
