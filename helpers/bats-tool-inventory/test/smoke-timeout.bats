#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  load '../load'
  export FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}/bin"
  export PATH="${FAKE_DIR}/bin:${PATH}"
  cat > "${FAKE_DIR}/inventory.json" <<'EOF'
{"packages":{"fake-package":{"commands":["fake-command"],"smoke-test-args":{"fake-command":["--fake flag","value;not-a-shell"]}}}}
EOF
  cat > "${FAKE_DIR}/smoke.bats" <<EOF
setup() {
  load '${BATS_TEST_DIRNAME}/../load'
}
@test "inventory commands start successfully" {
  exec 9>'${FAKE_DIR}/fake-descriptor'
  assert_inventory_tools_run '${FAKE_DIR}/inventory.json' 1
}
EOF
}

teardown() {
  # Keep a regression in the supervisor from leaking fixture processes.
  local pid
  if [[ -f "${FAKE_DIR}/pids" ]]; then
    while read -r pid; do
      kill -KILL "${pid}" 2>/dev/null || true
    done < "${FAKE_DIR}/pids"
  fi
}

make_command() {
  {
    printf '#!/usr/bin/env bash\n'
    printf 'echo "${BASHPID}" >> "${FAKE_DIR}/pids"\n'
    cat
  } > "${FAKE_DIR}/bin/fake-command"
  chmod +x "${FAKE_DIR}/bin/fake-command"
}

assert_junit_run() {
  local expected=${1:-1}
  local pid
  # The outer deadline is a test safeguard, not the implementation under test.
  run timeout --kill-after=2s 12s bats --formatter junit "${FAKE_DIR}/smoke.bats" < /dev/null
  assert_equal "${status}" "${expected}"
  printf '%s\n' "${output}" > "${FAKE_DIR}/report.xml"
  [[ "${#output}" -lt 100000 ]]
  run python3 -c '
import sys
import xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
cases = root.findall(".//testcase")
assert len(cases) == 1
assert cases[0].attrib["name"] == "inventory commands start successfully"
assert len(cases[0].findall("failure")) == int(sys.argv[2])
' "${FAKE_DIR}/report.xml" "${expected}"
  assert_success
  while read -r pid; do
    if [[ -e "/proc/${pid}" ]]; then
      fail "smoke command process ${pid} was not reaped"
      return 1
    fi
  done < "${FAKE_DIR}/pids"
  run cat "${FAKE_DIR}/report.xml"
}

assert_timeout_diagnostic() {
  assert_output --partial "fake-package"
  assert_output --partial 'fake-command --fake\ flag value\;not-a-shell'
  assert_output --partial "timed out after 1s"
  assert_output --partial "termination grace 5s"
  assert_output --partial "exit code"
  assert_output --partial "124"
}

@test "a blocking smoke command produces a complete JUnit timeout failure" {
  make_command <<'EOF'
echo "fake stdout"
echo "fake stderr" >&2
exec sleep 300
EOF

  assert_junit_run
  assert_timeout_diagnostic
  assert_output --partial "fake stdout"
  assert_output --partial "fake stderr"
}

@test "a smoke command ignoring TERM is killed and reaped within the deadline" {
  make_command <<'EOF'
trap '' TERM
exec sleep 300
EOF

  assert_junit_run
  assert_timeout_diagnostic
}

@test "an exited command cannot leave a detached child holding Bats capture open" {
  make_command <<'EOF'
if [[ -e "/proc/${BASHPID}/fd/3" || -e "/proc/${BASHPID}/fd/9" ]]; then
  echo "fake inherited Bats descriptor"
  exit 7
fi
setsid bash -c '
  trap "" TERM
  echo "${BASHPID}" >> "${FAKE_DIR}/pids"
  echo "fake detached child"
  exec sleep 300
' &
exit 0
EOF

  assert_junit_run
  assert_timeout_diagnostic
  assert_output --partial "fake detached child"
  refute_output --partial "fake inherited Bats descriptor"
}

@test "excessive smoke output is drained but diagnostics stay bounded" {
  make_command <<'EOF'
echo "fake useful output"
while :; do printf '%4096s\n' "fake noise"; done
EOF

  assert_junit_run
  assert_timeout_diagnostic
  assert_output --partial "fake useful output"
  assert_output --partial "output truncated after 16384 bytes"
}

@test "a successful smoke command keeps custom argument and stdin behavior" {
  make_command <<'EOF'
[[ "$#" == 2 && "$1" == "--fake flag" && "$2" == "value;not-a-shell" ]] || exit 7
[[ "$(readlink /proc/self/fd/0)" == /dev/null ]]
EOF

  assert_junit_run 0
  refute_output --partial "timed out"
}

@test "a successful command with excessive output does not receive SIGPIPE" {
  make_command <<'EOF'
head -c 131072 /dev/zero
EOF

  assert_junit_run 0
}

@test "a successful command cannot leave descendants after closing its streams" {
  make_command <<'EOF'
setsid bash -c '
  trap "" TERM
  echo "${BASHPID}" >> "${FAKE_DIR}/pids"
  sleep 300 &
  echo "$!" >> "${FAKE_DIR}/pids"
  touch "${FAKE_DIR}/fake-ready"
  wait
' >/dev/null 2>&1 &
while [[ ! -f "${FAKE_DIR}/fake-ready" ]]; do sleep 0.01; done
exit 0
EOF

  assert_junit_run 0
}

@test "a nonzero smoke exit preserves diagnostics and produces valid JUnit with control output" {
  make_command <<'EOF'
printf 'fake failure output\000\001\033\n'
echo "fake stderr" >&2
exit 3
EOF

  assert_junit_run
  assert_output --partial "inventory command failed to start successfully"
  assert_output --partial "fake-package"
  assert_output --partial 'fake-command --fake\ flag value\;not-a-shell'
  assert_output --partial "fake failure output"
  assert_output --partial '\x00\x01\x1b'
  assert_output --partial "fake stderr"
  assert_output --partial "3"
  refute_output --partial "timed out"
}
