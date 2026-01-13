# spec/spec_helper.sh
# shellcheck disable=SC2317
set -eu

# Fix SC2155: Declare and assign separately
CURRENT_DIR=$(pwd)
export PATH="$PATH:$CURRENT_DIR"

# Helper to load the library script for testing
load_lib() {
  # shellcheck disable=SC1090
  . "./lib/$1"
}

# Shared Mocks
mock_uci_get() {
  key="$1"
  value="$2"
  Mock uci
    if [ "$2" = "$key" ]; then echo "$value"; return 0; fi
    echo "mock_value"
  End
}

mock_opkg_installed() {
  package="$1"
  Mock opkg
    case "$*" in
      "status $package") echo "Status: install user installed";;
      "list-installed") echo "$package - 1.0";;
      *) return 0;;
    esac
  End
}
