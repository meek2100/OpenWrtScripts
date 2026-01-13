# spec/print_router_label_spec.sh
# shellcheck disable=SC2317

Describe 'print-router-label.sh'
  Mock cat
    case "$1" in
      */sysinfo/model) echo "Linksys E8450 (Mocked)";;
      *) echo "Generic Content";;
    esac
  End

  Mock uci
    # Use || true to prevent 'broken pipe' errors if the script stops reading early
    # Added 2>/dev/null to 'show wireless' echo to suppress broken pipe logs
    # Added wildcards (*"get"*"...") to ensure argument matching works reliably
    case "$*" in
      *"get system.@system[0].hostname") echo "MyRouter" || true ;;
      *"get network.lan.ipaddr") echo "192.168.1.1" || true ;;
      *"get dhcp.@dnsmasq[0].domain") echo "lan" || true ;;
      *"show wireless") echo "wireless.default_radio0=wifi-iface" 2>/dev/null || true ;;
      *"get"*"wireless.default_radio0.ssid") echo "MyWifi" || true ;;
      *"get"*"wireless.default_radio0.key") echo "secret123" || true ;;
      *) echo "" || true ;;
    esac
  End

  Mock date
    echo "2023-01-01"
  End
  Mock grep
    echo "OpenWrt 23.05.5"
  End

  It 'generates a label with correct credentials'
    When run script ./print-router-label.sh "mypassword"
    The output should include "Device: Linksys E8450 (Mocked)"
    The output should include "Login PW: mypassword"
    The output should include "Wifi SSID: MyWifi"
    The output should include "Wifi PW: secret123"
  End
End