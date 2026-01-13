# spec/getstats_spec.sh
# shellcheck disable=SC2317

Describe 'getstats.sh'
  # We must intercept the file writing.
  # Since the script writes to /tmp/openwrtstats.txt, we can check that file.

  # Mock the heavy lifters to avoid actual system calls
  Mock uname
    echo "Linux OpenWrt"
  End

  Mock uptime
    echo "10:00:00 up 1 day"
  End

  Mock opkg
    echo "Package: test-pkg"
  End

  It 'collects stats and writes to the output file'
    # We use a custom temp file for the test
    Parameters
      "/tmp/test_stats_output.txt"
    End

    When run script ./getstats.sh
    The status should be success

    # Verify the script tried to run standard commands
    The file "/tmp/openwrtstats.txt" should be exist
    The file "/tmp/openwrtstats.txt" should include "Linux OpenWrt"
  End
End