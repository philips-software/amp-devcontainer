add_executable(test-clang-tidy EXCLUDE_FROM_ALL main.cpp)
set_property(TARGET test-clang-tidy PROPERTY CXX_CLANG_TIDY clang-tidy -checks=-*,modernize*)

add_executable(test-clang-iwyu EXCLUDE_FROM_ALL main.cpp)
set_property(TARGET test-clang-iwyu PROPERTY CXX_INCLUDE_WHAT_YOU_USE iwyu)

add_executable(test-clang-uml EXCLUDE_FROM_ALL clang-uml-class.cpp)
set_property(TARGET test-clang-uml PROPERTY CXX_INCLUDE_WHAT_YOU_USE iwyu)
