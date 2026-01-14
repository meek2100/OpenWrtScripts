# spec/config_openwrt_spec.sh
# shellcheck disable=SC2317

Describe 'config-openwrt.sh'
  Include ./config-openwrt.sh

  # Mock commands that might be uncommented by the user
  Mock passwd
    exit 0
  End
  Mock uci
    exit 0
  End
  Mock ifup
    exit 0
  End
  Mock sleep
    exit 0
  End
  Mock opkg
    exit 0
  End
  Mock sed
    exit 0
  End

  # Mock service calls
  # Mock /etc/init.d/snmpd
  #   exit 0
  # End
  # Mock /etc/init.d/avahi-daemon
  #   exit 0
  # End
  # Mock /etc/init.d/sqm
  #   exit 0
  # End

  It 'runs the configuration template successfully'
    When call run_config_openwrt
    The status should be success
    The output should include "You should restart the router now"
  End
End
