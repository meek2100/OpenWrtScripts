# spec/betterspeedtest_spec.sh
# shellcheck disable=SC2317,SC2329

Describe 'betterspeedtest.sh'
  Include ./betterspeedtest.sh

  # Common mocks for foreground commands
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
    # HERMENEUTIC FIX:
    # We create a physical "stub" script in a temporary directory and add it to the PATH.
    # This is POSIX compliant and visible to background processes.
    # We disabled SC2329 (unused function) above because ShellCheck cannot see that
    # ShellSpec invokes these functions via the 'Before' and 'After' hooks below.

    setup_netperf_stub() {
      MOCK_DIR=$(mktemp -d)
      MOCK_BIN="$MOCK_DIR/netperf"

      # Create a shell script that acts as the fake netperf
      echo '#!/bin/sh' > "$MOCK_BIN"
      echo 'echo "100"' >> "$MOCK_BIN"
      chmod +x "$MOCK_BIN"

      # Prepend the mock dir to PATH so the script finds our stub first
      ORIGINAL_PATH="$PATH"
      export PATH="$MOCK_DIR:$PATH"
    }

    teardown_netperf_stub() {
      # Restore the environment and clean up
      export PATH="$ORIGINAL_PATH"
      rm -rf "$MOCK_DIR"
    }

    # Execute setup/teardown for tests in this Context
    Before 'setup_netperf_stub'
    After 'teardown_netperf_stub'

    It 'runs a download test and reports speed'
      When call run_betterspeedtest -Z pass -t 1 -i
      The status should be success
      The output should include "Testing idle line"
    End
  End

  Context 'when netperf is missing'
    # In this context, the setup_netperf_stub is NOT run.
    # Therefore, 'netperf' will not be found in the PATH.
    # We mock 'command' just to be absolutely sure we simulate a missing tool.
    Mock command
      if [ "$2" = "netperf" ]; then return 1; fi
      # Call the real command for everything else
      builtin command "$@"
    End

    It 'fails gracefully without netperf'
      When call run_betterspeedtest
      The status should be failure
      The stderr should include "netperf is not installed"
    End
  End
End
