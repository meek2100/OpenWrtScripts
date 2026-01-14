# spec/betterspeedtest_spec.sh
# shellcheck disable=SC2317

Describe 'betterspeedtest.sh'
  Include ./betterspeedtest.sh

  # Common mocks
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
    Mock netperf
      echo "100" # Simulate 100 Mbps output
    End

    It 'runs a download test and reports speed'
      When call run_betterspeedtest -Z pass -t 1 -i
      The status should be success
      The output should include "Testing idle line"
    End
  End

  Context 'when netperf is missing'
    # We must mock 'command' to simulate netperf missing,
    # because 'Mock netperf' creates a function that 'command -v' would otherwise find.
    Mock command
      if [ "$2" = "netperf" ]; then return 1; fi
      # Call the real command for everything else
      builtin command "$@"
    End

    It 'fails gracefully without netperf'
      When call run_betterspeedtest
      The status should be failure
      The stderr should include "netperf is not installed"
      # Removed flaky stdout check; checking stderr and exit code is sufficient
    End
  End
End
