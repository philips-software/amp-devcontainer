Feature: Debugging
  # @sbdl-begin
    debugging is aspect {
      custom:title is "[@-LINE]"
      description is
      "As a software craftsperson,
       to efficiently identify and resolve issues in my code,
       I want to be able to debug my source code within the development environment."
    }

    using { aspect is debugging }
  # @sbdl-end

  Rule: Debugging support
    # @sbdl-begin
      req-debug-0001 is requirement {
        custom:title is "[@-LINE]"
        description is
        "amp-devcontainer *SHALL* provide debugging support for the primary programming language(s)
         used within the container."
        remark is
        "Providing debugging support within the development environment enhances the developer
         experience and productivity. It allows developers to efficiently identify and resolve
         issues in their code by setting breakpoints, inspecting variables, and stepping through
         code execution. This capability is essential for diagnosing complex problems, understanding
         code flow, and ensuring the correctness of software. By having integrated debugging tools,
         developers can streamline their workflow and reduce the time spent on troubleshooting and
         fixing bugs."
      }
    # @sbdl-end
