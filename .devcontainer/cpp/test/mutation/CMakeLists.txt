option(ENABLE_MUTATION_TESTING_TEST Off)

if (ENABLE_MUTATION_TESTING_TEST)
    include(FetchContent)

    FetchContent_Declare(googletest
        GIT_REPOSITORY https://github.com/google/googletest
        GIT_TAG release-1.12.1
    )

    FetchContent_MakeAvailable(googletest)

    add_executable(test-mutation EXCLUDE_FROM_ALL test.cpp)
    target_compile_options(test-mutation PRIVATE
        -g -O0 -grecord-command-line -fprofile-instr-generate -fcoverage-mapping -fpass-plugin=/usr/lib/mull-ir-frontend
    )
    target_link_libraries(test-mutation PRIVATE gmock_main)
    add_test(NAME test-mutation COMMAND mull-runner $<TARGET_FILE:test-mutation>)
endif()
