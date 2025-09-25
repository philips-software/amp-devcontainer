Feature: Compatibility

  As a software craftsperson
  to ensure that my development environment works well with a variety of tools and systems
  I want my development environment to be compatible with commonly used tools and systems

  Rule: Host architecture
    amp-devcontainer *SHALL* be compatible with both the x86-64 (AMD64) *and* AArch64 (ARM64) host architectures.

    Supporting both x86-64 and AArch64 has several advantages:

    - Increasing useability on a wide range of host machines, from PC hardware using the x86-64 architecture to Apple Silicon using the AArch64 architecture
    - Unlocking the power efficiency of the AArch64 architecture, potentially reducing energy consumption and cost for metered ci-systems

  Rule: Open Container Initiative (OCI) Image Specification
    amp-devcontainer images *SHALL* be compatible with the [OCI image specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)

    To guarantee compatibility with container runtimes and container- and image tooling; amp-devcontainer should be compatible with the OCI image specification.

  Rule: Integrated Development Environment
    amp-devcontainer *SHALL* be compatible with [VS Code](https://code.visualstudio.com/) *and* [GitHub Codespaces](https://github.com/features/codespaces).

    It should be possible to use amp-devcontainer and all of its features in both VS Code and GitHub Codespaces with minimal effort.
    Where minimal effort means: with the least amount of additional set-up, user intervention or configuration for all functionality that is provided by amp-devcontainer.
    Features and functions should work "out-of-the-box" without being overly opinionated.
