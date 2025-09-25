Feature: Static and dynamic analysis

  As a software craftsperson
  to maintain consistent, high-quality and bug-free code
  I want my source code to be statically and dynamically analyzed

  @flavor:cpp @fixme
  Scenario: Format source code according to a formatting style
    Given the file "clang-tools/unformatted.cpp" is opened in the editor
    When the active document is formatted
    And the active document is saved
    Then the contents of "clang-tools/unformatted.cpp" should match the contents of "clang-tools/formatted.cpp"
