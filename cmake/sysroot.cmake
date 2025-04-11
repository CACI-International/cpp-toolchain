include("${CMAKE_CURRENT_LIST_DIR}/assets.cmake")

if(${TARGET_TRIPLE} MATCHES linux)
    set(_assets_dir "${CMAKE_BINARY_DIR}/_portable_cc_toolchain/assets")
    set(_sysroot_dir "${CMAKE_BINARY_DIR}/_portable_cc_toolchain/sysroot")
    
    file(DOWNLOAD "${_ASSETS_URL_sysroot-${TARGET_TRIPLE}}" "${_assets_dir}/sysroot.tar.xz" SHOW_PROGRESS EXPECTED_HASH "SHA256=${_ASSETS_SHA256_sysroot-${_host_triple}}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf "${_assets_dir}/sysroot.tar.xz" WORKING_DIRECTORY "${_sysroot_dir}")
endif()
