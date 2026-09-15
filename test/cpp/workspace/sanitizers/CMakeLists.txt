set(NO_OMIT_FRAME_POINTER $<IF:$<CXX_COMPILER_FRONTEND_VARIANT:MSVC>,/Oy-,-fno-omit-frame-pointer>)

add_executable(test-asan EXCLUDE_FROM_ALL asan.cpp)
target_compile_options(test-asan PRIVATE -fsanitize=address ${NO_OMIT_FRAME_POINTER})
target_link_options(test-asan PRIVATE -fsanitize=address)

add_executable(test-threadsan EXCLUDE_FROM_ALL threadsan.cpp)
target_compile_options(test-threadsan PRIVATE -fsanitize=thread ${NO_OMIT_FRAME_POINTER})
target_link_options(test-threadsan PRIVATE -fsanitize=thread)

add_executable(test-ubsan EXCLUDE_FROM_ALL ubsan.cpp)
target_compile_options(test-ubsan PRIVATE -fsanitize=undefined ${NO_OMIT_FRAME_POINTER})
target_link_options(test-ubsan PRIVATE -fsanitize=undefined)

add_executable(test-memsan EXCLUDE_FROM_ALL memsan.cpp)
target_compile_options(test-memsan PRIVATE -fsanitize=memory ${NO_OMIT_FRAME_POINTER})
target_link_options(test-memsan PRIVATE -fsanitize=memory)

set_target_properties(test-asan test-threadsan test-ubsan test-memsan
    PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
