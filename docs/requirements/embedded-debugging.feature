Feature: Debugging
  # @sbdl-begin
    using { aspect is debugging }
  # @sbdl-end

  Rule: Upload firmware to micro-controller
    # @sbdl-begin
      req-debug-0002 is requirement {
        custom:title is "[@-LINE]"
        description is
        "amp-devcontainer *MAY* provide tools to upload compiled firmware to a connected
         micro-controller."
        remark is
        "Providing tools to upload compiled firmware to a connected micro-controller enhances the
         development workflow for embedded systems. It allows developers to quickly and easily
         transfer their compiled code to the target hardware for testing and debugging. This
         capability is essential for validating the functionality of the firmware on the actual
         device, ensuring that it behaves as expected in real-world scenarios. By having integrated
         tools for firmware upload, developers can streamline their workflow, reduce manual steps,
         and improve overall productivity when working with micro-controllers."
      }
    # @sbdl-end
