Feature: Debugging

  As a software craftsperson
  to efficiently identify and resolve issues in my code
  I want to be able to debug my source code within the development environment

  Rule: Debugging support
    amp-devcontainer *SHALL* provide debugging support for the primary programming language(s) used within the container.

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

  Rule: Upload firmware to micro-controller
    amp-devcontainer *MAY* provide tools to upload compiled firmware to a connected micro-controller.

    Providing tools to upload compiled firmware to a connected micro-controller enhances the development workflow for embedded systems.
    It allows developers to quickly and easily transfer their compiled code to the target hardware for testing and debugging.
    This capability is essential for validating the functionality of the firmware on the actual device, ensuring that it behaves as expected in real-world scenarios.
    By having integrated tools for firmware upload, developers can streamline their workflow, reduce manual steps, and improve overall productivity when working with micro-controllers.
