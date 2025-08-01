# Windows doesn't have zlib or libxml2 builtin
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    # Build zlib
    ExternalProject_Add(zlib
        GIT_REPOSITORY https://github.com/madler/zlib.git
        GIT_TAG        v1.3.1
        CMAKE_GENERATOR ${CMAKE_GENERATOR}
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_BUILD_TYPE=Release
    )

    ExternalProject_Get_Property(zlib INSTALL_DIR)
    set(zlib_flag -DZLIB_ROOT=${INSTALL_DIR} -DZLIB_USE_STATIC_LIBS=ON)
    set(zlib_dep zlib)

    include(${CMAKE_SOURCE_DIR}/cmake/libxml2.cmake)
    ExternalProject_Add(libxml2
        GIT_REPOSITORY https://gitlab.gnome.org/GNOME/libxml2.git
        GIT_TAG        v2.14.5
        CMAKE_GENERATOR ${CMAKE_GENERATOR}
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_BUILD_TYPE=Release
            -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
            ${libxml2_flags}
    )

    ExternalProject_Get_Property(libxml2 INSTALL_DIR)

    set(libxml2_flag
        -DCMAKE_PREFIX_PATH=${libxml2_dir}
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
        -DLIBXML2_LIBRARY=${INSTALL_DIR}/lib/libxml2s.lib
        -DLIBXML2_INCLUDE_DIR=${INSTALL_DIR}/include/libxml2
    )
    set(libxml2_dep libxml2)
endif()

# Build LLVM
ExternalProject_Add(llvm
    SOURCE_DIR ${llvm_source_dir}
    INSTALL_DIR ${CMAKE_BINARY_DIR}/install/llvm
    DOWNLOAD_COMMAND ""
    SOURCE_SUBDIR llvm
    DEPENDS ${zlib_dep} ${libxml2_dep}
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS
        -C ${CMAKE_SOURCE_DIR}/caches/llvm.cmake
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_HOST_SYSTEM_PROCESSOR}
        ${zlib_flag}
        ${libxml2_flag}
)

ExternalProject_Get_Property(llvm INSTALL_DIR)
set(llvm_dir ${INSTALL_DIR})

# Create LLVM package
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
