load("@rules_foreign_cc//toolchains:prebuilt_toolchains.bzl", "prebuilt_toolchains")

def rules_foreign_cc_toolchains(ctx):
    prebuilt_toolchains(cmake_version = "3.29.5", ninja_version = "none", register_toolchains = True)
    register_toolchains(
        "@rules_foreign_cc//toolchains:preinstalled_make_toolchain",
        "@rules_foreign_cc//toolchains:preinstalled_ninja_toolchain",
        "@rules_foreign_cc//toolchains:preinstalled_meson_toolchain",
        "@rules_foreign_cc//toolchains:preinstalled_autoconf_toolchain",
        "@rules_foreign_cc//toolchains:preinstalled_automake_toolchain",
        "@rules_foreign_cc//toolchains:preinstalled_m4_toolchain",
        "@rules_foreign_cc//toolchains:preinstalled_pkgconfig_toolchain",
    )
