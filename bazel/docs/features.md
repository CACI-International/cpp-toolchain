# Features

| Feature | Target | Description |
| ------- | ------ | ----------- |
| `debug_symbols` | `//feature:debug_symbols` | Generage debug information |
| `hide_symbols` | `//feature:hide_symbols` | Set hidden symbol visibility |
| `strip_unused_dynamic_libs` | `//feature:strip_unused_dynamic_libs` | Don't link against dynamic libraries that aren't referenced by any symbols |
| `thinlto` | `//feature:thinlto` | Link with ThinLTO (incremental link time optimization) |
| `coverage` | `//feature:coverage` | Compile with instrumentation for code coverage |
| `no_optimization` | `//feature:no_optimization` | Disable all optimizations |
| `debug_optimization` | `//feature:debug_optimization` | Optimize for debugging |
| `size_optimization` | `//feature:size_optimization` | Optimize for smallest binary size |
| `moderate_optimization` | `//feature:moderate_optimization` | Enable standard optimizations |
| `max_optimization` | `//feature:max_optimization` | Enable maximum optimizations |
| `asan` | `//feature:asan` | Instrument with AddressSanitizer |
| `ubsan` | `//feature:ubsan` | Instrument with UndefinedBehaviorSanitizer |
| `lsan` | `//feature:lsan` | Instrument with LeakSanitizer |
| `default_sanitizers` | `//feature:default_sanitizers` | Instrument with the sanitizers supported by the default_linkage feature |
| `warnings_enabled` | `//feature:warnings_enabled` | Emit warnings |
| `warnings_disabled` | `//feature:warnings_disabled` | Disable warnings |
| `extra_warnings` | `//feature:extra_warnings` | Emit extra warnings |
| `pedantic_warnings` | `//feature:pedantic_warnings` | Emit pedantic warnings |
| `treat_warnings_as_errors` | `//feature:treat_warnings_as_errors` | Treat warnings as errors |
| `static_position_independent_executable` | `//feature:static_position_independent_executable` | Link static PIE executables |
| `default_linkage` | `//feature:default_linkage` | Default linkage for the platform: static PIE on musl, regular linkage elsewhere |
| `c89` | `//feature:c89` | Use C89 language standard |
| `c99` | `//feature:c99` | Use C99 language standard |
| `c11` | `//feature:c11` | Use C11 language standard |
| `c17` | `//feature:c17` | Use C17 language standard |
| `c23` | `//feature:c23` | Use C23 language standard |
| `c++98` | `//feature:cpp98` | Use C++98 language standard |
| `c++03` | `//feature:cpp03` | Use C++03 language standard |
| `c++11` | `//feature:cpp11` | Use C++11 language standard |
| `c++14` | `//feature:cpp14` | Use C++14 language standard |
| `c++17` | `//feature:cpp17` | Use C++17 language standard |
| `c++20` | `//feature:cpp20` | Use C++20 language standard |
| `c++23` | `//feature:cpp23` | Use C++23 language standard |
