# Codex App + RTK Bootstrap

This repo is a macOS user-level bootstrap that makes new Codex App sessions prefer RTK for supported shell commands.

It does not change your project code. It only installs user-scoped Codex config and command shims.

## What it installs

- `~/.codex/RTK.md`
- `~/.codex/AGENTS.md` with an `@RTK.md` reference
- `~/.codex/config.toml` with `model_instructions_file`
- `~/.local/bin/rtk-shim`
- command shims in `~/.local/bin` for common RTK-supported commands

## How it works

1. Codex reads `~/.codex/RTK.md` as a model instruction file.
2. Your shell resolves common command names from `~/.local/bin` first.
3. The shim forwards supported commands through `rtk`.
4. `rtk` compresses the output before Codex sees it.

## Requirements

- macOS
- Codex desktop app
- `rtk` installed locally
- `~/.local/bin` should be on `PATH` and come before the system command paths

If you need to add it:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

## Install

```bash
./install.sh
```

If you want a different RTK binary path, set `RTK_BIN` first.

If you want to change which command names are shimmed, set `RTK_SHIM_COMMANDS`.

## Uninstall

```bash
./uninstall.sh
```

## Notes

- This setup is user-local, not repo-local.
- New Codex app sessions will pick up the RTK instructions and the PATH shims.
- The repo does not change your existing project files.
- If you already have a different `model_instructions_file` in `~/.codex/config.toml`, merge it manually before running the installer.

## Who this is for

- People using the Codex desktop app on macOS who want the RTK command pipeline without configuring it by hand.
- People who want a repeatable install script they can run on a fresh Mac.
