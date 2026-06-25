cmake_minimum_required(VERSION 3.30)
project(devcontainer-test LANGUAGES ASM C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_SCAN_FOR_MODULES Off)

add_subdirectory(gcc-arm-none-eabi)
