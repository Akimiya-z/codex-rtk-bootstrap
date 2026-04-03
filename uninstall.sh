#!/bin/sh
set -eu

codex_home="${CODEX_HOME:-$HOME/.codex}"
local_bin="${HOME}/.local/bin"
config_file="${codex_home}/config.toml"
agents_file="${codex_home}/AGENTS.md"
rtk_md="${codex_home}/RTK.md"
shim_path="${local_bin}/rtk-shim"
target_model_line="model_instructions_file = \"$rtk_md\""

if [ -f "$config_file" ] && /usr/bin/grep -Fxq "$target_model_line" "$config_file"; then
  tmp_config="${config_file}.tmp.$$"
  /usr/bin/awk -v line="$target_model_line" '
    $0 != line { print }
  ' "$config_file" > "$tmp_config"
  /bin/mv "$tmp_config" "$config_file"
fi

if [ -f "$agents_file" ] && /usr/bin/grep -Fxq '@RTK.md' "$agents_file"; then
  tmp_agents="${agents_file}.tmp.$$"
  /usr/bin/awk '
    $0 != "@RTK.md" { print }
  ' "$agents_file" > "$tmp_agents"
  /bin/mv "$tmp_agents" "$agents_file"
fi

/bin/rm -f "$shim_path"
for link in "$local_bin"/*; do
  [ -L "$link" ] || continue
  [ "$(/usr/bin/readlink "$link")" = "rtk-shim" ] || continue
  /bin/rm -f "$link"
done

printf '%s\n' "Removed Codex + RTK bootstrap links."
