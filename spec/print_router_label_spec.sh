# spec/print_router_label_spec.sh
# shellcheck disable=SC2317

Describe 'print-router-label.sh'
  # Mock the file system reads
  Mock cat
    case "$1" in
      */sysinfo/model) echo "Linksys E8450 (Mocked)";;
      *) echo "Generic Content";;
    esac
  End

  # Mock the configuration system
  Mock uci
    # Handle flags like -q by using wildcards
    case "$*" in
      *"get system.@system[0].hostname") echo "MyRouter";;
      *"get network.lan.ipaddr") echo "192.168.1.1";;
      *"get dhcp.@dnsmasq[0].domain") echo "lan";;
      *"show wireless") echo "wireless.default_radio0=wifi-iface";;
      *"get wireless.default_radio0.ssid") echo "MyWifi";;
      *"get wireless.default_radio0.key") echo "secret123";;
      *) echo "";; # Default empty
    esac
  End

  # Mock basic tools
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