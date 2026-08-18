# dotfiles

Personal dotfiles for a PHP/Python development environment on macOS. Built on [holman's dotfiles](https://github.com/holman/dotfiles) — topic-centric, `.symlink` convention, auto-loading `.zsh` files.

## stack

- **Shell**: zsh with [Starship](https://starship.rs) prompt
- **History**: [Atuin](https://atuin.sh) — shell history sync across machines
- **Version management**: [mise](https://mise.jdx.dev) — Python, Node per project (prebuilt binaries)
- **PHP versions**: [PHP Monitor](https://phpmon.app) — Homebrew-based PHP switching (mise only offers source-compiled PHP)
- **Docker**: [OrbStack](https://orbstack.dev)
- **SSH**: 1Password SSH agent — no key files on disk
- **Editor**: VS Code
- **Terminals**: Ghostty + iTerm2

## structure

Everything is topic-centric. Each folder is a subject area — `git/`, `php/`, `docker/`, etc.

- **`topic/*.zsh`** — loaded automatically into every shell session
- **`topic/path.zsh`** — loaded first (for `$PATH` setup)
- **`topic/completion.zsh`** — loaded last (for autocomplete)
- **`topic/*.symlink`** — symlinked into `$HOME` as `~/.<name>` by `script/bootstrap`
- **`topic/config/**`** — symlinked into `~/.config/<topic>/` by `script/bootstrap`
- **`topic/config.sh`** — run by `script/install` for edge-case symlinks (non-standard destinations)
- **`topic/install.sh`** — run by `script/install` for actual software installation
- **`bin/`** — scripts added to `$PATH`

## install

```sh
git clone https://github.com/matthiasseghers/dotfiles.git ~/dotfiles
cd ~/dotfiles
script/bootstrap
```

> The repo can be cloned anywhere — `$ZSH` is resolved dynamically from the symlink.

`script/bootstrap` will:
1. Prompt for your primary git identity (name + email → `~/.gitconfig.local`)
2. Set up symlinks for all `*.symlink` files into `$HOME` and all `topic/config/**` files into `~/.config/`
3. Apply macOS defaults and prompt for hostname
4. Install Homebrew and all packages from `Brewfile`

> **Fresh-install caveat**: the Brewfile taps `nicoverbruggen/cask` (for PHP Monitor), which Homebrew treats as an untrusted third-party tap. If `brew bundle` refuses the `phpmon` cask, run `brew trust nicoverbruggen/cask` once and re-run.

## staying up to date

Run `dot` periodically (it's on your `$PATH` via `bin/`):

```sh
dot
```

This pulls the dotfiles repo (skipped if you have uncommitted changes), runs `brew update && brew upgrade`, and installs anything new from the `Brewfile` and `topic/install.sh` scripts. `dot -e` opens the dotfiles directory in your editor.

## ~/.config/ files

Files placed under `topic/config/` are symlinked into `~/.config/<topic>/` by `script/bootstrap`, preserving their path structure. This is the convention for any config that belongs under `~/.config/` rather than `$HOME`.

For example:

```
atuin/config/config.toml  →  ~/.config/atuin/config.toml
mise/config/config.toml   →  ~/.config/mise/config.toml
```

Not all tools follow this convention. SSH expects `~/.ssh/config` (outside `~/.config/` entirely), so it uses `ssh/config.sh` to create that symlink.

Starship uses `STARSHIP_CONFIG` (set in `starship/env.zsh`) to point to `~/.config/starship/starship.toml`, so it fits the automatic convention.

Files keep their original names and extensions in the repo, so editor tooling (syntax highlighting, schema validation) works correctly.

## machine-specific config

These files are generated per machine and **never committed**:

| File | Purpose |
|---|---|
| `~/.gitconfig.local` | Primary git identity (name + email) |
| `~/.gitconfig.identities` | Folder-scoped git identities (`includeIf` rules) |
| `~/.ssh/config.local` | Machine-specific SSH hosts/overrides |
| `~/.localrc` | Machine-specific shell config |

To add shell config for the current machine only, create `~/.localrc`.

## git identities

The primary identity is set during bootstrap. If you only ever commit as one identity, that's all you need — the machinery below is optional and silently ignored when unused.

To add a folder-scoped identity (e.g. different author for work projects):

```sh
bin/git-add-identity
```

This creates `~/.gitconfig-<label>` and appends an `[includeIf]` block to `~/.gitconfig.identities`, so commits under that folder automatically use the right identity. The script refuses duplicate labels and non-existent folders — both would otherwise fail silently.

> **Note**: this scopes *commit authorship* (name/email), not SSH authentication or signing. If your identities use different SSH keys in 1Password, select the right key per host in `~/.ssh/config.local`.

## after a fresh install

1. Run `script/bootstrap`
2. Run `pre-commit install` to enable local lint hooks
3. Enable 1Password SSH agent: Settings → Developer → Use the SSH agent
4. Add SSH keys in 1Password; copy public keys where needed
5. Set **MesloLGS Nerd Font** in your terminal: Preferences → Profiles → Text → Font
6. Optionally run `bin/git-add-identity` if this machine needs folder-scoped git identities (e.g. work)
7. Source the new shell: `source ~/.zshrc`
