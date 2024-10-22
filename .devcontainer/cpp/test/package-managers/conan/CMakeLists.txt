# Seperate project as Conan is in the drivers seat

cmake_minimum_required(VERSION 3.30)
project(conan-test LANGUAGES CXX)

find_package(fmt REQUIRED)
add_executable(test-conan main.cpp)
target_link_libraries(test-conan PRIVATE fmt::fmt)
