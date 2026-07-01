# Record Architecture Decisions Using MADR

* Status: accepted
* Deciders: Development Team
* Date: 2026-07-01

## Context and Problem Statement

The project makes architectural, process, and supply-chain decisions — such as how packages are pinned or how the threat model is expressed — whose rationale is easily lost over time. Commit messages and pull-request discussions are hard to discover after the fact, yet new contributors and auditors need to understand *why* a decision was made, not only *what* the code does.

The container's own maintainability requirement states that amp-devcontainer *SHOULD* document its architectural decisions (see [test/cpp/features/maintainability.feature](../../test/cpp/features/maintainability.feature)). The project therefore needs a lightweight, durable, and discoverable way to capture significant decisions together with their context and consequences.

## Decision Drivers

* **Traceability and auditability:** The container targets regulated domains (medical, automotive, aviation, railroad), where the rationale behind decisions must be reviewable.
* **Low friction:** Recording a decision should not require leaving the repository or learning heavyweight tooling.
* **Co-location and versioning:** Decisions should live and evolve alongside the code they concern and be reviewed through the normal pull-request process.
* **Durability:** The format should remain readable without special tools far into the future.

## Considered Options

* **No formal decision log:** Rely on commit messages, pull-request threads, and tribal knowledge.
* **External wiki or documentation tool:** Record decisions in a separate system, such as a wiki.
* **Markdown Architectural Decision Records (MADR):** Record each decision as a numbered Markdown file in `docs/adr/`, using the [MADR](https://adr.github.io/madr/) template.

## Decision Outcome

Chosen option: **Markdown Architectural Decision Records (MADR)**, because it satisfies every decision driver with the least overhead — decisions are captured as plain Markdown in the repository, reviewed through pull requests, and versioned with the code.

Architecture decisions are recorded as one Markdown file per decision under `docs/adr/`, named `NNNN-title-with-dashes.md` and numbered sequentially starting at `0000` (this record). Each record follows the MADR structure: context and problem statement, decision drivers, considered options, the decision outcome, and its consequences. Records are immutable once accepted; a decision that changes is captured in a new record, and the superseded record's status is updated to point to it.

### Positive Consequences

* **Preserved rationale:** The context and trade-offs behind each decision remain available to future contributors and auditors.
* **Co-versioned and reviewable:** Records live with the code and are reviewed like any other change, directly supporting the maintainability requirement.
* **Tooling-agnostic:** Plain Markdown requires no special software to read, write, or render.
* **Consistent and discoverable:** A single, numbered file gives every decision a predictable home.

### Negative Consequences

* **Requires discipline:** The team must remember to write a record when a significant decision is made.
* **Numbering upkeep:** Sequential numbering has to be maintained as records are added.

## Pros and Cons of the Options

### No formal decision log

* ✅ Good, because it requires no effort up front.
* ❌ Bad, because rationale is scattered across commits and pull requests and is hard to find later.
* ❌ Bad, because it does not satisfy the requirement to document architectural decisions.

### External wiki or documentation tool

* ✅ Good, because it centralizes documentation and can be richly formatted.
* ❌ Bad, because it drifts out of sync with the code and is not versioned alongside it.
* ❌ Bad, because it adds a second system to maintain and access.

### Markdown Architectural Decision Records (MADR)

* ✅ Good, because records are co-located and co-versioned with the code.
* ✅ Good, because they are reviewed through the normal pull-request process.
* ✅ Good, because plain Markdown is durable and tooling-agnostic.
* ❌ Bad, because it relies on contributor discipline to keep the log current.

## Links

* [Architecture Decision Records](https://adr.github.io/)
* [MADR](https://adr.github.io/madr/)
