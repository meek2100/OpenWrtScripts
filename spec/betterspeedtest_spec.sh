# spec/betterspeedtest_spec.sh
# shellcheck disable=SC2317,SC2329

Describe 'betterspeedtest.sh'
  Include ./betterspeedtest.sh

  # Common mocks for foreground commands
  Mock mktemp
    echo "/tmp/mock_temp_file"
  End
  Mock rm
    exit 0
  End

  Context 'when netperf is installed'
    setup_stubs() {
      # Create a temporary directory for our physical stubs
      MOCK_DIR=$(mktemp -d)

      # 1. Stub for netperf
      # - Prints "100" to simulate 100Mbps
      # - Sleeps 1s to ensure 'pgrep' finds it (Fixes race condition/0Mbps)
      cat << 'EOF' > "$MOCK_DIR/netperf"
#!/bin/sh
echo "100"
sleep 1
EOF
      chmod +x "$MOCK_DIR/netperf"

      # 2. Stub for ping (and aliases)
      # - Prints mock output so summarize_pings has data
      # - Sleeps 5s to stay alive during the test (preventing early exit)
      # - Will be killed by the script's clean_up function
      cat << 'EOF' > "$MOCK_DIR/ping"
#!/bin/sh
echo "64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=15.0 ms"
sleep 5
EOF
      chmod +x "$MOCK_DIR/ping"
      # Create symlinks for ping4/ping6 so command -v finds them
      ln -s "$MOCK_DIR/ping" "$MOCK_DIR/ping4"
      ln -s "$MOCK_DIR/ping" "$MOCK_DIR/ping6"

      # Prepend our MOCK_DIR to PATH so the script uses our tools
      ORIGINAL_PATH="$PATH"
      export PATH="$MOCK_DIR:$PATH"
    }

    teardown_stubs() {
      # Restore environment and cleanup
      export PATH="$ORIGINAL_PATH"
      rm -rf "$MOCK_DIR"
    }

    # Apply the stubs to this Context
    Before 'setup_stubs'
    After 'teardown_stubs'

    It 'runs a download test and reports speed'
      # We explicitly pass -t 1 to make the test fast (if stubs work)
      # We pass -i to test the idle path, or omit it for full test.
      # This test covers the full download/upload path.
      When call run_betterspeedtest -Z pass -t 1
      The status should be success

      # Verify we are using the stubs (speed 100 * 5 sessions = 500)
      The output should include "Download: 500.00 Mbps"
      The output should include "Upload: 500.00 Mbps"
    End
  End

  Context 'when netperf is missing'
    # In this context, we do NOT run setup_stubs.
    # We must ensure command -v netperf fails.
    # Since the runner has netperf installed, we mock command to force failure.
    Mock command
      if [ "$2" = "netperf" ]; then return 1; fi
      builtin command "$@"
    End

    It 'fails gracefully without netperf'
      When call run_betterspeedtest
      The status should be failure
      The stderr should include "netperf is not installed"
    End
  End
End
