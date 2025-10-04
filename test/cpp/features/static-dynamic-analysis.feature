Feature: Static and dynamic analysis

  As a software craftsperson,
  to maintain consistent, high-quality and bug-free code,
  I want my source code to be statically and dynamically analyzed.

  Rule: Code formatting
    amp-devcontainer *MAY* provide code formatting tools for the primary programming language(s) used within the container.

    Providing code formatting tools helps maintain a consistent coding style across the codebase, improving readability and reducing friction during code reviews.
    It also helps catch potential issues early by enforcing coding standards and best practices.
    By integrating code formatting tools into the development environment, developers can easily format their code according to predefined rules, ensuring that the code adheres to the project's style guidelines.

  @flavor:cpp @fixme
  Scenario: Format source code according to a formatting style
    Given the file "clang-tools/unformatted.cpp" is opened in the editor
    When the active document is formatted
    And the active document is saved
    Then the contents of "clang-tools/unformatted.cpp" should match the contents of "clang-tools/formatted.cpp"

  Rule: Static analysis
    amp-devcontainer *MAY* provide static analysis tools for the primary programming language(s) used within the container.

    Providing static analysis tools helps identify potential issues in the code before it is executed, improving code quality and reducing the likelihood of runtime errors.
    These tools can analyze the code for common pitfalls, coding standards violations, and potential bugs, providing developers with valuable feedback early in the development process.
    By integrating static analysis tools into the development environment, developers can catch issues before they become more significant problems, streamlining the development workflow and improving overall code quality.

  Rule: Coverage analysis
    amp-devcontainer *SHOULD* provide code coverage analysis tools for the primary programming language(s) used within the container.

    Providing code coverage analysis tools helps assess the effectiveness of the existing test suite by measuring how much of the code is exercised by the tests.
    This information can help identify gaps in test coverage, ensuring that critical parts of the code are adequately tested.
    By integrating code coverage analysis tools into the development environment, developers can improve their test suites, leading to higher code quality and increased confidence in the software's correctness.

  Rule: Mutation testing
    amp-devcontainer *MAY* provide mutation testing tools for the primary programming language(s) used within the container.

    Providing mutation testing tools helps assess the effectiveness of the existing test suite by introducing small changes (mutations) to the code and checking if the tests can detect these changes.
    This process helps identify gaps in test coverage and ensures that the tests are robust enough to catch potential issues in the code.
    By integrating mutation testing tools into the development environment, developers can improve their test suites, leading to higher code quality and increased confidence in the software's correctness.

  Rule: Fuzz testing
    amp-devcontainer *MAY* provide fuzz testing tools for the primary programming language(s) used within the container.

    Providing fuzz testing tools helps identify potential security vulnerabilities and robustness issues in the code by automatically generating and executing a large number of random inputs.
    This process can uncover edge cases and unexpected behaviors that may not be covered by traditional testing methods.
    By integrating fuzz testing tools into the development environment, developers can improve the overall security and reliability of their software, reducing the risk of vulnerabilities being exploited in production.
