---
applyTo: ".github/workflows/*.yml"
---

# GitHub Workflows Guidelines

When writing GitHub Action workflows, ensure that:

- Workflows that have a workflow_call trigger have their filename prefixed with `wc-`.
- For all re-usable workflows, only the top-level workflow (workflows that are not called themselves by other workflows with workflow_call) has defaults and descriptions for inputs to avoid duplication.
- All workflows and action definitions have a name that is descriptive and concise, using emoji where appropriate.
- The sorting order for inputs, secrets, and outputs is alphabetical.
- The sorting order of other keys is consistent across the repository.
- Don't use quotes for strings unless necessary (e.g., to avoid special characters being misinterpreted).
- Use multi-line syntax for longer strings (e.g., for `run` commands or descriptions).
