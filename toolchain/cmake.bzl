load("@rules_foreign_cc//foreign_cc:defs.bzl", cmake_impl = "cmake")
load("config.bzl", "APPLE_TARGETS", "LINUX_TARGETS", "MIN_IOS_VERSION", "MIN_MACOS_ARM64_VERSION", "MIN_MACOS_X86_VERSION")

def _cross_compile_flags(target, build_with_llvm = False):
    parts = target.split("-")
    cpu = parts[0]
    vendor = parts[1]
    os = parts[2]
    target_var = target.replace("-", "_")

    if os == "ios" or os == "macos":
        if os == "ios":
            min_version = MIN_IOS_VERSION
        elif os == "macos":
            min_version = MIN_MACOS_ARM64_VERSION if cpu.startswith("arm64") else MIN_MACOS_X86_VERSION

        sysroots = {"macos": "macosx", "ios": "iphoneos"}
        return ({
            "CMAKE_OSX_ARCHITECTURES": cpu,
            "CMAKE_OSX_SYSROOT": sysroots[os],
            "CMAKE_OSX_DEPLOYMENT_TARGET": min_version,
        }, {})
    else:
        compiler = "llvm" if build_with_llvm else "gcc"
        return ({
            "CMAKE_TOOLCHAIN_FILE": "$CMAKE_TOOLCHAIN_FILE",
        }, {
            "CMAKE_TOOLCHAIN_FILE": "$(execpath //linux:{}-toolchain-{}.cmake)".format(compiler, target),
        })

def cmake(build_args = [], data = [], cache_entries = {}, env = {}, build_with_llvm = False, target = "host", **kwargs):
    if build_with_llvm:
        compiler = "llvm"
        data = data + ["//:llvm"]
    else:
        compiler = "gcc"

    if target == "host":
        cache_entries = cache_entries | select({"//platforms:config-" + triple: _cross_compile_flags(triple, build_with_llvm)[0] for triple in APPLE_TARGETS + LINUX_TARGETS})
        env = env | select({"//platforms:config-" + triple: _cross_compile_flags(triple, build_with_llvm)[1] for triple in APPLE_TARGETS + LINUX_TARGETS})
        data = data + select({"//platforms:config-" + triple: ["//gcc:{}".format(triple), "//linux:{}-toolchain-{}.cmake".format(compiler, triple)] for triple in LINUX_TARGETS} | {"//conditions:default": []})
    else:
        cache_entries = cache_entries | _cross_compile_flags(target, build_with_llvm)[0]
        env = env | _cross_compile_flags(target, build_with_llvm)[1]
        data = data + ["//gcc:{}".format(target), "//linux:{}-toolchain-{}.cmake".format(compiler, target)]

    cmake_impl(
        build_args = build_args + ["-j8"],
        data = data,
        cache_entries = cache_entries,
        env = env,
        generate_crosstool_file = select({
            "@platforms//os:linux": False,
            "//conditions:default": True,
        }),
        generate_args = select({
            "@platforms//os:linux": ["-DCMAKE_SHARED_LINKER_FLAGS=", "-DCMAKE_EXE_LINKER_FLAGS="],
            "//conditions:default": [],
        }) + ["-G Ninja"],
        # trick rules_foreign_cc into exposing all files
        out_data_dirs = ["."],
        out_headers_only = True,
        out_include_dir = ".",
        **kwargs
    )
