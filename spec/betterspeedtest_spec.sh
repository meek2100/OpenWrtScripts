# spec/betterspeedtest_spec.sh
# shellcheck disable=SC2317,SC2329

Describe 'betterspeedtest.sh'
  Include ./betterspeedtest.sh

  Context 'when netperf is installed'
    setup_stubs() {
      MOCK_DIR=$(mktemp -d)
      cat << 'EOF' > "$MOCK_DIR/netperf"
#!/bin/sh
echo "100"
sleep 1
EOF
      chmod +x "$MOCK_DIR/netperf"

      cat << 'EOF' > "$MOCK_DIR/ping"
#!/bin/sh
echo "64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=15.0 ms"
sleep 5
EOF
      chmod +x "$MOCK_DIR/ping"
      ln -s "$MOCK_DIR/ping" "$MOCK_DIR/ping4"
      ln -s "$MOCK_DIR/ping" "$MOCK_DIR/ping6"

      ORIGINAL_PATH="$PATH"
      export PATH="$MOCK_DIR:$PATH"
    }

    teardown_stubs() {
      export PATH="$ORIGINAL_PATH"
      rm -rf "$MOCK_DIR"
    }

    Before 'setup_stubs'
    After 'teardown_stubs'

    It 'runs a download test and reports speed'
      When call run_betterspeedtest -Z pass -t 1
      The status should be success
      The output should include "Download: 500.00 Mbps"
      The output should include "Upload: 500.00 Mbps"
    End
  End

  Context 'when netperf is missing'
    setup_no_netperf() {
      MOCK_DIR=$(mktemp -d)
      for tool in sh ls cat rm mkdir mktemp grep sed awk date sleep wait kill wc ps env seq pgrep cut tr head tail; do
        if command -v "$tool" >/dev/null; then
           ln -s "$(command -v "$tool")" "$MOCK_DIR/$tool"
        fi
      done
      ORIGINAL_PATH="$PATH"
      export PATH="$MOCK_DIR"
    }

    teardown_no_netperf() {
      export PATH="$ORIGINAL_PATH"
      rm -rf "$MOCK_DIR"
    }

    Before 'setup_no_netperf'
    After 'teardown_no_netperf'

    It 'fails gracefully without netperf'
      When run command env UNIT_TESTING= ./betterspeedtest.sh
      The status should be failure
      # The output should be present
      The stderr should be present
      The stderr should include "netperf is not installed"
    End
  End
End
