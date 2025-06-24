Feature: amp-devcontainer::compilation

  As a developer
  To generate working software
  Source code needs to be compiled successfully

  Rule: amp-devcontainer::compilation.host-target
    amp-devcontainer *SHALL* be able to compile valid source code into a working executable targeting the container host architecture.

    Compiling valid source code into working software, able to run on the host architecture,
    can be necessary in several scenarios; for example when:

    - the host is the deployment target
    - running tests on the host
    - building plug-ins, extensions, code generators, or other additional tools that need to run on the host

    @flavor:cpp
    Scenario: Compile valid source code into working software targeting the host architecture
      Given build configuration "gcc" is selected
      And build preset "gcc" is selected
      When the selected target is built
      Then the output should contain "Build finished with exit code 0"

  Rule: amp-devcontainer::compilation.arm-target
    amp-devcontainer *SHALL* be able to compile valid source-code into a working ELF executable targeting the ARM Cortex architecture.

    Compiling valid source-code into working ELF executables, able to run on the ARM Cortex architecture,
    is a primary function for amp-devcontainer. It enables building firmware for micro-controllers based
    on the ARM Cortex architecture.

  Rule: amp-devcontainer::compilation.windows-target
    amp-devcontainer *SHALL* be able to compile valid source-code into a working executable targeting the Microsoft® Windows operating system.

    Compiling valid source-code into working executables, able to run on the Microsoft® Windows operating system, can be necessary in several scenarios e.g.

    - Cross platform code is written and needs to be compiled and deployed
    - Executables needs to be deployed outside of container context to a host running the Microsoft® Windows operating system

  Rule: amp-devcontainer::compilation.cache
    amp-devcontainer *SHOULD* be able to cache the results of a compilation to speed-up subsequent compilations.

    Maintaining a compilation cache can be useful in both local and ci development scenarios. A compilation cache can provide benefits like

    - Reduce developer waiting time and context switches, [maintaining flow-state](https://azure.microsoft.com/en-us/blog/quantifying-the-impact-of-developer-experience/)
    - Reduce CPU usage at the cost of more storage usage, potentially reducing energy consumption and cost for metered ci-systems
