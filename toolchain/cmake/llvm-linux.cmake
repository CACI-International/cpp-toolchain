# Build zlib, LLVM, compiler-rt, and openmp for each target

set(toolchain_targets
    "x86_64-unknown-linux-gnu"
    "aarch64-unknown-linux-gnu"
    "armv7-unknown-linux-gnueabihf"
    "x86_64-unknown-linux-musl"
    "aarch64-unknown-linux-musl"
)

function(get_gcc_toolchain_flags var triple)
    ExternalProject_Get_Property(gcc-toolchain-${triple} BINARY_DIR)
    set(gcc_dir ${BINARY_DIR})

    set(flags
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/toolchains/gcc.cmake
        -DGCC_TOOLCHAIN_ROOT=${gcc_dir}/toolchain
        -DTOOLCHAIN_TRIPLE=${triple}
    )
    set(${var} ${flags} PARENT_SCOPE)
endfunction()

function(get_llvm_toolchain_flags var triple)
    ExternalProject_Get_Property(gcc-toolchain-${triple} BINARY_DIR)
    set(gcc_dir ${BINARY_DIR})

    ExternalProject_Get_Property(llvm INSTALL_DIR)
    set(llvm_dir ${INSTALL_DIR})

    set(flags
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/toolchains/llvm.cmake
        -DGCC_TOOLCHAIN_ROOT=${gcc_dir}/toolchain
        -DLLVM_TOOLCHAIN_ROOT=${llvm_dir}
        -DTOOLCHAIN_TRIPLE=${triple}
        -DLLVM_VERSION=${llvm_version}
    )
    set(${var} ${flags} PARENT_SCOPE)
endfunction()

get_gcc_toolchain_flags(compile_with_gcc_for_host ${host_triple})

# Build zlib, a dependency of LLVM. It's only needed by the host.
ExternalProject_Add(zlib
    GIT_REPOSITORY https://github.com/madler/zlib.git
    GIT_TAG        v1.3.1
    DEPENDS gcc-toolchain-${host_triple}
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS
        ${compile_with_gcc_for_host}
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=Release
)

include(${CMAKE_SOURCE_DIR}/cmake/libxml2.cmake)
ExternalProject_Add(libxml2
    GIT_REPOSITORY https://gitlab.gnome.org/GNOME/libxml2.git
    GIT_TAG        v2.14.5
    DEPENDS gcc-toolchain-${host_triple}
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS
        ${compile_with_gcc_for_host}
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=Release
        ${libxml2_flags}
)

ExternalProject_Get_Property(zlib INSTALL_DIR)
set(zlib_dir ${INSTALL_DIR})

ExternalProject_Get_Property(libxml2 INSTALL_DIR)
set(libxml2_dir ${INSTALL_DIR})

# Build LLVM for the host
ExternalProject_Add(llvm
    SOURCE_DIR ${llvm_source_dir}
    INSTALL_DIR ${CMAKE_BINARY_DIR}/install/llvm
    DEPENDS zlib libxml2 gcc-toolchain-${host_triple}
    SOURCE_SUBDIR llvm
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS
        -C ${CMAKE_SOURCE_DIR}/caches/llvm.cmake
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=Release
        ${compile_with_gcc_for_host}
        -DZLIB_ROOT=${zlib_dir}
        -DCMAKE_PREFIX_PATH=${libxml2_dir}
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
)

ExternalProject_Get_Property(llvm INSTALL_DIR)
set(llvm_dir ${INSTALL_DIR})

