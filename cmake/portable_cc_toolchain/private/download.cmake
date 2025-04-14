include("${CMAKE_CURRENT_LIST_DIR}/assets.cmake")

function(find_root_binary_dir root_binary_dir)
  set(current_dir "${CMAKE_BINARY_DIR}")

  while(1)
    if(EXISTS "${current_dir}/_portable_cc_toolchain")
      set("${root_binary_dir}" "${current_dir}" PARENT_SCOPE)
      return()
    endif()

    get_filename_component(parent_dir "${current_dir}" DIRECTORY)
    if("${parent_dir}" STREQUAL "${current_dir}")
      # We are the root project, or it simply couldn't find the directory
      set("${root_binary_dir}" "${CMAKE_BINARY_DIR}" PARENT_SCOPE)
      return()
    endif()
    set(current_dir "${parent_dir}")
  endwhile()
endfunction()

find_root_binary_dir(_root_binary_dir)

function(download location asset)
    set(_url "${_ASSET_URL_${asset}}")
    set(_sha "${_ASSET_SHA256_${asset}}")
    set(_dir "${_root_binary_dir}/_portable_cc_toolchain/${asset}-${_sha}")
    set(_out "${_root_binary_dir}/_portable_cc_toolchain/${asset}")

    if(NOT EXISTS "${_dir}")
        message("Downloading ${asset}...")
        file(DOWNLOAD "${_url}" "${_dir}.tar.xz" EXPECTED_HASH "SHA256=${_sha}")
        file(MAKE_DIRECTORY ${_dir})
        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf "${_dir}.tar.xz" WORKING_DIRECTORY "${_dir}" OUTPUT_QUIET)
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${_dir}" "${_out}")
    set("${location}" "${_out}" PARENT_SCOPE)
endfunction()
