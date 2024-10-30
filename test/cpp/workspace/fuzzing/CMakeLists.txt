add_executable(test-fuzzing EXCLUDE_FROM_ALL main.cpp)

target_compile_options(test-fuzzing PRIVATE -g -O1 -fsanitize=address,fuzzer)
target_link_options(test-fuzzing PRIVATE -fsanitize=address,fuzzer)
