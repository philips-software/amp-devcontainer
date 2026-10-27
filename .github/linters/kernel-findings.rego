package trivy

import rego.v1

default ignore := false

# Kernel packages never execute inside a container - only the host's kernel runs -
# so vulnerabilities against them can't be exploited here, regardless of CVE ID.
ignore if {
	startswith(input.PkgName, "linux-")
}
