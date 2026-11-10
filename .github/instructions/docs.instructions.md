---
description: "Use when writing or editing documentation: README.md, docs/, action and helper READMEs, ADRs, CONTRIBUTING, or Jinja2 release note templates."
applyTo: "**/*.md, **/*.md.j2"
---

# Documentation Guidelines

- Write one sentence per line, as the existing documents do, and keep lines under 400 characters (markdownlint).
- The README is the source for the key features and how to use the containers. Link to it instead of copying.
- Link to the document that describes something instead of repeating it, with relative links. The link checker (lychee) validates them.
- Explain why, and who it is for, before how. Examples are copy-pasteable and use obviously fake names, e.g. `my-org/my-image`.
- Every action and helper has a README with usage and its inputs and outputs. Update it, and the list in [the re-usable build system](../../docs/reusable-build-system.md), in the same pull request as the change.
- Significant design decisions are an architecture decision record in `docs/adr`.
- Use fenced code blocks with a language, and GitHub alerts (`> [!NOTE]`) sparingly.
- Don't edit a `CHANGELOG.md`, release-please writes them.
