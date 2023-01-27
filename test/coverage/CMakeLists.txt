option(ENABLE_COVERAGE_TEST Off)

if (ENABLE_COVERAGE_TEST)
    include(FetchContent)

    FetchContent_Declare(googletest
        GIT_REPOSITORY https://github.com/google/googletest
        GIT_TAG release-1.12.1
    )

    FetchContent_MakeAvailable(googletest)

    add_executable(test-coverage EXCLUDE_FROM_ALL test.cpp)
    target_compile_options(test-coverage PRIVATE
        -g -O0 --coverage -fprofile-arcs -ftest-coverage -fno-inline
    )
    target_link_libraries(test-coverage PRIVATE gmock_main gcov)
    add_test(NAME test-coverage COMMAND test-coverage)
endif()
