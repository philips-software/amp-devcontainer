add_executable(test-gcc EXCLUDE_FROM_ALL main.cpp)
add_executable(test-gcc-fail EXCLUDE_FROM_ALL main-fail.cpp)
add_executable(test-gcc-lld EXCLUDE_FROM_ALL main.cpp)
target_link_options(test-gcc-lld PRIVATE -fuse-ld=lld)
