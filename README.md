# dotfiles

Personal dotfiles for a PHP/Python development environment on macOS. Built on [holman's dotfiles](https://github.com/holman/dotfiles) — topic-centric, `.symlink` convention, auto-loading `.zsh` files.

## stack

- **Shell**: zsh with [Starship](https://starship.rs) prompt
- **History**: [Atuin](https://atuin.sh) — shell history sync across machines
- **Version management**: [mise](https://mise.jdx.dev) — PHP, Python, Node per project
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

## ~/.config/ files

Files placed under `topic/config/` are symlinked into `~/.config/<topic>/` by `script/bootstrap`, preserving their path structure. This is the convention for any config that belongs under `~/.config/` rather than `$HOME`.

For example:

```
atuin/config/config.toml  →  ~/.config/atuin/config.toml
mise/config/config.toml   →  ~/.config/mise/config.toml
```

Not all tools follow this convention. Starship expects `~/.config/starship.toml` (flat, not in a subdirectory), so it uses `starship/config.sh` to create that symlink — the same pattern as `ssh/config.sh` for `~/.ssh/config`.

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

The primary identity is set during bootstrap. To add a folder-scoped identity at any time:

```sh
bin/git-add-identity
```

This creates `~/.gitconfig-<label>` and appends an `[includeIf]` block to `~/.gitconfig.identities`, so commits in that folder automatically use the right identity.

## after a fresh install

1. Run `script/bootstrap`
2. Run `pre-commit install` to enable local lint hooks
3. Enable 1Password SSH agent: Settings → Developer → Use the SSH agent
4. Add SSH keys in 1Password; copy public keys where needed
5. Set **MesloLGS Nerd Font** in your terminal: Preferences → Profiles → Text → Font
6. Run `bin/git-add-identity` to add folder-scoped git identities (e.g. work)
7. Source the new shell: `source ~/.zshrc`
