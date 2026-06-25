Feature: Compilation
  # @sbdl-begin
    using { aspect is compilation }
  # @sbdl-end

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
