#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
codex_home="${CODEX_HOME:-$HOME/.codex}"
local_bin="${HOME}/.local/bin"
config_file="${codex_home}/config.toml"
agents_file="${codex_home}/AGENTS.md"
rtk_md="${codex_home}/RTK.md"
template_rtk_md="${repo_dir}/RTK.md"
shim_path="${local_bin}/rtk-shim"
commands="${RTK_SHIM_COMMANDS:-git gh cargo cat head tail grep rg ls find tree curl docker kubectl pytest ruff go tsc prettier pnpm npm npx pip node python python3 yarn make jq}"

if [ -n "${RTK_BIN:-}" ]; then
  if [ ! -x "$RTK_BIN" ]; then
    printf '%s\n' "RTK_BIN is set but not executable: $RTK_BIN" >&2
    exit 1
  fi
elif ! command -v rtk >/dev/null 2>&1; then
  cat >&2 <<'EOF'
rtk is not installed.
Install it first, then rerun this script.
Example:
  brew install rtk
EOF
  exit 1
fi

mkdir -p "$codex_home" "$local_bin"

if [ ! -f "$rtk_md" ]; then
  cp "$template_rtk_md" "$rtk_md"
fi

if [ ! -f "$agents_file" ]; then
  printf '# Codex instructions\n@RTK.md\n' > "$agents_file"
elif ! grep -q '^@RTK\.md$' "$agents_file"; then
  printf '\n@RTK.md\n' >> "$agents_file"
fi

model_line="model_instructions_file = \"$rtk_md\""
if [ ! -f "$config_file" ]; then
  printf '%s\n' "$model_line" > "$config_file"
elif ! grep -q '^[[:space:]]*model_instructions_file[[:space:]]*=' "$config_file"; then
  tmp_config="${config_file}.tmp.$$"
  awk -v line="$model_line" '
    BEGIN { inserted = 0 }
    {
      if (!inserted && $0 ~ /^[[:space:]]*\[/) {
        print line
        inserted = 1
      }
      print
    }
    END {
      if (!inserted) print line
    }
  ' "$config_file" > "$tmp_config"
  mv "$tmp_config" "$config_file"
fi

cat > "$shim_path" <<'EOF'
#!/bin/sh
set -eu

cmd=${0##*/}
case $0 in
  */*) shim_dir=${0%/*} ;;
  *) shim_dir=. ;;
esac

sanitize_path() {
  old_ifs=$IFS
  IFS=:
  new_path=
  for dir in $PATH; do
    if [ "$dir" = "$shim_dir" ]; then
      continue
    fi
    if [ -z "$new_path" ]; then
      new_path=$dir
    else
      new_path="$new_path:$dir"
    fi
  done
  IFS=$old_ifs
  printf '%s' "$new_path"
}

rtk_bin=${RTK_BIN:-}
if [ -z "$rtk_bin" ]; then
  for candidate in /opt/homebrew/bin/rtk /usr/local/bin/rtk; do
    if [ -x "$candidate" ]; then
      rtk_bin=$candidate
      break
    fi
  done
fi
if [ -z "$rtk_bin" ]; then
  rtk_bin=$(command -v rtk 2>/dev/null || true)
fi
if [ -z "$rtk_bin" ]; then
  printf '%s\n' 'rtk binary not found; set RTK_BIN or install rtk first.' >&2
  exit 127
fi

PATH=$(sanitize_path)
export PATH
exec "$rtk_bin" "$cmd" "$@"
EOF

chmod +x "$shim_path"

for name in $commands; do
  ln -sfn rtk-shim "$local_bin/$name"
done

printf '%s\n' "Installed Codex + RTK bootstrap."
printf '%s\n' "Restart the Codex app to pick up the new instructions."