# Build compiler-rt and openmp for each target
function(build_target_libraries target_arch)
    get_gcc_toolchain_flags(compile_with_gcc ${target_arch})
    get_llvm_toolchain_flags(compile_with_llvm ${target_arch})

    ExternalProject_Get_Property(llvm SOURCE_DIR)
    ExternalProject_Get_Property(llvm BINARY_DIR)

    ExternalProject_Add(compiler-rt-${target_arch}
        SOURCE_DIR ${llvm_source_dir}
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/compiler-rt-${target_arch}
        DOWNLOAD_COMMAND ""
        DEPENDS llvm gcc-toolchain-${target_arch}
        SOURCE_SUBDIR compiler-rt
        CMAKE_GENERATOR ${CMAKE_GENERATOR}
        CMAKE_ARGS
            -C ${CMAKE_SOURCE_DIR}/caches/compiler-rt.cmake
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_BUILD_TYPE=Release
            ${compile_with_llvm}
            -DLLVM_CMAKE_DIR=${BINARY_DIR}/lib/cmake/llvm
    )

    ExternalProject_Add(openmp-${target_arch}
        SOURCE_DIR ${llvm_source_dir}
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openmp-${target_arch}
        DOWNLOAD_COMMAND ""
        DEPENDS gcc-toolchain-${target_arch}
        SOURCE_SUBDIR openmp
        CMAKE_GENERATOR ${CMAKE_GENERATOR}
        CMAKE_ARGS
            -C ${CMAKE_SOURCE_DIR}/caches/openmp.cmake
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_BUILD_TYPE=Release
            # this could be build with LLVM, but building with GCC means
            # the sysroot only depends on target GCC, rather than target + host GCCs
            ${compile_with_gcc}
            -DLLVM_TOOLS_DIR=${BINARY_DIR}/bin
    )
endfunction()

# Build packages for each target
function(build_packages target_arch)
    ExternalProject_Get_Property(gcc-toolchain-${target_arch} BINARY_DIR)
    set(gcc_dir ${BINARY_DIR})

    ExternalProject_Get_Property(compiler-rt-${target_arch} INSTALL_DIR)
    set(compiler_rt_dir ${INSTALL_DIR})

    ExternalProject_Get_Property(openmp-${target_arch} INSTALL_DIR)
    set(openmp_dir ${INSTALL_DIR})

    configure_file(
        ${CMAKE_SOURCE_DIR}/packages/sysroot.json
        ${CMAKE_BINARY_DIR}/packages/sysroot-${target_arch}.json
        @ONLY
    )

    configure_file(
        ${CMAKE_SOURCE_DIR}/packages/compiler-rt.json
        ${CMAKE_BINARY_DIR}/packages/compiler-rt-${target_arch}.json
        @ONLY
    )

    add_custom_target(sysroot-package-${target_arch}
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/tar.py
                ${CMAKE_BINARY_DIR}/sysroot-${target_arch}.tar.xz
                ${CMAKE_BINARY_DIR}/packages/sysroot-${target_arch}.json
        DEPENDS gcc-toolchain-${target_arch} openmp-${target_arch} ${CMAKE_BINARY_DIR}/packages/sysroot-${target_arch}.json
    )
endfunction()

foreach(target_arch IN LISTS toolchain_targets)
    build_target_libraries(${target_arch})
    build_packages(${target_arch})
endforeach()

# Create a compiler-rt package containing the runtime for all targets
list(TRANSFORM toolchain_targets REPLACE "(.+)" "${CMAKE_BINARY_DIR}/packages/compiler-rt-\\1.json" OUTPUT_VARIABLE compiler_rt_package_configs)
list(TRANSFORM toolchain_targets REPLACE "(.+)" "compiler-rt-\\1" OUTPUT_VARIABLE compiler_rt_package_depends)

add_custom_target(compiler-rt-package
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/tar.py
            ${CMAKE_BINARY_DIR}/compiler-rt-linux.tar.xz
            ${compiler_rt_package_configs}
    DEPENDS ${compiler_rt_package_depends} ${compiler_rt_package_configs}
)

# Create an LLVM package that also contains compiler-rt
configure_file(
    ${CMAKE_SOURCE_DIR}/packages/llvm.json
    ${CMAKE_BINARY_DIR}/packages/llvm.json
    @ONLY
)

add_custom_target(llvm-package
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/tar.py
            ${CMAKE_BINARY_DIR}/llvm-${host_triple}.tar.xz
            ${CMAKE_BINARY_DIR}/packages/llvm.json ${compiler_rt_package_configs}
    DEPENDS llvm ${CMAKE_BINARY_DIR}/packages/llvm.json ${compiler_rt_package_depends} ${compiler_rt_package_configs}
)
