cmake_minimum_required(VERSION 3.30)

include(CPM)

project(devcontainer-test "NONE")

CPMAddPackage("gh:neonsoftware/cmake-bats@0.0.3")

enable_testing()
bats_discover_tests("${CMAKE_CURRENT_SOURCE_DIR}/test/$ENV{CONTAINER_FLAVOR}/integration-tests.bats")
