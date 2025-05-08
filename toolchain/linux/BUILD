load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("@llvm_version//:llvm_version.bzl", "LLVM_VERSION")
load("//:cmake.bzl", "cmake")
load("//:config.bzl", "LINUX_TARGETS")
load("//:host.bzl", "HOST_TARGET")
load("//util:tar.bzl", "tar_package")

package(default_visibility = ["//visibility:public"])

# The following targets are built for each target
[
    (
        # Build OpenMP
        cmake(
            name = "openmp-{}".format(target),
            cache_entries = {
                "LIBOMP_ENABLE_SHARED": "OFF",
                "LIBOMP_CXXFLAGS": "-fPIC -fvisibility=hidden -fvisibility-inlines-hidden",
                "LIBOMP_OMPD_GDB_SUPPORT": "OFF",  # requires python
                "OPENMP_ENABLE_LIBOMPTARGET": "OFF",
            },
            lib_source = "@llvm-project",
            target = target,
            working_directory = "openmp",
        ),

        # Build compiler-rt
        cmake(
            name = "compiler-rt-{}".format(target),
            build_with_llvm = True,
            cache_entries = {
                "COMPILER_RT_BUILD_BUILTINS": "OFF",
                "COMPILER_RT_DEFAULT_TARGET_ONLY": "ON",
                "COMPILER_RT_USE_LIBCXX": "OFF",

                # Workaround for https://gitlab.kitware.com/cmake/cmake/-/issues/22995
                "CMAKE_ASM_COMPILER_VERSION": LLVM_VERSION,

                # Workaround for https://github.com/llvm/llvm-project/issues/57717
                "COMPILER_RT_BUILD_GWP_ASAN": "OFF",
            },
            lib_source = "@llvm-project",
            target = target,
            working_directory = "compiler-rt",
        ),

        # Package the sysroot into a tar
        tar_package(
            name = "sysroot-package-{}".format(target),
            srcs = {
                "//gcc:{}-srcs".format(target): "targets/{}/toolchain:.".format(target),  # don't use copy_to_directory here, because it erases symlinks
                "openmp-{}".format(target): "openmp-{}:{}/sysroot/usr".format(target, target),
                "targets/{}.cfg".format(target): "targets:.",
            },
            exclude = [
                "build.log.bz2",
                "bin/**",
                "libexec/**",
                "{}/bin/**".format(target),
            ],
            output = "sysroot-" + target,
        ),

        # toolchain.cmake files for building with the GCC and LLVM cross-compilers
        # These are automatically used by the `cmake` rule.
        expand_template(
            name = "gcc-toolchain-{}".format(target),
            out = "gcc-toolchain-{}.cmake".format(target),
            data = ["//gcc:{}".format(target)],
            substitutions = {
                "%target%": target,
                "%gcc%": "$(execpath //gcc:{})".format(target),
            },
            template = "gcc-toolchain.cmake",
        ),
        expand_template(
            name = "llvm-toolchain-{}".format(target),
            out = "llvm-toolchain-{}.cmake".format(target),
            data = [
                "//gcc:{}".format(target),
                "//:llvm",
            ],
            substitutions = {
                "%target%": target,
                "%llvm%": "$(execpath //:llvm)",
                "%gcc%": "$(execpath //gcc:{})".format(target),
            },
            template = "llvm-toolchain.cmake",
        ),
    )
    for target in LINUX_TARGETS
]

COMPILER_RT_SRCS = {
    "compiler-rt-" + target: "compiler-rt-{}:lib/clang/{}".format(
        target,
        LLVM_VERSION.split(".")[0],
    )
    for target in LINUX_TARGETS
}

# Package the compiler into a tar
tar_package(
    name = "llvm-package",
    srcs = {
        "//:llvm": "llvm:.",
    } | COMPILER_RT_SRCS,
    output = "llvm-{}".format(HOST_TARGET),
)

# Make standalone compiler-rt for macOS hosts
tar_package(
    name = "compiler-rt-package",
    srcs = COMPILER_RT_SRCS,
    output = "compiler-rt-linux",
)
