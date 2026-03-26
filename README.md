# dotfiles

Personal dotfiles for a PHP/Python development environment on macOS. Built on [holman's dotfiles](https://github.com/holman/dotfiles) — topic-centric, `.symlink` convention, auto-loading `.zsh` files.

## stack

- **Shell**: zsh with [Starship](https://starship.rs) prompt
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
- **`topic/*.symlink`** — symlinked into `$HOME` as dotfiles by `script/bootstrap`
- **`bin/`** — scripts added to `$PATH`

## install

```sh
git clone https://github.com/matthiasseghers/dotfiles.git ~/dotfiles
cd ~/dotfiles
script/bootstrap
```

> The repo can be cloned anywhere — `$ZSH` is resolved dynamically from the symlink.

`script/bootstrap` will:
1. Set up symlinks for all `*.symlink` files
2. Prompt for your primary git identity (name + email → `~/.gitconfig.local`)
3. Optionally configure mackup (`~/.mackup.cfg`)

Then install Homebrew packages:

```sh
script/install
```

## machine-specific config

Two files are generated per machine and **never committed**:

| File | Purpose |
|---|---|
| `~/.gitconfig.local` | Primary git identity (name + email) |
| `~/.gitconfig.identities` | Folder-scoped git identities (`includeIf` rules) |
| `~/.mackup.cfg` | Mackup storage engine |
| `~/.localrc` | Machine-specific shell config (see `system/localrc.example`) |

To add shell config for the current machine only, create `~/.localrc`. See [system/localrc.example](system/localrc.example) for documented options.

## git identities

The primary identity is set during bootstrap. To add a folder-scoped identity at any time:

```sh
bin/git-add-identity
```

This creates `~/.gitconfig-<label>` and appends an `[includeIf]` block to `~/.gitconfig.identities`, so commits in that folder automatically use the right identity.

## after a fresh install

1. Run `script/bootstrap` then `script/install`
2. Run `pre-commit install` to enable local lint hooks
3. Run `uninstall_oh_my_zsh` if migrating from Oh My Zsh
4. Run `brew bundle cleanup --force` to remove unlisted packages
5. Enable 1Password SSH agent: Settings → Developer → Use the SSH agent
6. Set **MesloLGS Nerd Font** in your terminal: Preferences → Profiles → Text → Font
7. Source the new shell: `source ~/.zshrc`
