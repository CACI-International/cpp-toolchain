cmake_minimum_required(VERSION 3.20)
project(PortableToolchainImplementation NONE)

find_package(Python3 REQUIRED COMPONENTS Interpreter)

include(ExternalProject)
include(FetchContent)

include(${CMAKE_SOURCE_DIR}/cmake/host-triple.cmake)

# Download LLVM here, because we use it in multiple ExternalProjects
set(llvm_version 20.1.8)
string(REGEX MATCH "^([0-9]+)" llvm_major_version ${llvm_version})

FetchContent_Declare(llvm-source
    URL https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_version}/llvm-project-${llvm_version}.src.tar.xz
    PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/patches/musl.patch
)
FetchContent_MakeAvailable(llvm-source)
FetchContent_GetProperties(llvm-source SOURCE_DIR llvm_source_dir)

# Load OS-specific LLVM build script
include(${CMAKE_SOURCE_DIR}/cmake/libxml2.cmake)
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    add_subdirectory(gcc)
    include(${CMAKE_SOURCE_DIR}/cmake/llvm-linux.cmake)
else()
    include(${CMAKE_SOURCE_DIR}/cmake/llvm.cmake)
endif()
