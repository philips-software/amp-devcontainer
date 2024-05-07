option(ENABLE_COVERAGE_TEST Off)
option(ENABLE_MUTATION_TESTING_TEST Off)

include(FetchContent)

FetchContent_Declare(googletest
    GIT_REPOSITORY https://github.com/google/googletest
    GIT_TAG v1.14.0
)

if (ENABLE_COVERAGE_TEST)
    FetchContent_MakeAvailable(googletest)

    add_executable(test-coverage EXCLUDE_FROM_ALL test.cpp)
    target_compile_options(test-coverage PRIVATE
        -g -O0 --coverage -fprofile-arcs -ftest-coverage -fno-inline
    )
    target_link_libraries(test-coverage PRIVATE gmock_main gcov)
    add_test(NAME test-coverage COMMAND test-coverage)
endif()

if (ENABLE_MUTATION_TESTING_TEST)
    FetchContent_MakeAvailable(googletest)

    add_executable(test-mutation EXCLUDE_FROM_ALL test.cpp)
    target_compile_options(test-mutation PRIVATE
        -g -O0 -grecord-command-line -fprofile-instr-generate -fcoverage-mapping -fpass-plugin=/usr/lib/mull-ir-frontend
    )
    target_link_libraries(test-mutation PRIVATE gmock_main)
    add_test(NAME test-mutation COMMAND mull-runner $<TARGET_FILE:test-mutation>)
endif()
