# bats-tool-inventory

Bats helpers to verify that the tools declared in a tool inventory are present and start, and that apt packages are installed at their pinned versions.
The package follows the same conventions as [bats-support](https://github.com/bats-core/bats-support) and [bats-assert](https://github.com/bats-core/bats-assert), and is installed by the amp-devcontainer base image in `/usr/local/bats-tool-inventory`.

The helpers know nothing about container images, flavors, or repository layout.
Callers pass every input file explicitly, so they are equally usable for a single image or for a build system that derives multiple images.

## Usage

Load bats-support and bats-assert before loading this package:

```bash
setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  load '/usr/local/bats-tool-inventory/load'
}
```

### Requirements

Bash, [Bats](https://bats-core.readthedocs.io) 1.5.0 or newer, bats-support, bats-assert, `jq`, GNU `timeout` and `realpath`, and `dpkg-query` (only for the apt assertions).

### Apt requirement files

An apt requirements file is a JSON object mapping a package name to its pinned version, e.g. `{"fake-package": "1.2.3-1"}`.
When multiple files are passed, later files override earlier ones.
A missing argument or file is an error.

| Function | Description |
| --- | --- |
| `read_apt_requirements FILE...` | Print the merged requirements as JSON. |
| `get_expected_version_for TOOL FILE...` | Print the pinned upstream version (packaging revision removed) of a tool. |
| `get_expected_semver_for TOOL FILE...` | Print the first `major.minor.patch` of the expected version. |
| `assert_apt_packages_at_pinned_versions FILE...` | Assert that each package is installed at exactly the pinned version. |

A tool matches a package when its name is equal to the package name, or when the package name starts with the tool name followed by a dash.
Looking up `fake-tool` therefore also matches `fake-tool-extra`; the lookup fails when the matches have different versions.

### Tool inventory

An inventory file is a JSON object with an optional `includes` array and a `packages` object:

```json
{
  "includes": ["../fake-base/tool-inventory.json"],
  "packages": {
    "fake-tool": {},
    "fake-package": {
      "commands": ["fake-command"],
      "files": ["/fake/prefix/share/fake-file"],
      "smoke-test-args": { "fake-command": ["--fake-flag"] }
    }
  }
}
```

- An empty entry is shorthand for a single command with the name of the package.
- Includes are relative to the declaring file and are applied in order; local packages then replace inherited entries in full.
- Commands are started with `--version` unless `smoke-test-args` provides other arguments.
- Missing includes, include cycles, and invalid documents are errors.

| Function | Description |
| --- | --- |
| `resolve_inventory FILE` | Print the resolved inventory as compact JSON. |
| `read_inventory_tools FILE` | Print one JSON object per command and file in the inventory. |
| `assert_inventory_tools_available FILE` | Assert that all commands are on the `PATH` and all files exist. |
| `assert_inventory_tools_run FILE` | Assert that every command starts successfully within 30 seconds. |

### Version helpers

| Function | Description |
| --- | --- |
| `to_semver` | Read stdin and print the first `major.minor.patch`. |
| `assert_tool_version TOOL ACTUAL EXPECTED` | Fail with a diagnostic when the versions differ. |
| `assert_commands_available COMMAND...` | Fail on the first command that is not on the `PATH`. |

## Tests

The package tests use generated fake inputs only. Run them with Bats from the repository root:

```bash
bats helpers/bats-tool-inventory/test
```

The tests are not installed into container images.
