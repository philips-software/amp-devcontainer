Feature: Compilation

  Rule: Compile for container host architecture and operating system
    @flavor:cpp
    Scenario: Compile valid source code into working software targeting the container host architecture
      Given build configuration "gcc" is selected
      And build preset "gcc" is selected
      When the selected target is built
      Then the output should contain "Build finished with exit code 0"
