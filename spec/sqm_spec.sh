# spec/sqm_spec.sh
# shellcheck disable=SC2317

Describe 'TestScripts/sqm.sh'
  Include ./TestScripts/sqm.sh

  Mock uci
    exit 0
  End

  It 'configures SQM with expected values'
    When call run_sqm
    The status should be success
    The output should include "Setting SQM to 8264/911 kbps down/up"
  End
End