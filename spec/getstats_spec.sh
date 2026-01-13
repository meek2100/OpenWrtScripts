# spec/getstats_spec.sh
# shellcheck disable=SC2317

Describe 'getstats.sh'
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
    When run script ./getstats.sh
    The status should be success

    # Verify the script tried to run standard commands
    The file "/tmp/openwrtstats.txt" should be exist
    The file "/tmp/openwrtstats.txt" should include "Linux OpenWrt"
  End
End