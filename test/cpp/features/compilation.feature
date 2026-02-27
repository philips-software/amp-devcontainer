Feature: Compilation
  # @sbdl compilation is aspect { description is "As a software developer, source code needs to be compiled into working software." }

  As a software developer,
  to generate a working product, when using compiled languages,
  source code needs to be compiled into working software.

  @REQ-COMP-0001
  Rule: Compile for container host architecture and operating system
    # @sbdl req-comp-0001 is requirement { description is "amp-devcontainer *SHALL* be able to compile valid source code into a working executable targeting the container host architecture and operating system." aspect is compilation }
    amp-devcontainer *SHALL* be able to compile valid source code into a working executable targeting the container host architecture and operating system.

    Compiling valid source code into working software, able to run on the container host architecture and operating system,
    can be necessary in several scenarios; for example when:

    - the container host is the deployment target
    - running tests on the container host
    - building plug-ins, extensions, code generators, or other additional tools that need to run on the container host

    @flavor:cpp
    Scenario: Compile valid source code into working software targeting the container host architecture
      # @sbdl compile-valid-source-code-into-working-software-targeting-the-container-host-architecture is test { description is "Compile valid source code into working software targeting the container host architecture" requirement is req-comp-0001 }
      Given build configuration "gcc" is selected
      And build preset "gcc" is selected
      When the selected target is built
      Then the output should contain "Build finished with exit code 0"

  @REQ-COMP-0002
  Rule: Compile for ARM Cortex target architecture
    # @sbdl req-comp-0002 is requirement { description is "amp-devcontainer *SHOULD* be able to compile valid source-code into a working ELF executable targeting the ARM Cortex architecture." aspect is compilation }
    amp-devcontainer *SHOULD* be able to compile valid source-code into a working ELF executable targeting the ARM Cortex architecture.

    Compiling valid source-code into working ELF executables, able to run on the ARM Cortex architecture,
    is a primary function for amp-devcontainer. It enables building firmware for micro-controllers based
    on the ARM Cortex architecture.

  @REQ-COMP-0003
  Rule: Compile for Microsoft® Windows operating system
    # @sbdl req-comp-0003 is requirement { description is "amp-devcontainer *SHOULD* be able to compile valid source-code into a working executable targeting the Microsoft® Windows operating system." aspect is compilation }
    amp-devcontainer *SHOULD* be able to compile valid source-code into a working executable targeting the Microsoft® Windows operating system.

    Compiling valid source-code into working executables, able to run on the Microsoft® Windows operating system, can be necessary in several scenarios e.g.

    - Cross platform code is written and needs to be compiled and deployed
    - Executables needs to be deployed outside of container context to a host running the Microsoft® Windows operating system

  @REQ-COMP-0004
  Rule: Compilation cache
    # @sbdl req-comp-0004 is requirement { description is "amp-devcontainer *MAY* be able to cache the results of a compilation to speed-up subsequent compilations." aspect is compilation }
    amp-devcontainer *MAY* be able to cache the results of a compilation to speed-up subsequent compilations.

    Maintaining a compilation cache can be useful in both local and ci development scenarios. A compilation cache can provide benefits like:

    - Reduce developer waiting time and context switches, [maintaining flow-state](https://azure.microsoft.com/en-us/blog/quantifying-the-impact-of-developer-experience/)
    - Reduce CPU usage at the cost of more storage usage, potentially reducing energy consumption and cost for metered ci-systems
