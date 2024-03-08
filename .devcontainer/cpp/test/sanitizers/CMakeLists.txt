add_executable(test-asan EXCLUDE_FROM_ALL asan.cpp)
target_compile_options(test-asan PRIVATE -fsanitize=address -fno-omit-frame-pointer)
target_link_options(test-asan PRIVATE -fsanitize=address)

add_executable(test-threadsan EXCLUDE_FROM_ALL threadsan.cpp)
target_compile_options(test-threadsan PRIVATE -fsanitize=thread -fno-omit-frame-pointer)
target_link_options(test-threadsan PRIVATE -fsanitize=thread)

add_executable(test-ubsan EXCLUDE_FROM_ALL ubsan.cpp)
target_compile_options(test-ubsan PRIVATE -fsanitize=undefined -fno-omit-frame-pointer)
target_link_options(test-ubsan PRIVATE -fsanitize=undefined)

add_executable(test-memsan EXCLUDE_FROM_ALL memsan.cpp)
target_compile_options(test-memsan PRIVATE -fsanitize=memory -fno-omit-frame-pointer)
target_link_options(test-memsan PRIVATE -fsanitize=memory)
