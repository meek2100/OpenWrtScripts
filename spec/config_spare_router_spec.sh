# spec/config_spare_router_spec.sh
# shellcheck disable=SC2317

Describe 'config-spare-router.sh'
  export UNIT_TESTING=true

  cat() {
    if [ "$1" = "/tmp/sysinfo/model" ]; then
      echo "Linksys E8450 (Mocked)"
    else
      command cat "$@"
    fi
  }

  grep() {
    if [ "$1" = "DISTRIB_DESCRIPTION" ]; then
        echo "DISTRIB_DESCRIPTION='OpenWrt 23.05.5'"
    else
        command grep "$@"
    fi
  }

  Include ./config-spare-router.sh

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
