cmake_minimum_required(VERSION 3.30)

include(CPM)

project(devcontainer-test "NONE")

CPMAddPackage("gh:neonsoftware/cmake-bats#05e53f68976fcee935a40643b30f31e250bc5a9c")

enable_testing()
bats_discover_tests("${CMAKE_CURRENT_SOURCE_DIR}/test/$ENV{CONTAINER_FLAVOR}/integration-tests.bats")
