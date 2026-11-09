# bats-tool-inventory - Tool inventory and apt pin assertions for Bats
#
# Depends on bats-support and bats-assert, which are loaded from BATS_LIB_PATH.

bats_load_library bats-support
bats_load_library bats-assert

# shellcheck disable=1090
source "$(dirname "${BASH_SOURCE[0]}")/src/resolve-inventory.bash"
source "$(dirname "${BASH_SOURCE[0]}")/src/tool-inventory.bash"
