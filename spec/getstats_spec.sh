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

  # Updated Mock opkg to handle 'status kernel' vs other packages
  Mock opkg
    case "$*" in
      *"status kernel"*)
        echo "Package: kernel"
        echo "Status: install hold installed"
        echo "Installed-Time: 1000000000"
        ;;
      *)
        echo "Package: test-pkg"
        echo "Status: install user installed"
        echo "Installed-Time: 2000000000"
        ;;
    esac
  End

  It 'collects stats and writes to the output file'
    # We use a custom temp file for the test, but the script hardcodes output.
    # We just check the hardcoded location.

    When run script ./getstats.sh
    The status should be success
    # Verify the script tried to run standard commands
    The stdout should include "Done..."
    The file "/tmp/openwrtstats.txt" should be exist
    The file "/tmp/openwrtstats.txt" should include "Linux OpenWrt"
  End
End