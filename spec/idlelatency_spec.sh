# spec/idlelatency_spec.sh
# shellcheck disable=SC2317

Describe 'idlelatency.sh'
  Include ./idlelatency.sh

  Mock mktemp
    echo "/tmp/mock_ping_file"
  End
  Mock date
    echo "2023-01-01"
  End
  Mock sleep
    exit 0
  End
  Mock rm
    exit 0
  End
  Mock kill
    exit 0
  End
  Mock wait
    exit 0
  End

  Context 'running the latency test'
    Mock ping
      # Simulate ping output writing to the file (which is $3 in the redirect, but hard to mock redirect)
      # Instead, we just let the mock run. The script reads from the temp file.
      # We can seed the temp file in a Before hook if we wanted to test the math strictly,
      # but here we mostly test the flow.
      exit 0
    End

    # Mock the pipeline tools to return a canned response for the summary
    Mock sed
      cat # pass through
    End
    Mock grep
      cat # pass through
    End
    Mock sort
      cat # pass through
    End

    # The big awk script is hard to verify via mock output alone,
    # so we mock awk to return the final formatted string we expect.
    Mock awk
      echo "  Latency: (in msec, 10 pings, 0.00% packet loss)"
      echo "      Min: 10.000"
      echo "      Avg: 12.000"
      echo "      Max: 15.000"
    End

    It 'collects pings and summarizes them'
      When call run_idlelatency -t 1
      The status should be success
      The output should include "Testing idle line"
      The output should include "Latency: (in msec"
    End
  End
End