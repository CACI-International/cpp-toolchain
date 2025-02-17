load("cmake.bzl", "cmake")
load("config.bzl", "LLVM_TOOLS", "LLVM_VERSION")
load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")

package(default_visibility = ["//visibility:public"])

common_llvm_flags = {
    "LLVM_TARGETS_TO_BUILD": "X86;ARM;AArch64;NVPTX",
    "LLVM_ENABLE_ZLIB": "FORCE_ON",
    "LLVM_INSTALL_BINUTILS_SYMLINKS": "ON",
    "LLVM_INSTALL_CCTOOLS_SYMLINKS": "ON",
    "LLVM_INSTALL_TOOLCHAIN_ONLY": "ON",
    "LLVM_TOOLCHAIN_TOOLS": ";".join(LLVM_TOOLS),
    "LLVM_INCLUDE_DOCS": "OFF",
    "LLVM_INCLUDE_TESTS": "OFF",
    "LLVM_INCLUDE_EXAMPLES": "OFF",
    "LLVM_ENABLE_TERMINFO": "OFF",
    "LLVM_BUILD_LLVM_DYLIB": "ON",
    "LLVM_LINK_LLVM_DYLIB": "ON",
    "LLDB_ENABLE_PYTHON": "OFF",
    "LLDB_ENABLE_LIBEDIT": "OFF",
    "LLDB_ENABLE_CURSES": "OFF",
    "LLDB_ENABLE_LIBXML2": "OFF",
}

linux_llvm_flags = {
    "LLVM_ENABLE_PROJECTS": ";".join([
        "clang",
        "lld",
        "lldb",
        "clang-tools-extra",
    ]),
    "LLVM_STATIC_LINK_CXX_STDLIB": "ON",
    "CLANG_DEFAULT_LINKER": "lld",
}

macos_llvm_flags = {
    "LLVM_ENABLE_PROJECTS": ";".join([
        "clang",
        "lld",
        "lldb",
        "clang-tools-extra",
        "compiler-rt",
    ]),
    "LLVM_ENABLE_RUNTIMES": "libcxx;libcxxabi",
    "LLVM_ENABLE_LIBCXX": "ON",

    # TODO enable zstd compression in the future, maybe with a static link.
    "LLVM_ENABLE_ZSTD": "OFF",
    "LLDB_USE_SYSTEM_DEBUGSERVER": "ON",
    "LIBCXX_INSTALL_LIBRARY": "OFF",
    "LIBCXX_INSTALL_HEADERS": "ON",
    "LIBCXX_ENABLE_SHARED": "ON",
    "LIBCXX_ENABLE_STATIC": "OFF",
    "LIBCXX_USE_COMPILER_RT": "ON",
    "LIBCXX_HAS_ATOMIC_LIB": "OFF",
    "LIBCXX_HIDE_FROM_ABI_PER_TU_BY_DEFAULT": "ON",
    "LIBCXXABI_INSTALL_LIBRARY": "OFF",
    "LIBCXXABI_ENABLE_SHARED": "ON",
    "LIBCXXABI_ENABLE_STATIC": "OFF",
    "LIBCXXABI_USE_COMPILER_RT": "ON",
    "LIBCXXABI_USE_LLVM_UNWINDER": "OFF",
    "CLANG_DEFAULT_LINKER": "lld",
}

cmake(
    name = "llvm",
    build_args = ["-j16"],
    data = select({
        "@platforms//os:linux": ["//linux:zlib"],
        "//conditions:default": [],
    }),
    cache_entries = common_llvm_flags | select({
        "@platforms//os:linux": linux_llvm_flags,
        "@platforms//os:macos": macos_llvm_flags,
    }),
    env = select({
        "@platforms//os:linux": {
            "ZLIB_ROOT": "$$EXT_BUILD_ROOT/$(location //linux:zlib)",
        },
        "//conditions:default": {},
    }),
    lib_source = "@llvm-project",
    working_directory = "llvm",
)
