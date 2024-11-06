Feature: Compile source code into working software

  As a developer
  To generate working software
  Source code needs to be compiled successfully

  Scenario: Compile valid source code into working software targeting the host architecture

    Compiling valid source code into working software, able to run on the host architecture,
    can be necessary in several scenarios; for example when:

    - the host is the deployment target
    - running tests on the host
    - building plug-ins, extensions, code generators, or other additional tools that need to run on the host

    Given build configuration "gcc" is selected
    And build preset "gcc" is selected
    When the selected target is built
    Then the output should contain "Build finished with exit code 0"
