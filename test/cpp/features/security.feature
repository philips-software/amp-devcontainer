Feature: Security

  As a security engineer and security conscious developer,
  to have control over the security posture of my development environment,
  I want to have controls in place to identify and mitigate supply-chain vulnerabilities.

  Rule: Build provenance
    amp-devcontainer *SHALL* include build provenance as specified in [SLSA v1.0 Build L3](https://slsa.dev/spec/v1.0/levels).

    Including provenance gives confidence that the container images haven't been tampered with and can be securely traced back to its source code.
    The primary purpose is to enable [verification](https://slsa.dev/spec/v1.0/verifying-artifacts) that the container image was built as expected.
    Consumers have some way of knowing what the expected provenance should look like for a given container image and then compare each container image's actual provenance to those expectations.
    Doing so prevents several classes of [supply chain threats](https://slsa.dev/spec/v1.0/threats).

  Rule: Signing
    amp-devcontainer *SHALL* cryptographically sign its released container images.

    Cryptographically signing released container images provides integrity and authenticity guarantees.
    It enables consumers to verify that the container image hasn't been tampered with and that it indeed originates from the expected publisher.
    This helps mitigate several classes of [supply chain threats](https://slsa.dev/spec/v1.0/threats).

  Rule: Software Bill of Materials (SBOM)
    amp-devcontainer *SHOULD* provide a Software Bill of Materials (SBOM) for its released container images.

    Providing a Software Bill of Materials (SBOM) enables consumers to identify and manage security risks associated with the software components included in the container images.
    It helps identify known vulnerabilities, license compliance issues, and potential supply chain risks.
