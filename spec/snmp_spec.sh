# spec/snmp_spec.sh
# shellcheck disable=SC2317

Describe 'TestScripts/snmp.sh'
  Include ./TestScripts/snmp.sh

  Mock uci
    exit 0
  End

  Mock /etc/init.d/snmpd
    echo "Restarting snmpd (mock)"
  End

  It 'configures SNMP settings and restarts service'
    When call run_snmp
    The status should be success
    The output should include "Configuring and starting snmpd"
    The output should include "Restarting snmpd (mock)"
  End
End