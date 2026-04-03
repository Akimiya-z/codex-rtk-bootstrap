#!/bin/sh
set -eu

codex_home="${CODEX_HOME:-$HOME/.codex}"
local_bin="${HOME}/.local/bin"
config_file="${codex_home}/config.toml"
agents_file="${codex_home}/AGENTS.md"
rtk_md="${codex_home}/RTK.md"
shim_path="${local_bin}/rtk-shim"
commands="${RTK_SHIM_COMMANDS:-git gh cargo cat head tail grep rg ls find tree curl docker kubectl pytest ruff go tsc prettier pnpm npm npx pip node python python3 yarn make jq}"
target_model_line="model_instructions_file = \"$rtk_md\""

if [ -f "$config_file" ] && grep -Fxq "$target_model_line" "$config_file"; then
  tmp_config="${config_file}.tmp.$$"
  awk -v line="$target_model_line" '
    $0 != line { print }
  ' "$config_file" > "$tmp_config"
  mv "$tmp_config" "$config_file"
fi

if [ -f "$agents_file" ] && grep -Fxq '@RTK.md' "$agents_file"; then
  tmp_agents="${agents_file}.tmp.$$"
  awk '
    $0 != "@RTK.md" { print }
  ' "$agents_file" > "$tmp_agents"
  mv "$tmp_agents" "$agents_file"
fi

rm -f "$shim_path"
for name in $commands; do
  rm -f "$local_bin/$name"
done

printf '%s\n' "Removed Codex + RTK bootstrap links."
