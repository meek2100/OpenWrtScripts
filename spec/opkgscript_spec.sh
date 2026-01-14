# spec/opkgscript_spec.sh
# shellcheck disable=SC2317,SC2329

Describe 'opkgscript.sh'
  Include ./opkgscript.sh

  Mock opkg
    exit 0
  End

  It 'displays help when no command is provided'
    When call run_opkgscript
    The output should include "Usage:"
  End

  Context 'generating script'
    setup() {
      echo "missing_package" > "$SHELLSPEC_TMPBASE/installed_list"
    }
    Before 'setup'

    It 'generates an install script from a list'
      Mock opkg
        # Matches the behavior expected by the script's check:
        # if [ -z "$(opkg status "$PACKAGE")" ]; then ...
        if [ "$1" = "status" ]; then
           # Return nothing to simulate package not installed
           echo ""
           exit 0
        fi
        if [ "$1" = "info" ]; then echo "Depends: libc"; fi
        exit 0
      End

      When call run_opkgscript script "$SHELLSPEC_TMPBASE/installed_list"
      The output should include "opkg install missing_package"
    End
  End
End
