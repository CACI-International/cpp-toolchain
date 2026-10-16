# Build zlib and LLVM for the host, and runtimes for every target.

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

# Build the runtimes for every target with the just-built clang
set(runtimes_args "")
foreach(triple IN LISTS toolchain_targets)
    ExternalProject_Get_Property(gcc-toolchain-${triple} BINARY_DIR)
    foreach(prefix BUILTINS_${triple} RUNTIMES_${triple})
        list(APPEND runtimes_args
            -D${prefix}_CMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_SOURCE_DIR}/toolchains/llvm.cmake
            -D${prefix}_GCC_TOOLCHAIN_ROOT:PATH=${BINARY_DIR}/toolchain
            -D${prefix}_TOOLCHAIN_TRIPLE:STRING=${triple}
        )
    endforeach()
    list(APPEND runtimes_args
        "-DRUNTIMES_${triple}_LLVM_ENABLE_RUNTIMES:STRING=compiler-rt;openmp"
        -DRUNTIMES_${triple}_CACHE_FILES:FILEPATH=${CMAKE_SOURCE_DIR}/caches/runtimes.cmake
    )
endforeach()
list(TRANSFORM toolchain_targets PREPEND gcc-toolchain- OUTPUT_VARIABLE runtime_gcc_deps)

# Build LLVM for the host
ExternalProject_Add(llvm
    SOURCE_DIR ${llvm_source_dir}
    INSTALL_DIR ${CMAKE_BINARY_DIR}/install/llvm
    DEPENDS zlib libxml2 gcc-toolchain-${host_triple} ${runtime_gcc_deps}
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
    CMAKE_CACHE_ARGS
        -DLLVM_RUNTIME_TARGETS:STRING=${toolchain_targets}
        ${runtimes_args}
)

ExternalProject_Get_Property(llvm INSTALL_DIR)
set(llvm_dir ${INSTALL_DIR})

# Build packages for each target
function(build_packages target_arch)
    ExternalProject_Get_Property(gcc-toolchain-${target_arch} BINARY_DIR)
    set(gcc_dir ${BINARY_DIR})

    configure_file(
        ${CMAKE_SOURCE_DIR}/packages/sysroot.json
        ${CMAKE_BINARY_DIR}/packages/sysroot-${target_arch}.json
        @ONLY
    )

    add_custom_target(sysroot-package-${target_arch}
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/tar.py
                ${CMAKE_BINARY_DIR}/sysroot-${target_arch}.tar.xz
                ${CMAKE_BINARY_DIR}/packages/sysroot-${target_arch}.json
        DEPENDS gcc-toolchain-${target_arch} ${CMAKE_BINARY_DIR}/packages/sysroot-${target_arch}.json
    )
endfunction()

foreach(target_arch IN LISTS toolchain_targets)
    build_packages(${target_arch})
endforeach()

# Create the LLVM package
configure_file(
    ${CMAKE_SOURCE_DIR}/packages/llvm.json
    ${CMAKE_BINARY_DIR}/packages/llvm.json
    @ONLY
)

add_custom_target(llvm-package
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/tar.py
            ${CMAKE_BINARY_DIR}/llvm-${host_triple}.tar.xz
            ${CMAKE_BINARY_DIR}/packages/llvm.json
    DEPENDS llvm ${CMAKE_BINARY_DIR}/packages/llvm.json
)

# Create a package with only the runtimes, for hosts that can't build them
ExternalProject_Get_Property(llvm BINARY_DIR)
set(llvm_build_dir ${BINARY_DIR})
set(runtimes_stage_dir ${CMAKE_BINARY_DIR}/install/runtimes)
set(runtimes_dir ${runtimes_stage_dir}${llvm_dir})

configure_file(
    ${CMAKE_SOURCE_DIR}/packages/runtimes.json
    ${CMAKE_BINARY_DIR}/packages/runtimes.json
    @ONLY
)

add_custom_target(runtimes-package
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${runtimes_stage_dir}
    COMMAND ${CMAKE_COMMAND} -E env DESTDIR=${runtimes_stage_dir}
            ${CMAKE_COMMAND} --build ${llvm_build_dir} --target install-runtimes install-builtins
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/tar.py
            ${CMAKE_BINARY_DIR}/runtimes-linux.tar.xz
            ${CMAKE_BINARY_DIR}/packages/runtimes.json
    DEPENDS llvm ${CMAKE_BINARY_DIR}/packages/runtimes.json
)
