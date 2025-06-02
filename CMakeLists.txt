cmake_minimum_required(VERSION 3.30)

include(CPM)

project(devcontainer-test "NONE")

CPMAddPackage("gh:neonsoftware/cmake-bats#53562f5a9be517944fb8a2df3ea80f81f17e070c")

enable_testing()
bats_discover_tests("${CMAKE_CURRENT_SOURCE_DIR}/test/$ENV{CONTAINER_FLAVOR}/integration-tests.bats")
