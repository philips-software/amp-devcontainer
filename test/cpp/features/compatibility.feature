Feature: Compatibility
  # @sbdl compatibility is aspect { description is "As a software craftsperson, I want my development environment to be compatible with commonly used tools and systems." }

  As a software craftsperson,
  to ensure that my development environment works well with a variety of tools and systems,
  I want my development environment to be compatible with commonly used tools and systems.

  @REQ-COMPAT-0001
  Rule: Open Container Initiative (OCI) Image Specification
    # @sbdl req-compat-0001 is requirement { description is "amp-devcontainer images *SHALL* be compatible with the [OCI image specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)" aspect is compatibility }
    amp-devcontainer images *SHALL* be compatible with the [OCI image specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)

    To guarantee compatibility with container runtimes and container- and image tooling; amp-devcontainer should be compatible with the OCI image specification.

  @REQ-COMPAT-0002
  Rule: Host architecture
    # @sbdl req-compat-0002 is requirement { description is "amp-devcontainer *SHALL* be compatible with both the x86-64 (AMD64) *and* AArch64 (ARM64) host architectures." aspect is compatibility }
    amp-devcontainer *SHALL* be compatible with both the x86-64 (AMD64) *and* AArch64 (ARM64) host architectures.

    Supporting both x86-64 and AArch64 has several advantages:

    - Increasing useability on a wide range of host machines, from PC hardware using the x86-64 architecture to Apple Silicon using the AArch64 architecture
    - Unlocking the power efficiency of the AArch64 architecture, potentially reducing energy consumption and cost for metered ci-systems

  @REQ-COMPAT-0003
  Rule: Integrated Development Environment (IDE)
    # @sbdl req-compat-0003 is requirement { description is "amp-devcontainer *SHOULD* be compatible with [VS Code](https://code.visualstudio.com/) *and* [GitHub Codespaces](https://github.com/features/codespaces)." aspect is compatibility }
    amp-devcontainer *SHOULD* be compatible with [VS Code](https://code.visualstudio.com/) *and* [GitHub Codespaces](https://github.com/features/codespaces).

    It should be possible to use amp-devcontainer and all of its features in both VS Code and GitHub Codespaces with minimal effort.
    Where minimal effort means: with the least amount of additional set-up, user intervention or configuration for all functionality that is provided by amp-devcontainer.
    Features and functions should work "out-of-the-box" without being overly opinionated.

  @REQ-COMPAT-0004
  Rule: GitHub Actions
    # @sbdl req-compat-0004 is requirement { description is "amp-devcontainer *SHOULD* support seamless integration with [GitHub Actions](https://github.com/features/actions) without additional configuration." aspect is compatibility }
    amp-devcontainer *SHOULD* support seamless integration with [GitHub Actions](https://github.com/features/actions) without additional configuration.

    Seamless integration with GitHub Actions allows users to easily incorporate amp-devcontainer into their ci/cd workflows.
    This integration helps automate the build, test, and deployment processes, improving efficiency and reducing manual errors.
    By minimizing the need for additional configuration, users can quickly set up and start using amp-devcontainer in their GitHub Actions workflows, enhancing their overall development experience.
