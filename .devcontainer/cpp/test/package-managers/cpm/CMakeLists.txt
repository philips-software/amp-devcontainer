if (ENABLE_CPM_TEST)
    include(CPM)

    CPMAddPackage("gh:fmtlib/fmt#11.0.2")

    add_executable(test-cpm EXCLUDE_FROM_ALL main.cpp)
    target_link_libraries(test-cpm PRIVATE fmt::fmt)
endif()
