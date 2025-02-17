# Don't set this! It enables CMAKE_CROSSCOMPILING, which breaks the LLVM build.
# set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER "$ENV{EXT_BUILD_ROOT}/%gcc%/bin/%target%-cc")
set(CMAKE_CXX_COMPILER "$ENV{EXT_BUILD_ROOT}/%gcc%/bin/%target%-c++")
set(CMAKE_ASM_COMPILER "$ENV{EXT_BUILD_ROOT}/%gcc%/bin/%target%-cc")
# set(CMAKE_LINKER "$ENV{EXT_BUILD_ROOT}/%gcc%/bin/%target%-ld")
set(CMAKE_AR "$ENV{EXT_BUILD_ROOT}/%gcc%/bin/%target%-ar")
set(CMAKE_RANLIB "$ENV{EXT_BUILD_ROOT}/%gcc%/bin/%target%-ranlib")

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_C_COMPILER_TARGET "%target%")
set(CMAKE_CXX_COMPILER_TARGET "%target%")
set(CMAKE_ASM_COMPILER_TARGET "%target%")
            
set(CMAKE_FIND_ROOT_PATH "$ENV{EXT_BUILD_ROOT}/%gcc%/%target%/sysroot")

set(CMAKE_C_FLAGS "-static-libgcc")
set(CMAKE_CXX_FLAGS "-static-libgcc -static-libstdc++")
set(CMAKE_ASM_FLAGS "")
set(CMAKE_SHARED_LINKER_FLAGS "")
set(CMAKE_EXE_LINKER_FLAGS "")

if(DEFINED ENV{ZLIB_ROOT})
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I$ENV{ZLIB_ROOT}/include")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I$ENV{ZLIB_ROOT}/include")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-rpath-link,$ENV{ZLIB_ROOT}/lib")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath-link,$ENV{ZLIB_ROOT}/lib")
endif()

if("%target%" STREQUAL "aarch64-unknown-linux-gnu")
    set(CMAKE_C_FLAGS "$CMAKE_C_FLAGS -DAT_HWCAP2=26")
    set(CMAKE_CXX_FLAGS "$CMAKE_CXX_FLAGS -DAT_HWCAP2=26")
endif()

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
