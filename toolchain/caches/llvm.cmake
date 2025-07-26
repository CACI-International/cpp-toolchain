set(LLVM_TOOLCHAIN_TOOLS
    "llvm-ar"
    "llvm-ranlib"
    "llvm-size"
    "llvm-nm"
    "llvm-strip"
    "llvm-objcopy"
    "llvm-objdump"
    "llvm-cxxfilt"
    "llvm-addr2line"
    "llvm-strings"
    "llvm-symbolizer"
    "llvm-cov"

    # Linux tooling
    "llvm-readelf"
    "llvm-readobj"

    # Apple tooling
    "llvm-install-name-tool"
    "llvm-lipo"
    "llvm-libtool-darwin"
    "llvm-otool"

    # Windows tooling
    "llvm-dlltool"
    "llvm-lib"

    CACHE STRING ""
)

set(LLVM_ENABLE_PROJECTS
    "clang"
    "lld"
    "lldb"
    "clang-tools-extra"
    CACHE STRING ""
)

set(LLVM_TARGETS_TO_BUILD
    "X86"
    "ARM"
    "AArch64"
    "NVPTX"
    CACHE STRING ""
)

set(LLVM_INSTALL_BINUTILS_SYMLINKS      ON        CACHE BOOL "")
set(LLVM_INSTALL_CCTOOLS_SYMLINKS       ON        CACHE BOOL "")
set(LLVM_INSTALL_TOOLCHAIN_ONLY         ON        CACHE BOOL "")
set(LLVM_INCLUDE_DOCS                   OFF       CACHE BOOL "")
set(LLVM_INCLUDE_TESTS                  OFF       CACHE BOOL "")
set(LLVM_INCLUDE_EXAMPLES               OFF       CACHE BOOL "")
set(LLVM_ENABLE_ZLIB                    FORCE_ON  CACHE STRING "")
set(LLVM_ENABLE_PER_TARGET_RUNTIME_DIR  ON        CACHE BOOL "")
set(LLDB_ENABLE_PYTHON                  OFF       CACHE BOOL "")
set(LLDB_ENABLE_LIBEDIT                 OFF       CACHE BOOL "")
set(LLDB_ENABLE_CURSES                  OFF       CACHE BOOL "")
set(LLDB_ENABLE_LIBXML2                 OFF       CACHE BOOL "")
set(LLVM_ENABLE_TERMINFO                OFF       CACHE BOOL "")
set(CLANG_DEFAULT_LINKER                "lld"     CACHE STRING "")

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(LLVM_BUILD_LLVM_DYLIB  ON  CACHE BOOL "")
    set(LLVM_LINK_LLVM_DYLIB   ON  CACHE BOOL "")
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")

    set(LLVM_STATIC_LINK_CXX_STDLIB  ON     CACHE BOOL "")

elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")

    set(CMAKE_OSX_SYSROOT "macosx" CACHE STRING "")
    if(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
        set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "")
    else()
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "")
    endif()
    set(RUNTIMES_CMAKE_ARGS "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.13;-DCMAKE_OSX_ARCHITECTURES=arm64|x86_64" CACHE STRING "") # https://github.com/llvm/llvm-project/issues/63085

    # It would be nice to include our own libc++ headers here, to allow using features not available in the installed xcode, but in practice that can cause issues: https://github.com/llvm/llvm-project/issues/77653
    # LLVM can introduce new libc++ symbols not yet released in any macOS version.
    set(LLVM_ENABLE_RUNTIMES
        "compiler-rt"
        CACHE STRING ""
    )

    set(LLVM_ENABLE_LIBCXX           ON   CACHE BOOL "")
    set(LLDB_USE_SYSTEM_DEBUGSERVER  ON   CACHE BOOL "")
    set(LLVM_ENABLE_ZSTD             OFF  CACHE BOOL "") # TODO enable zstd compression in the future, maybe with a static link.

elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")

    set(LLVM_ENABLE_RUNTIMES "compiler-rt" CACHE STRING "")
    set(LLVM_RUNTIME_TARGETS "default" CACHE STRING "")

endif()
