cmake_minimum_required(VERSION 3.24)
project(devcontainer-test LANGUAGES ASM C CXX)

include(CTest)
include(GoogleTest)

add_subdirectory(clang-cl)
add_subdirectory(clang-tools)
add_subdirectory(fuzzing)
add_subdirectory(gcc)
add_subdirectory(gcc-arm-none-eabi)
add_subdirectory(sanitizers)
add_subdirectory(test)
