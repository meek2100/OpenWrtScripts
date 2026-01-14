# spec/config_spare_router_spec.sh
# shellcheck disable=SC2317

Describe 'config-spare-router.sh'
  Include ./config-spare-router.sh

  # System Mocks
  Mock passwd
    # Consumes stdin (password) and exits success
    cat >/dev/null
    exit 0
  End

  Mock uci
    # Handle read requests for the label printer
    case "$*" in
      *"get system.@system[0].hostname") echo "SpareRouter" ;;
      *"get network.lan.ipaddr") echo "172.30.42.1" ;;
      *"get dhcp.@dnsmasq[0].domain") echo "lan" ;;
      *"show wireless") echo "wireless.radio0=wifi-iface" ;;
      *"get"*"ssid") echo "SpareRouter" ;;
      *"get"*"key") echo "" ;;
      # Default success for 'set', 'commit', etc.
      *) exit 0 ;;
    esac
  End

  Mock sed
    exit 0
  End

  Mock opkg
    exit 0
  End

  Mock reboot
    echo "Rebooting (mock)"
    exit 0
  End

  Mock sleep
    exit 0
  End

  # Mocks for print_router_label info
  Mock cat
    if [ "$1" = "/tmp/sysinfo/model" ]; then
      echo "Linksys E8450 (Mocked)"
    else
      # Fallback to cat behavior for other uses (like piping)
      # But since we can't easily replicate 'cat' behavior for stdin in mock without arguments
      # We assume specific usage or return true.
      # However, print_router_label uses cat /tmp/sysinfo/model.
      # The script also uses cat > config.sh in instructions but that's comments.
      # It uses cat for the passwd heredoc? No, passwd reads stdin directly.
      # Ideally we mock specific files.
      echo "Generic Content"
    fi
  End

  Mock grep
    if [ "$1" = "DISTRIB_DESCRIPTION" ]; then
        echo "DISTRIB_DESCRIPTION='OpenWrt 23.05.5'"
    else
        # Mock grep behavior for other cases or standard input
        # Returning true avoids breaking pipes
        cat >/dev/null
        exit 0
    fi
  End

  Mock mktemp
    echo "/tmp/mock_wifi_creds"
  End

  Mock rm
    exit 0
  End

  Mock cut
    # Simple mock to handle the specific cut usage in the script
    # This is brittle, but often sufficient for simple scripts.
    # Ideally, rely on real 'cut' if environment allows, but for strict isolation:
    case "$*" in
      *"-d="*) echo "OpenWrt 23.05.5" ;;
      *"-d:"*) echo "SpareRouter" ;; # simplified return for wifi creds
      *) cat ;;
    esac
  End

  # For 'tr', 'date' we can use real commands or simple mocks
  Mock date
    echo "2024-01-01"
  End

  # Since cut/tr pipelines are complex to mock perfectly,
  # sometimes it is easier to let the script run real cut/tr if they are safe pure-functions.
  # But assuming we want isolation:
  Mock tr
    cat
  End

  It 'configures the spare router and prints a label'
    When call run_config_spare_router
    The status should be success

    # Verify configuration steps
    The output should include "*** Updating root password"
    The output should include "*** Setting host name"
    The output should include "*** Changing IP address"
    The output should include "*** Setting Wifi Parameters"
    The output should include "*** Updating software packages"

    # Verify Label Printing output
    The output should include "======= Printed with: print-router-label.sh ======="
    The output should include "Login PW: SpareRouter"

    # Verify Reboot
    The output should include "Rebooting the router now"
    The output should include "Rebooting (mock)"
  End
End
