# Settings for the runtimes sub-builds (see llvm-linux.cmake)

set(LLVM_ENABLE_PER_TARGET_RUNTIME_DIR  ON  CACHE BOOL "")
set(LLVM_INCLUDE_DOCS                   OFF CACHE BOOL "")

set(LLVM_STATIC_LINK_CXX_STDLIB         ON  CACHE BOOL "")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE   "-static-libgcc" CACHE STRING "")

set(CMAKE_BUILD_WITH_INSTALL_RPATH      ON  CACHE BOOL "")

# compiler-rt
set(COMPILER_RT_DEFAULT_TARGET_ONLY     ON  CACHE BOOL "")
set(COMPILER_RT_USE_LIBCXX              OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_GWP_ASAN          OFF CACHE BOOL "") # Workaround for https://github.com/llvm/llvm-project/issues/57717
set(COMPILER_RT_ASAN_ENABLE_EXCEPTIONS  OFF CACHE BOOL "") # armv7 libstdc++.so doesn't export __gxx_personality_v0

# openmp
set(LIBOMP_CXXFLAGS "-fvisibility=hidden" CACHE STRING "") # libomp is static; don't re-export its symbols from shared libraries
set(LIBOMP_ENABLE_SHARED                OFF CACHE BOOL "")
set(LIBOMP_INSTALL_ALIASES              OFF CACHE BOOL "") # symlinks don't extract well on Windows
set(LIBOMP_OMPD_GDB_SUPPORT             OFF CACHE BOOL "") # requires python
set(OPENMP_ENABLE_LIBOMPTARGET          OFF CACHE BOOL "")
