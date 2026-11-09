<!-- markdownlint-disable MD041 -->

### :clipboard: Summary

<!-- Manually fill this summary, taking note of any changes relevant to the end user.
     When a change requires action, or emphasis, use '> [!NOTE]' notation.
-->

#### :ice_cream: Image flavors

|    Flavor     | Full identifier                                                                                                                                                                           |
|:-------------:|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     base      | <pre><code>ghcr.io/philips-software/amp-devcontainer-base:{{ image.amp-devcontainer-base.version }}@{{ image.amp-devcontainer-base.digest }}</code></pre><tr/>                            |
|      cpp      | <pre><code>ghcr.io/philips-software/amp-devcontainer-cpp:{{ image.amp-devcontainer-cpp.version }}@{{ image.amp-devcontainer-cpp.digest }}</code></pre><tr/>                               |
|     docs      | <pre><code>ghcr.io/philips-software/amp-devcontainer-docs:{{ image.amp-devcontainer-docs.version }}@{{ image.amp-devcontainer-docs.digest }}</code></pre><tr/>                            |
| embedded-cpp  | <pre><code>ghcr.io/philips-software/amp-devcontainer-embedded-cpp:{{ image.amp-devcontainer-embedded-cpp.version }}@{{ image.amp-devcontainer-embedded-cpp.digest }}</code></pre><tr/>    |
| embedded-rust | <pre><code>ghcr.io/philips-software/amp-devcontainer-embedded-rust:{{ image.amp-devcontainer-embedded-rust.version }}@{{ image.amp-devcontainer-embedded-rust.digest }}</code></pre><tr/> |
|     rust      | <pre><code>ghcr.io/philips-software/amp-devcontainer-rust:{{ image.amp-devcontainer-rust.version }}@{{ image.amp-devcontainer-rust.digest }}</code></pre>                                 |

#### :hammer_and_wrench: Included tools

The tables below list the most relevant packages per flavor, their versions from the image's Software Bill of Materials (SBOM), and the commands or library files checked by the integration tests.

<details>
<summary>amp-devcontainer-base</summary>

{{ image.amp-devcontainer-base.tools }}

</details>

<details>
<summary>amp-devcontainer-cpp</summary>

{{ image.amp-devcontainer-cpp.tools }}

</details>

<details>
<summary>amp-devcontainer-docs</summary>

{{ image.amp-devcontainer-docs.tools }}

</details>

<details>
<summary>amp-devcontainer-embedded-cpp</summary>

{{ image.amp-devcontainer-embedded-cpp.tools }}

</details>

<details>
<summary>amp-devcontainer-embedded-rust</summary>

{{ image.amp-devcontainer-embedded-rust.tools }}

</details>

<details>
<summary>amp-devcontainer-rust</summary>

{{ image.amp-devcontainer-rust.tools }}

</details>
