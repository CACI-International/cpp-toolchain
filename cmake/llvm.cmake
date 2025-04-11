if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
    set(_host_triple "${CMAKE_HOST_SYSTEM_PROCESSOR}-unknown-linux-gnu")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
    set(_host_triple "${CMAKE_HOST_SYSTEM_PROCESSOR}-apple-macos")
else()
    message(FATAL_ERROR "Unsupported host operating system: ${CMAKE_HOST_SYSTEM_NAME}")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/assets.cmake")

set(_assets_dir "${CMAKE_BINARY_DIR}/_portable_cc_toolchain/assets")
set(_llvm_dir "${CMAKE_BINARY_DIR}/_portable_cc_toolchain/llvm")

file(DOWNLOAD "${_ASSETS_URL_llvm-${_host_triple}}" "${_assets_dir}/llvm.tar.xz" SHOW_PROGRESS EXPECTED_HASH "SHA256=${_ASSETS_SHA256_llvm-${_host_triple}}")
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf "${_assets_dir}/llvm.tar.xz" WORKING_DIRECTORY "${_llvm_dir}")
