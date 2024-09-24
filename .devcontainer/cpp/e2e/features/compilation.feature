Feature: Compile source code into working software

  As a developer
  In order to generate working software
  Source code needs to be compiled successfully

  Scenario: Compile valid source code into working software targeting the host architecture

    Compiling valid source code into working software, able to run on the host architecture, can be necessary in several scenarios e.g.

    * When the host is the target
    * When running tests on the host
    * When building plug-ins, extensions, code generators, or other additional tools that need to run on the host

    Given the default build configuration is selected
    When the configuration "host" is built
    Then the output should contain "Build finished with exit code 0"
