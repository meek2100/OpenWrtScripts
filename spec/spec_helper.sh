# spec/spec_helper.sh
# shellcheck disable=SC2317

# 1. Enforce the environment (The Whole Context)
# set -eu # Removed set -e to prevent test aborts on expected failures

export UNIT_TESTING=true

# Mock commands globally
uci() {
  case "$*" in
    *"get system.@system[0].hostname") echo "SpareRouter" ;;
    *"get network.lan.ipaddr") echo "172.30.42.1" ;;
    *"get dhcp.@dnsmasq[0].domain") echo "lan" ;;
    *"show wireless") echo "wireless.radio0=wifi-iface" ;;
    *"get"*"ssid") echo "SpareRouter" ;;
    *"get"*"key") echo "" ;;
    *) return 0 ;;
  esac
}

passwd() {
  cat >/dev/null
  return 0
}

sed() { return 0; }
opkg() { return 0; }
reboot() { echo "Rebooting (mock)"; }
sleep() { return 0; }

# 2. Add the project root to PATH so scripts can be run without './' prefix if needed
#    and ensures mocked tools in current dir are found first if you add them.
PATH="$(pwd):$PATH"
export PATH

# 3. Define the load helper (Connects Library Parts to Tests)
load_lib() {
  # shellcheck disable=SC1090
  . "./lib/$1"
}
