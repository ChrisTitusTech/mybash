#!/usr/bin/env bash
# shellcheck disable=SC2030,SC2031 # HOME changes are intentionally isolated in test subshells.
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

grep -Fq "alias cat='batcat --paging=never --style=full'" "$ROOT/.bashrc" || fail 'missing batcat alias'
grep -Fq "alias cat='bat --paging=never --style=full'" "$ROOT/.bashrc" || fail 'missing bat fallback alias'

BAT_TEST_DIR="$TMPDIR/bat-test"
mkdir -p "$BAT_TEST_DIR"
cat >"$BAT_TEST_DIR/batcat" <<'EOF'
#!/bin/sh
printf 'args:%s\n' "$*"
cat
EOF
chmod +x "$BAT_TEST_DIR/batcat"
bat_output=$(PATH="$BAT_TEST_DIR:/usr/bin:/bin" HOME="$TMPDIR" bash --noprofile --rcfile "$ROOT/.bashrc" -ic 'printf payload | cat' 2>/dev/null)
[[ $bat_output == $'args:--paging=never --style=full\npayload' ]] || fail "interactive cat did not invoke batcat directly: $bat_output"

BAT_FALLBACK_DIR="$TMPDIR/bat-fallback-test"
mkdir -p "$BAT_FALLBACK_DIR"
cat >"$BAT_FALLBACK_DIR/bat" <<'EOF'
#!/bin/sh
printf 'args:%s\n' "$*"
/bin/cat
EOF
chmod +x "$BAT_FALLBACK_DIR/bat"
bat_fallback_output=$(PATH="$BAT_FALLBACK_DIR" HOME="$TMPDIR" /bin/bash --noprofile --rcfile "$ROOT/.bashrc" -ic 'printf payload | cat' 2>/dev/null)
[[ $bat_fallback_output == $'args:--paging=never --style=full\npayload' ]] || fail "cat alias did not invoke bat fallback correctly: $bat_fallback_output"

REAL_BAT=$(command -v batcat || command -v bat || true)
[[ -n $REAL_BAT ]] || fail 'batcat/bat is required for the rendering contract'
command -v script >/dev/null 2>&1 || fail 'script is required for the rendering contract'
RENDER_HOME="$TMPDIR/render-home"
mkdir -p "$RENDER_HOME/bin"
ln -s "$REAL_BAT" "$RENDER_HOME/bin/$(basename "$REAL_BAT")"
printf '%s\n' 'PING 192.168.88.1 (192.168.88.1)' '64 bytes from 192.168.88.1' >"$RENDER_HOME/ping.txt"
render_output=$(TERM=xterm-256color PATH="$RENDER_HOME/bin:/usr/bin:/bin" HOME="$RENDER_HOME" \
  script -qec "bash --noprofile --rcfile '$ROOT/.bashrc' -ic 'cat \"$RENDER_HOME/ping.txt\"'" /dev/null 2>/dev/null)
[[ $render_output == *'ping.txt'* ]] || fail 'interactive cat rendering lacks the bat file header'
[[ $render_output == *'1'*'PING 192.168.88.1'* ]] || fail 'interactive cat rendering lacks bat line numbers/grid'
[[ $render_output == *$'\033['* ]] || fail 'interactive cat rendering lacks terminal color escapes'

noninteractive_output=$(PATH="$BAT_TEST_DIR:/usr/bin:/bin" HOME="$TMPDIR" bash --noprofile -c '. "$1"; printf payload | cat' bash "$ROOT/.bashrc" 2>/dev/null)
[[ $noninteractive_output == payload ]] || fail "non-interactive cat behavior changed: $noninteractive_output"
bypass_output=$(PATH="$BAT_TEST_DIR:/usr/bin:/bin" HOME="$TMPDIR" bash --noprofile --rcfile "$ROOT/.bashrc" -ic 'printf payload | command cat' 2>/dev/null)
[[ $bypass_output == payload ]] || fail "command cat did not bypass the alias: $bypass_output"

LOGIN_HOME="$TMPDIR/login-home"
mkdir -p "$LOGIN_HOME"
printf '# existing profile\n' >"$LOGIN_HOME/.profile"
ln -s "$ROOT/.bashrc" "$LOGIN_HOME/.bashrc"
(
  export HOME="$LOGIN_HOME" MYBASH_SETUP_LIB_ONLY=1 PATH="$BAT_TEST_DIR:/usr/bin:/bin"
  # shellcheck source=/dev/null
  . "$ROOT/setup.sh"
  # shellcheck disable=SC2034 # Consumed by the sourced setup function.
  OS_NAME=Linux
  ensure_login_profile_sources_bashrc
  ensure_login_profile_sources_bashrc
)
# shellcheck disable=SC2016 # Match the literal profile command.
grep -Fq '. "$HOME/.bashrc"' "$LOGIN_HOME/.profile" || fail 'Linux login profile does not source .bashrc'
# shellcheck disable=SC2016 # Match the literal profile command.
[[ $(grep -Fc '. "$HOME/.bashrc"' "$LOGIN_HOME/.profile") -eq 1 ]] || fail 'login profile sources .bashrc more than once'
/bin/sh -c '. "$1"' sh "$LOGIN_HOME/.profile" >/dev/null 2>&1 || fail 'generated .profile is unsafe for non-Bash shells'

PROFILE_HOME="$TMPDIR/bash-profile-home"
mkdir -p "$PROFILE_HOME"
# shellcheck disable=SC2016 # Write the literal ${HOME} profile form.
printf '%s\n' '. "${HOME}/.bashrc"' >"$PROFILE_HOME/.bash_profile"
(
  export HOME="$PROFILE_HOME" MYBASH_SETUP_LIB_ONLY=1
  # shellcheck source=/dev/null
  . "$ROOT/setup.sh"
  # shellcheck disable=SC2034 # Consumed by the sourced setup function.
  OS_NAME=Linux
  ensure_login_profile_sources_bashrc
)
[[ $(grep -c '\.bashrc' "$PROFILE_HOME/.bash_profile") -eq 1 ]] || fail 'existing bash profile received a duplicate .bashrc source block'
[[ ! -e $PROFILE_HOME/.profile ]] || fail 'setup ignored existing .bash_profile precedence'

VERIFY_HOME="$TMPDIR/verify-home"
mkdir -p "$VERIFY_HOME/bin"
cat >"$VERIFY_HOME/bin/batcat" <<'EOF'
#!/bin/sh
exit 0
EOF
cat >"$VERIFY_HOME/bin/bash" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >"$HOME/bash-args"
printf "%s\n" "alias cat='batcat --paging=never --style=full'" >&3
EOF
chmod +x "$VERIFY_HOME/bin/batcat" "$VERIFY_HOME/bin/bash"
(
  export HOME="$VERIFY_HOME" MYBASH_SETUP_LIB_ONLY=1 PATH="$VERIFY_HOME/bin:/usr/bin:/bin"
  # shellcheck source=/dev/null
  . "$ROOT/setup.sh"
  verify_interactive_cat_alias >/dev/null
)
grep -Fq -- '--login -ic alias cat >&3' "$VERIFY_HOME/bash-args" || fail 'alias verification did not use a login shell'

printf 'Shell integration tests passed.\n'