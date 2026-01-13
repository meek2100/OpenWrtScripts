# spec/spec_helper.sh
# shellcheck disable=SC2317

# 1. Enforce the environment (The Whole Context)
set -eu

# 2. Add the project root to PATH so scripts can be run without './' prefix if needed
#    and ensures mocked tools in current dir are found first if you add them.
export PATH="$(pwd):$PATH"

# 3. Define the load helper (Connects Library Parts to Tests)
load_lib() {
  # shellcheck disable=SC1090
  . "./lib/$1"
}
