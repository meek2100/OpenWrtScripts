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
    exit 0 # Must use exit, not return, for external command mocks
  End

  # Function to intercept the script execution
  It 'runs a download test and reports speed'
    When run script ./betterspeedtest.sh -Z pass -t 1 -i
    The status should be success
    The output should include "Testing idle line"
    The stderr should be present
  End

  It 'fails gracefully without netperf'
    Mock command
      # Mocking 'command -v' behavior
      if [ "$1" = "-v" ]; then return 1; fi
      # NOTE: 'command' is a shell builtin, so 'return' IS valid here if ShellSpec mocks it as a function.
      # HOWEVER, if ShellSpec wraps it in a script due to context, try exit.
      # Safe bet for builtins in 'run script' is tricky, but try 'return 1' first.
      # If this fails with the same error, change to 'exit 1'.
      return 1
    End

    # Simpler approach for checking if netperf exists:
    # Just mock the check logic or ensure command -v fails.
    # Actually, the error in your log came from 'rm', not 'command'.
    # Let's fix 'rm' first (above).

    # If 'command' gives you trouble, simply Mock it to exit 1:
    Mock command
       exit 1
    End

    When run script ./betterspeedtest.sh
    The status should be failure
    The output should include "netperf is not installed"
  End
End