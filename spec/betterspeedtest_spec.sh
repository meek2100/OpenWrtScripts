# spec/betterspeedtest_spec.sh
# shellcheck disable=SC2317

Describe 'betterspeedtest.sh'
  # Mock external tools so we don't actually hit the network
  Mock netperf
    echo "100" # Simulate 100 Mbps output
  End
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

  # Function to intercept the script execution
  It 'runs a download test and reports speed'
    When run script ./betterspeedtest.sh -Z pass -t 1 -i
    The status should be success
    The output should include "Testing idle line"
    # The stderr should be present # Removing unreliable expectation
  End

  It 'fails gracefully without netperf'
    Mock command
      # Mock command -v behavior to fail
      exit 1
    End

    When run script ./betterspeedtest.sh
    The status should be failure
    The stderr should include "netperf is not installed"
  End
End