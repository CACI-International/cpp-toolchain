load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("//:tar.bzl", "tar_package")
load("//:config.bzl", "LINUX_TARGETS")

package(default_visibility = ["//visibility:public"])

[
    # Files built by make + crosstool-ng
    copy_to_directory(
	name = target,
	srcs = glob(["targets/{}/toolchain/**/*".format(target)]),
        root_paths = ["**/toolchain"],
    )
    for target in LINUX_TARGETS
]
