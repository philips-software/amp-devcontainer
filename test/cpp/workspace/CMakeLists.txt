cmake_minimum_required(VERSION 3.30)
project(devcontainer-test LANGUAGES ASM C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_SCAN_FOR_MODULES Off)

include(CTest)
include(GoogleTest)

add_subdirectory(clang-cl)
add_subdirectory(clang-tools)
add_subdirectory(fuzzing)
add_subdirectory(gcc)
add_subdirectory(gcc-arm-none-eabi)
add_subdirectory(package-managers)
add_subdirectory(sanitizers)
add_subdirectory(test)
