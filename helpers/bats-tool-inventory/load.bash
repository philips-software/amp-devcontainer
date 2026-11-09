# bats-tool-inventory - Tool inventory and apt pin assertions for Bats
#
# Requires bats-support and bats-assert to be loaded by the caller.

# shellcheck disable=1090
source "$(dirname "${BASH_SOURCE[0]}")/src/resolve-inventory.bash"
source "$(dirname "${BASH_SOURCE[0]}")/src/tool-inventory.bash"
