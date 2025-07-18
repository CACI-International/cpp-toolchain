include("${CMAKE_CURRENT_LIST_DIR}/private/download.cmake")



# Host triple

if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
    set(_host_triple "${CMAKE_HOST_SYSTEM_PROCESSOR}-unknown-linux-gnu")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
    set(_host_triple "${CMAKE_HOST_SYSTEM_PROCESSOR}-apple-macos")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
    if("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL AMD64)
        set(_host_triple "x86-64-pc-windows-msvc")
    elseif("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL ARM64)
        set(_host_triple "aarch64-pc-windows-msvc")
    endif()
else()
    message(FATAL_ERROR "Unsupported host operating system: ${CMAKE_HOST_SYSTEM_NAME}")
endif()



# Target triple

if(NOT TARGET_TRIPLE)
    set(TARGET_TRIPLE ${_host_triple})
endif()

if(TARGET_TRIPLE STREQUAL ${_host_triple})
    set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
endif()



# Set CMake variables

if(NOT _host_triple STREQUAL TARGET_TRIPLE)
    if(TARGET_TRIPLE STREQUAL "x86_64-unknown-linux-gnu")
        set(CMAKE_SYSTEM_NAME Linux)
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    elseif(TARGET_TRIPLE STREQUAL "aarch64-unknown-linux-gnu")
        set(CMAKE_SYSTEM_NAME Linux)
        set(CMAKE_SYSTEM_PROCESSOR aarch64)
    elseif(TARGET_TRIPLE STREQUAL "armv7-unknown-linux-gnueabihf")
        set(CMAKE_SYSTEM_NAME Linux)
        set(CMAKE_SYSTEM_PROCESSOR arm)
    elseif(TARGET_TRIPLE STREQUAL "x86_64-apple-macos")
        set(CMAKE_SYSTEM_NAME Darwin)
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    elseif(TARGET_TRIPLE STREQUAL "arm64-apple-macos")
        set(CMAKE_SYSTEM_NAME Darwin)
        set(CMAKE_SYSTEM_PROCESSOR arm64)
    elseif(TARGET_TRIPLE STREQUAL "x86_64-pc-windows-msvc")
        set(CMAKE_SYSTEM_NAME Windows)
        set(CMAKE_SYSTEM_PROCESSOR AMD64)
    elseif(TARGET_TRIPLE STREQUAL "aarch64-pc-windows-msvc")
        set(CMAKE_SYSTEM_NAME Windows)
        set(CMAKE_SYSTEM_PROCESSOR ARM64)
    endif()
endif()



# Download toolchain

download(_llvm_dir "llvm-${_host_triple}" PORTABLE_CC_TOOLCHAIN_LLVM)
if("${TARGET_TRIPLE}" MATCHES "linux")
    download(_sysroot_dir "sysroot-${TARGET_TRIPLE}" PORTABLE_CC_TOOLCHAIN_SYSROOT)
endif()



# Configure toolchain

set(_exe "")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
    set(_exe ".exe")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL Windows)
    set(CMAKE_C_COMPILER   "${_llvm_dir}/bin/clang-cl${_exe}"  CACHE FILEPATH "")
    set(CMAKE_CXX_COMPILER "${_llvm_dir}/bin/clang-cl${_exe}"  CACHE FILEPATH "")
    set(CMAKE_ASM_COMPILER "${_llvm_dir}/bin/clang-cl${_exe}"  CACHE FILEPATH "")
    set(CMAKE_AR           "${_llvm_dir}/bin/llvm-lib${_exe}"  CACHE FILEPATH "")
    set(CMAKE_LINKER       "${_llvm_dir}/bin/lld-link${_exe}"  CACHE FILEPATH "")
else()
    set(CMAKE_C_COMPILER   "${_llvm_dir}/bin/clang${_exe}"     CACHE FILEPATH "")
    set(CMAKE_CXX_COMPILER "${_llvm_dir}/bin/clang++${_exe}"   CACHE FILEPATH "")
    set(CMAKE_ASM_COMPILER "${_llvm_dir}/bin/clang${_exe}"     CACHE FILEPATH "")
    set(CMAKE_AR           "${_llvm_dir}/bin/llvm-ar${_exe}"   CACHE FILEPATH "")
    if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
        set(CMAKE_LINKER   "${_llvm_dir}/bin/ld64.lld${_exe}"  CACHE FILEPATH "")
    else()
        set(CMAKE_LINKER   "${_llvm_dir}/bin/ld.lld${_exe}"    CACHE FILEPATH "")
    endif()
endif()

set(CMAKE_RANLIB  "${_llvm_dir}/bin/llvm-ranlib${_exe}"    CACHE FILEPATH "")
set(CMAKE_NM      "${_llvm_dir}/bin/llvm-nm${_exe}"        CACHE FILEPATH "")
set(CMAKE_STRIP   "${_llvm_dir}/bin/llvm-strip${_exe}"     CACHE FILEPATH "")
set(CMAKE_OBJCOPY "${_llvm_dir}/bin/llvm-objcopy${_exe}"   CACHE FILEPATH "")
set(CMAKE_OBJDUMP "${_llvm_dir}/bin/llvm-objdump${_exe}"   CACHE FILEPATH "")
set(CMAKE_READELF "${_llvm_dir}/bin/llvm-readelf${_exe}"   CACHE FILEPATH "")
set(CMAKE_INSTALL_NAME_TOOL "${_llvm_dir}/bin/llvm-install-name-tool${_exe}" CACHE FILEPATH "")

set(CMAKE_ASM_FLAGS "--target=${TARGET_TRIPLE}")

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_C_COMPILER_TARGET "${TARGET_TRIPLE}")
set(CMAKE_CXX_COMPILER_TARGET "${TARGET_TRIPLE}")
set(CMAKE_ASM_COMPILER_TARGET "${TARGET_TRIPLE}")

if(CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN "${_sysroot_dir}")
    set(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN "${_sysroot_dir}")
    set(CMAKE_ASM_COMPILER_EXTERNAL_TOOLCHAIN "${_sysroot_dir}")

    set(CMAKE_SYSROOT        "${_sysroot_dir}/${TARGET_TRIPLE}/sysroot")
    set(CMAKE_FIND_ROOT_PATH "${_sysroot_dir}/${TARGET_TRIPLE}/sysroot")

    set(CMAKE_EXE_LINKER_FLAGS_INIT    "-static-libgcc -static-libstdc++")
    set(CMAKE_SHARED_LINKER_FLAGS_INIT "-static-libgcc -static-libstdc++")
    set(CMAKE_MODULE_LINKER_FLAGS_INIT "-static-libgcc -static-libstdc++")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
