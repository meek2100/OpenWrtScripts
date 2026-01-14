# spec/tunnelbroker_spec.sh
# shellcheck disable=SC2317

Describe 'tunnelbroker.sh'
  Include ./tunnelbroker.sh

  Mock opkg
    exit 0
  End

  Mock uci
    exit 0
  End

  # Mock the init scripts. Since they are called by full path,
  # we mock the path as the command name.
  Mock /etc/init.d/network
    echo "Restarting network (mock)..."
  End

  Mock /etc/init.d/firewall
    echo "Restarting firewall (mock)..."
  End

  It 'configures the tunnel and restarts services'
    When call run_tunnelbroker
    The status should be success
    The output should include "Setting up HE.net tunnel"
    The output should include "Restarting network..."
    The output should include "Restarting firewall..."
  End
End
