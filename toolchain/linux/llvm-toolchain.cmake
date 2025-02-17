# Don't set this! It enables CMAKE_CROSSCOMPILING, which breaks the LLVM build.
# set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/clang")
set(CMAKE_CXX_COMPILER "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/clang++")
set(CMAKE_ASM_COMPILER "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/clang")
set(CMAKE_LINKER "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/ld.lld")
set(CMAKE_AR "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/llvm-ar")
set(CMAKE_RANLIB "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/llvm-ranlib")
set(CMAKE_NM "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/llvm-nm")
set(CMAKE_OBJCOPY "$ENV{EXT_BUILD_ROOT}/%llvm%/bin/llvm-objcopy")

set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN "$ENV{EXT_BUILD_ROOT}/%gcc%")
set(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN "$ENV{EXT_BUILD_ROOT}/%gcc%")
set(CMAKE_ASM_COMPILER_EXTERNAL_TOOLCHAIN "$ENV{EXT_BUILD_ROOT}/%gcc%")

set(CMAKE_ASM_FLAGS "--target=%target%")

set(CMAKE_SYSROOT "$ENV{EXT_BUILD_ROOT}/%gcc%/%target%/sysroot")

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_C_COMPILER_TARGET "%target%")
set(CMAKE_CXX_COMPILER_TARGET "%target%")
set(CMAKE_ASM_COMPILER_TARGET "%target%")
            
set(CMAKE_FIND_ROOT_PATH "$ENV{EXT_BUILD_ROOT}/%gcc%/%target%/sysroot")

set(CMAKE_C_FLAGS "")
set(CMAKE_CXX_FLAGS "-D__STDC_FORMAT_MACROS=1") # workaround for GNU libstdc++
set(CMAKE_ASM_FLAGS "")
set(CMAKE_SHARED_LINKER_FLAGS "")
set(CMAKE_EXE_LINKER_FLAGS "")

if("%target%" STREQUAL "aarch64-unknown-linux-gnu")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DAT_HWCAP2=26")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DAT_HWCAP2=26")
endif()

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
