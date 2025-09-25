Feature: Debugging

  As a software craftsperson
  to efficiently identify and resolve issues in my code
  I want to be able to debug my source code within the development environment

  Rule: Debugging support
    amp-devcontainer *SHALL* provide debugging support for the primary programming languages used within the container.

    Providing debugging support within the development environment enhances the developer experience and productivity.
    It allows developers to efficiently identify and resolve issues in their code by setting breakpoints, inspecting variables, and stepping through code execution.
    This capability is essential for diagnosing complex problems, understanding code flow, and ensuring the correctness of software.
    By having integrated debugging tools, developers can streamline their workflow and reduce the time spent on troubleshooting and fixing bugs.

  @flavor:cpp @fixme
  Scenario: Debug a simple C++ program
    Given the file "debugging/main.cpp" is opened in the editor
    When a breakpoint is set on line 5 of "debugging/main.cpp"
    And the debugger is started
    Then the debugger should stop at line 5 of "debugging/main.cpp"
    When the debugger is continued
    Then the program output should be "Hello, Debugging!"
