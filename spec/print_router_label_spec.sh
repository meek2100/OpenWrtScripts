# spec/print_router_label_spec.sh
# shellcheck disable=SC2317

Describe 'print-router-label.sh'
  Include ./print-router-label.sh

  Mock cat
    case "$1" in
      */sysinfo/model) echo "Linksys E8450 (Mocked)";;
      *) echo "Generic Content";;
    esac
  End

  Mock uci
    # We wrap the body in a subshell and redirect stderr to null
    # to silence 'Broken pipe' errors when the reader (grep/cut) exits early.
    (
      case "$*" in
        *"get system.@system[0].hostname") echo "MyRouter" ;;
        *"get network.lan.ipaddr") echo "192.168.1.1" ;;
        *"get dhcp.@dnsmasq[0].domain") echo "lan" ;;
        *"show wireless") echo "wireless.default_radio0=wifi-iface" ;;
        *"get"*"wireless.default_radio0.ssid") echo "MyWifi" ;;
        *"get"*"wireless.default_radio0.key") echo "secret123" ;;
        *) echo "" ;;
      esac
    ) 2>/dev/null || true
  End

  Mock date
    echo "2023-01-01"
  End
  Mock grep
    echo "OpenWrt 23.05.5"
  End

  It 'generates a label with correct credentials'
    When call print_router_label "mypassword"
    The output should include "Device: Linksys E8450 (Mocked)"
    The output should include "Login PW: mypassword"
    The output should include "Wifi SSID: MyWifi"
    The output should include "Wifi PW: secret123"
  End
End
