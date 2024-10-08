Feature: Analyze source code using static and dynamic analysis

  As a software craftsman
  To maintain consistent, high-quality and bug-free code
  Source code needs to be statically and dynamically analyzed

  Scenario: Format source code according to a formatting style

    Given the file "unformatted.cpp" is opened in the editor
    When the active document is formatted
    And the active document is saved
    Then the contents of "unformatted.cpp" should match the contents of "formatted.cpp"
