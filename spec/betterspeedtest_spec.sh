# spec/betterspeedtest_spec.sh
# shellcheck disable=SC2317

Describe 'betterspeedtest.sh'
  # Common Mocks
  Mock ping
    echo "64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=15.0 ms"
    sleep 0.1
  End
  Mock mktemp
    echo "/tmp/mock_temp_file"
  End
  Mock rm
    exit 0
  End

  Context 'when netperf is installed'
    # Mocking netperf makes 'command -v netperf' succeed
    Mock netperf
      echo "100"
    End

    It 'runs a download test and reports speed'
      When run script ./betterspeedtest.sh -Z pass -t 1 -i
      The status should be success
      The output should include "Testing idle line"
    End
  End

  Context 'when netperf is not installed'
    # No netperf mock here.
    # 'command -v netperf' will fail (return 1) if not in system PATH.

    It 'fails gracefully'
      When run script ./betterspeedtest.sh
      The status should be failure
      The output should include "netperf is not installed"
    End
  End
End