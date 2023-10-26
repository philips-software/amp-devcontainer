---
active: true
derived: false
level: 1.0
links: []
normative: false
ref: ''
reviewed: cOI6NlkJN-yg59JzLqsodC6aAP09XKowI1O47MHyNYE=
---

# Purpose

This document describes the test cases to be executed as part of the verification of amp-devcontainer.

``` {.sh file=test/testsuite.bats}
#!/usr/bin/env bats

setup() {
  #!/usr/bin/env bats
  <<setup>>
}

teardown() {
  #!/usr/bin/env bats
  <<teardown>>
}

<<testcase>>

```

``` {.sh #setup}
load '/usr/local/bats-support/load'
load '/usr/local/bats-assert/load'
```

``` {.sh #teardown}
rm -rf build
```