Feature: Compilation
  # @sbdl-begin
    compilation is aspect {
      custom:title is "[@-LINE]"
      description is
      "As a software developer,
       to generate a working product, when using compiled languages,
       source code needs to be compiled into working software."
    }

    using { aspect is compilation }
  # @sbdl-end

  Rule: Compile for container host architecture and operating system
    # @sbdl-begin
      req-comp-0001 is requirement {
        custom:title is "[@-LINE]"
        description is
        "amp-devcontainer *SHALL* be able to compile valid source code into a
         working executable targeting the container host architecture and operating system."
        remark is
        "Compiling valid source code into working software, able to run on the container host
         architecture and operating system, can be necessary in several scenarios; for example when:\n\n

         - the container host is the deployment target\n
         - running tests on the container host\n
         - building plug-ins, extensions, code generators, or other additional tools that need to
           run on the container host"
      }
    # @sbdl-end

    @flavor:cpp
    Scenario: Compile valid source code into working software targeting the container host architecture
      Given build configuration "gcc" is selected
      And build preset "gcc" is selected
      When the selected target is built
      Then the output should contain "Build finished with exit code 0"

  Rule: Compile for ARM Cortex target architecture
    # @sbdl-begin
      req-comp-0002 is requirement {
        custom:title is "[@-LINE]"
        description is
        "amp-devcontainer *SHOULD* be able to compile valid source-code into a working ELF
         executable targeting the ARM Cortex architecture."
        remark is
        "Compiling valid source-code into working ELF executables, able to run on the ARM Cortex
         architecture, is a primary function for amp-devcontainer. It enables building firmware for
         micro-controllers based on the ARM Cortex architecture."
      }
    # @sbdl-end

  Rule: Compile for Microsoft® Windows operating system
    # @sbdl-begin
      req-comp-0003 is requirement {
        custom:title is "[@-LINE]"
        description is
        "amp-devcontainer *SHOULD* be able to compile valid source-code into a working executable
        targeting the Microsoft® Windows operating system."
        remark is
        "Compiling valid source-code into working executables, able to run on the Microsoft® Windows
         operating system, can be necessary in several scenarios e.g.\n\n

         - Cross platform code is written and needs to be compiled and deployed\n
         - Executables needs to be deployed outside of container context to a host running the
           Microsoft® Windows operating system"
      }
    # @sbdl-end

  Rule: Compilation cache
    # @sbdl-begin
      req-comp-0004 is requirement {
        custom:title is "[@-LINE]"
        description is
        "amp-devcontainer *MAY* be able to cache the results of a compilation to speed-up subsequent
         compilations."
        remark is
        "Maintaining a compilation cache can be useful in both local and ci development scenarios.
         A compilation cache can provide benefits like:\n\n

         - Reduce developer waiting time and context switches,
           [maintaining flow-state](https://azure.microsoft.com/en-us/blog/quantifying-the-impact-of-developer-experience/)\n
         - Reduce CPU usage at the cost of more storage usage, potentially reducing energy
           consumption and cost for metered ci-systems"
      }
    # @sbdl-end
