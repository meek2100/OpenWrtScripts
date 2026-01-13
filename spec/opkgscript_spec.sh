# spec/opkgscript_spec.sh
# shellcheck disable=SC2317,SC2329

Describe 'opkgscript.sh'
  Mock opkg
    exit 0
  End

  It 'displays help when no command is provided'
    When run script ./opkgscript.sh
    The output should include "Usage:"
  End

  Context 'generating script'
    setup() {
      echo "missing_package" > "$SHELLSPEC_TMPBASE/installed_list"
    }
    Before 'setup'

    It 'generates an install script from a list'
      Mock opkg
        if [ "$1" = "status" ]; then exit 1; fi
        if [ "$1" = "info" ]; then echo "Depends: libc"; fi
        exit 0
      End

      When run script ./opkgscript.sh script "$SHELLSPEC_TMPBASE/installed_list"
      The output should include "opkg install missing_package"
    End
  End
End