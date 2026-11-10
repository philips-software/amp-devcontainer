---
description: "Use when writing or changing Bats tests (*.bats), the Bats helper packages in helpers/, or test/repository: conventions for fakes, stubbing, libraries and running them."
applyTo: "**/*.bats, helpers/**"
---

# Bats Test Guidelines

- Start with `#!/usr/bin/env bats` and `bats_require_minimum_version 1.6.0`, and load libraries in `setup` with `bats_load_library bats-support`, `bats-assert`, and `bats-tool-inventory` where needed. This needs `BATS_LIB_PATH=/usr/local` outside of the dev container.
- Test inputs are obviously fake: use names like `fake-tool`, `example.invalid`, and digests like `sha256:000…1`. Never use real package names, versions or SHAs, so a test can't pass or fail by accident when the real thing changes.
- Stub external commands (`gh`, `docker`, `git`, `curl`) with exported bash functions (`export -f`), so tests run without network, credentials or a container engine. GNU `timeout` and `env` can't run a function: use an executable stub on `PATH` for those.
- Use `BATS_TEST_TMPDIR` for files, and don't write to the repository.
- `run` overwrites `$output` and `$status`, order assertions accordingly. Use `assert_output`, `assert_line` and `refute_output` rather than ad hoc `[ ... ]`. Use `jq -S` to compare JSON, because key order is not stable.
- A test name says what the behavior is: `fails when the markers in the notes don't match up`.
- Cover the failure paths (missing input, invalid file, a command that fails) as well as the happy path.
- Integration tests in `test/<flavor>` run inside the flavor's container and check the tools from the [tool inventory](../../.github/CONTRIBUTING.md) with `bats-tool-inventory`, instead of repeating a list of tools.
- Run a changed test before finishing: `bats <path>`. The full set that needs no container is `bats helpers/*/test .github/actions/*/test test/repository`.
