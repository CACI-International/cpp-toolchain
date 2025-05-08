load("//:host.bzl", "HOST_TARGET")
load("//util:tar.bzl", "tar_package")

package(default_visibility = ["//visibility:public"])

tar_package(
    name = "llvm-package",
    srcs = {
        "//:llvm": "llvm:.",
    },
    output = "llvm-" + HOST_TARGET,
)
