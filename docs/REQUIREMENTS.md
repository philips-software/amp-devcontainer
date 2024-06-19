# amp-devcontainer requirement specification

## Introduction

### Purpose

This document describes the software system requirements for amp-devcontainer.
<!--- @sbdl requirement_specification is definition { [@DFP] }
     @sbdl using { definition is requirement_specification }
-->

### Definitions of key words

The key words *MUST*, *MUST NOT*, *REQUIRED*, *SHALL*, *SHALL NOT*, *SHOULD*, *SHOULD NOT*, *RECOMMENDED*, *MAY*, and *OPTIONAL* in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

### Abstract

amp-devcontainer is a set of [devcontainers](https://containers.dev/) tailored towards modern, embedded, software development.
<!--- @sbdl amp_devcontainer is aspect { [@DFP] }
      @sbdl using { aspect is amp_devcontainer }
-->

The containers may be used both for local development and continuous integration (ci).
<!--- @sbdl local_development is usecase { description is "amp-devcontainer may be used for local development"; actor is "developer" }
      @sbdl continuous_integration is usecase { description is "amp-devcontainer may be used for continuous integration"; actor is "continuous integration system" }
-->

### Terminology and Abbreviations

| Terminology and Abbreviations | Description/Definition                                                                                                                 |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| ARM                           | A family of RISC architectures for computer processors and micro controllers, formerly an acronym for Advanced RISC Machines and originally Acorn RISC Machine |
| Continuous Integration (ci)   | The practice of continuously merging developers work to a shared code-base; ideally including automation for build, test and deployment |
| ELF                           | Executable and Linkable Format, formerly named Extensible Linking Format |
| RISC                          | Reduced Instruction Set Computer |

## Requirements

This chapter describes the requirements for amp-devcontainer.

### Compilation Requirements

This chapter describes requirements pertaining to efficient and effective compilation of source-code into working executables.

#### Host Compilation

amp-devcontainer *SHALL* be able to compile valid source-code into a working executable targeting the container host architecture.
<!-- @sbdl host_compilation is requirement { [@DFP] }
-->
Compiling valid source-code into working executables, able to run inside the container, can be necessary in several scenarios e.g.
  - When running tests inside the container
  - When building plug-ins, extensions, code generators, or other additional tools that need to run inside the container

#### ARM Cross Compilation

amp-devcontainer *SHALL* be able to compile valid source-code into a working ELF executable targeting the ARM Cortex architecture.
<!-- @sbdl arm_cross_compilation is requirement { [@DFP] }
-->
Compiling valid source-code into working ELF executables, able to run on the ARM Cortex architecture, is a primary function for amp-devcontainer. It enables building firmware for micro-controllers based on the ARM Cortex architecture.

#### Windows Host Cross Compilation

amp-devcontainer *SHALL* be able to compile valid source-code into a working executable targeting the Windows operating system.
<!-- @sbdl windows_host_cross_compilation is requirement { [@DFP] }
-->
Compiling valid source-code into working executables, able to run on the Windows operating system, can be necessary in several scenarios e.g.
  - Cross platform code is written and needs to be tested or deployed
  - Executables needs to be deployed outside of container context to a host running the Windows operating system

#### Compilation Cache

amp-devcontainer *SHALL* be able to cache the results of a compilation to speed-up subsequent compilations.
<!-- @sbdl compilation_cache is requirement { [@DFP] }
-->
Maintaining a compilation cache can be useful in both local and ci development scenarios. A compilation cache can provide benefits like
  - Reduce developer waiting time and context switches, [maintaining flow-state](https://azure.microsoft.com/en-us/blog/quantifying-the-impact-of-developer-experience/)
  - Reduce CPU usage at the cost of more storage usage, potentially reducing energy consumption and cost for metered ci-systems

### Debugging Requirements

### Static and Dynamic Analysis Requirements

### Security Requirements

This chapter describes requirements pertaining to security, and supply-chain security aspects of amp-devcontainer.

#### Build Provenance

amp-devcontainer *SHALL* include build provenance as specified in [SLSA v1.0 Build L2](https://slsa.dev/spec/v1.0/levels).
<!-- @sbdl build_provenance is requirement { [@DFP] }
-->
Including provenance gives confidence that the container images haven't been tampered with and can be securely traced back to its source.
The primary purpose is to enable [verification](https://slsa.dev/spec/v1.0/verifying-artifacts) that the container image was built as expected. Consumers have some way of knowing what the expected provenance should look like for a given container image and then compare each container image's actual provenance to those expectations. Doing so prevents several classes of [supply chain threats](https://slsa.dev/spec/v1.0/threats).

#### Signing

amp-devcontainer *SHALL* cryptographically sign its released container images.
<!-- @sbdl crytographically_sign is requirement { [@DFP] }
-->

#### Software Bill of Materials (SBOM)

amp-devcontainer *SHALL* include an SBOM including all software packages for every container image that is built.

Having an overview of all software packages included in a specific build of a container image helps in monitoring and detection of vulnerabilities.

#### Vulnerability Scanning

amp-devcontainer *SHALL* have vulnerability information for the latest released version of all containers.

### Compatibility Requirements

This chapter describes requirements pertaining to compatibility of amp-devcontainer with its run- and build-time environment.

#### Host Architecture

amp-devcontainer *SHALL* be compatible with both the x86-64 (AMD64) *and* AArch64 (ARM64) host architectures.

Supporting both x86-64 and AArch64 has several advantages:
  - Increasing useability on a wide range of host machines, from PC hardware using the x86-64 architecture to Apple Silicon using the AArch64 architecture
  - Unlocking the power efficiency of the AArch64 architecture, potentially reducing energy consumption and cost for metered ci-systems

#### Open Container Initiative (OCI) Image Specification

amp-devcontainer images *SHALL* be compatible with the [OCI image specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)

To guarantee compatibility with container runtimes and container- and image tooling; amp-devcontainer should be compatible with the latest version
of the OCI image specification.

#### Integrated Development Environment

amp-devcontainer *SHALL* be compatible with [VS Code](https://code.visualstudio.com/) *and* [GitHub Codespaces](https://github.com/features/codespaces).

It should be possible to use amp-devcontainer and all of its features in both VS Code and GitHub Codespaces with minimal effort.
Where minimal effort means: with the least amount of additional set-up, user intervention or configuration for all functionality that is provided by amp-devcontainer. Features and functions should work "out-of-the-box" without being overly opinionated.

### Maintainability
