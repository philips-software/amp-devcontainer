if (ENABLE_CPM_TEST)
    include(CPM)

    CPMAddPackage("gh:fmtlib/fmt#11.0.2")

    add_executable(cpm-test EXCLUDE_FROM_ALL main.cpp)
    target_link_libraries(cpm-test PRIVATE fmt::fmt)
endif()
