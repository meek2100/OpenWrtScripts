# spec/netperfrunner_spec.sh
# shellcheck disable=SC2317

Describe 'netperfrunner.sh'
  Include ./netperfrunner.sh

  # Common mocks
  Mock mktemp
    echo "/tmp/mock_temp_file"
  End
  Mock date
    echo "2023-01-01 12:00:00"
  End
  Mock rm
    exit 0
  End
  Mock sleep
    exit 0
  End

  # Mock pgrep to return a fake PID so the wait loop runs once
  Mock pgrep
    echo "12345"
  End

  # Mock wait to just return success
  Mock wait
    exit 0
  End

  # Mock wc to return 0 (no errors in error file)
  Mock wc
    echo "0"
  End

  Context 'when netperf is installed'
    Mock command
      # Simulate netperf being present
      return 0
    End

    Mock netperf
      # Simulate output for bandwidth calculation
      echo "50.0"
    End

    # We need to mock awk to handle the summation of bandwidth
    # The script uses: awk '{s+=$1} END {print s}' "$DLFILE"
    Mock awk
      echo "200.00"
    End

    It 'runs the stress test and reports bandwidth'
      # We mock the ping function's internal commands too
      Mock ping
        echo "64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=15.0 ms"
      End

      When call run_netperfrunner -H test.server -t 1
      The status should be success
      The output should include "Testing test.server (ipv4)"
      The output should include "Download: 200.00 Mbps"
      The output should include "Upload: 200.00 Mbps"
    End
  End

  Context 'when netperf is missing'
    Mock command
      if [ "$2" = "netperf" ]; then return 1; fi
      return 0
    End

    It 'fails gracefully'
      When call run_netperfrunner
      The status should be failure
      The stderr should include "netperf is not installed"
    End
  End
End
