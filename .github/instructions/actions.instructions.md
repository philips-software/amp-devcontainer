---
applyTo: ".github/workflows/*.{yml,yaml}"
---

# GitHub Actions Guidelines

When writing GitHub Action workflows, ensure that:

- Workflows that have a workflow_call trigger have the file name prefixed with `wc-`.
- For all re-usable workflows, only the top-level workflow (workflows that are not called themselves by other workflows with workflow_call) has defaults and descriptions for inputs to avoid duplication.
- The sorting order for inputs, secrets, and outputs is alphabetical.
- The sorting order of other keys is consistent across the repository.
