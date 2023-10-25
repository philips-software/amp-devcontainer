``` {.sh file=specification/tests/assets/testsuite.bats}
setup() {
  <<setup>>
}

teardown() {
  <<teardown>>
}

<<testbody>>
```

``` {.sh #setup}
load '/usr/local/bats-support/load'
load '/usr/local/bats-assert/load'
```

``` {.sh #teardown}
rm -rf build
```

``` {.sh #testbody}
@test <<testcase>>
```
