# spec/getstats_spec.sh
# shellcheck disable=SC2317

Describe 'getstats.sh'
  Include ./getstats.sh

  # Mock the heavy lifters
  Mock uname
    echo "Linux OpenWrt"
  End
  Mock uptime
    echo "10:00:00 up 1 day"
  End

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
    When call run_getstats
    The status should be success
    The stdout should include "Done..."
    The file "/tmp/openwrtstats.txt" should be exist
    The file "/tmp/openwrtstats.txt" should include "Linux OpenWrt"
  End
End