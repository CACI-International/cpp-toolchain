load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("//:host.bzl", "HOST_TARGET")
load("//:tar.bzl", "tar_package")

package(default_visibility = ["//visibility:public"])

# Assemble LLVM package
copy_to_directory(
    name = "llvm",
    srcs = ["//:llvm"],
    root_paths = [
        "llvm",
        ".",
    ],
)

# Package the compiler into a tar
tar_package(
    "llvm-package",
    "llvm-{}-{}".format(
        HOST_TARGET,
        module_version(),
    ),
    "llvm",
)
