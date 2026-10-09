# dotfiles

Personal dotfiles for a Python development environment on macOS (PHP tooling lives in the optional `work` [app group](#app-groups)). Built on [holman's dotfiles](https://github.com/holman/dotfiles) — topic-centric, `.symlink` convention, auto-loading `.zsh` files.

> [!NOTE]
> These are my personal dotfiles, tuned to my machines and workflow - they will not fit your setup one-size-fits-all. Think of them as a starting point: fork it, remove what you don't use, and build on what you do.

## stack

- **Shell**: zsh with [Starship](https://starship.rs) prompt
- **History**: [Atuin](https://atuin.sh) — shell history sync across machines
- **Navigation & search**: [zoxide](https://github.com/ajeetdsouza/zoxide) (`z`), [fzf](https://github.com/junegunn/fzf) (Ctrl-T file picker)
- **Diffs**: [git-delta](https://github.com/dandavison/delta) — side-by-side, syntax-highlighted git diffs
- **Version management**: [mise](https://mise.jdx.dev) — Python, Node per project (prebuilt binaries)
- **PHP versions** (work group): [PHP Monitor](https://phpmon.app) — Homebrew-based PHP switching (mise only offers source-compiled PHP)
- **Docker**: [OrbStack](https://orbstack.dev)
- **SSH**: 1Password SSH agent — no key files on disk
- **App settings backup**: [Mackup](https://github.com/lra/mackup) — copy mode, whitelisted apps only
- **Editor**: VS Code
- **Terminals**: Ghostty

## structure

Everything is topic-centric. Each folder is a subject area — `git/`, `php/`, `docker/`, etc.

- **`topic/*.zsh`** — loaded automatically into every shell session
- **`topic/path.zsh`** — loaded first (for `$PATH` setup)
- **`topic/completion.zsh`** — loaded last (for autocomplete)
- **`topic/*.symlink`** — symlinked into `$HOME` as `~/.<name>` by `script/bootstrap`
- **`topic/config/**`** — symlinked into `~/.config/<topic>/` by `script/bootstrap`
- **`topic/install.sh`** — run by `script/install` for actual software installation
- **`bin/`** — scripts added to `$PATH`
- **`1password/functions.zsh`** — optional `local-backup` / `local-restore` shell functions (see [secrets backup](#secrets-backup-optional-1password)); loaded only when the `op` CLI is installed

## install

```sh
git clone https://github.com/matthiasseghers/dotfiles.git ~/dotfiles
cd ~/dotfiles
script/bootstrap
```

> **Fresh Mac**: a new Mac has no `git` yet. Running `git clone` triggers the Xcode Command Line Tools install prompt — accept it, wait for the install to finish, then re-run the clone.

> The repo can be cloned anywhere — `$ZSH` is resolved dynamically from the symlink.

`script/bootstrap` will:
1. Prompt for your primary git identity (name + email → `~/.gitconfig.local`)
2. Set up symlinks for all `*.symlink` files into `$HOME` and all `topic/config/**` files into `~/.config/`
3. Apply macOS defaults and prompt for hostname
4. Install Homebrew and all packages from `Brewfile` plus your `DOTFILES_GROUPS` app groups

> **Fresh-install caveat**: the `work` group taps `nicoverbruggen/cask` (for PHP Monitor), which Homebrew treats as an untrusted third-party tap. If `brew bundle` refuses the `phpmon` cask, run `brew trust nicoverbruggen/cask` once and re-run.

## staying up to date

Run `dot` periodically (it's on your `$PATH` via `bin/`):

```sh
dot
```

This pulls the dotfiles repo (skipped if you have uncommitted changes), runs `brew update && brew upgrade`, and installs anything new from the `Brewfile`, your `DOTFILES_GROUPS` group files, and the `topic/install.sh` scripts. `dot -e` opens the dotfiles directory in your editor.

## app groups

Apps are split across plain Brewfiles — one shared file every Mac gets, plus one file per optional group:

| File | Contents |
|---|---|
| `Brewfile` | Shared CLI tools + apps (every Mac) |
| `Brewfile.work` | PHP tooling, work apps |
| `Brewfile.personal` | Games, media, personal apps |

Pick your groups per machine in `~/.localrc` (space- or comma-separated):

```sh
export DOTFILES_GROUPS="work personal"
```

- **Unset** → only the shared `Brewfile` is installed.
- **Adding a group later** = edit the line, open a new shell (or `source ~/.localrc`), run `dot`. Nothing is reset — what's installed stays.
- **Nothing is ever uninstalled automatically**: removing an app from a Brewfile leaves it on disk; remove apps by hand.
- **New group** = create `Brewfile.<name>` in the repo root; it becomes available immediately.
- **Typos** in `DOTFILES_GROUPS` are reported by `dot` (via `script/install`) and `dot-doctor` before anything is installed.
- A group exists iff `Brewfile.<name>` exists. Each app appears in exactly one file, and taps sit in the same file as the formulae/casks that need them.

## ~/.config/ files

Files placed under `topic/config/` are symlinked into `~/.config/<topic>/` by `script/bootstrap`, preserving their path structure. This is the convention for any config that belongs under `~/.config/` rather than `$HOME`.

For example:

```
atuin/config/config.toml  →  ~/.config/atuin/config.toml
mise/config/config.toml   →  ~/.config/mise/config.toml
```

Not all tools follow this convention. SSH expects `~/.ssh/config` (outside `~/.config/` entirely), so `ssh/install.sh` creates that symlink via holman's `install.sh` mechanism (`script/install` runs every topic `install.sh`).

Starship uses `STARSHIP_CONFIG` (set in `starship/env.zsh`) to point to `~/.config/starship/starship.toml`, so it fits the automatic convention.

Files keep their original names and extensions in the repo, so editor tooling (syntax highlighting, schema validation) works correctly.

## machine-specific config

These files are generated per machine and **never committed**:

| File | Purpose | How it comes back after a reinstall |
|---|---|---|
| `~/.gitconfig.local` | Primary git identity (name + email) | `script/bootstrap` prompt |
| `~/.gitconfig.identities` (+ `~/.gitconfig-*`) | Folder-scoped git identities (`includeIf` rules) | `bin/git-add-identity` |
| `~/.ssh/config.local` | Machine-specific SSH hosts/overrides | `local-restore`, or your own password manager |
| `~/.localrc` | Machine-specific shell config, incl. `DOTFILES_GROUPS` app groups | `local-restore`, or your own password manager |
| `~/.config/mackup/mackup.cfg` | Mackup storage location + app whitelist (linked from `mackup/config/mackup.cfg`) | comes with the repo; per-machine override via `~/.mackup.cfg` |
| `~/.config/1Password/ssh/agent.toml` | 1Password SSH agent config | `local-restore`, or your own password manager |
| `~/.local/share/atuin/key` | Atuin history-sync encryption key | `local-restore`, or your own password manager |

To add shell config for the current machine only, create `~/.localrc`.

## app settings (Mackup)

[Mackup](https://github.com/lra/mackup) backs up **app-written** settings and data (preferences, databases, save files) to a synced folder. The ownership rule:

- **dotfiles own hand-written plain-text config** (anything in this repo)
- **Mackup owns app-written prefs/data** — never both for the same file

Rules:

- **Copy mode only**: run `mackup backup` / `mackup restore`. **Never run `mackup link`** — it replaces app files with symlinks and corrupts preferences on macOS 14+.
- **Whitelist only**: `mackup/config/mackup.cfg` (linked to `~/.config/mackup/mackup.cfg`) lists exactly which apps are backed up. Without the whitelist Mackup backs up *every* supported app — including ssh, git, zsh and vim — which would fight the dotfiles symlinks and copy `~/.ssh` to cloud storage.
- **Storage is per machine**: the linked config defaults to `~/Mackup` (local-only, `dot-doctor` warns). If a machine's storage differs (a synced folder, a different provider), create `~/.mackup.cfg` on that machine — Mackup prefers it over the linked config.
- **Storage**: `script/bootstrap` asks where backups should live. `~/Mackup` works but is only a real backup if that folder is synced; a folder under `~/Library/CloudStorage/` (Proton Drive, MEGA, …) is synced by construction — mark it **"Available offline"**, because cloud-file providers otherwise leave online-only placeholders Mackup cannot restore from.
- **Custom apps**: add a `.cfg` under `mackup/config/applications/` in this repo; `script/bootstrap` links it to `~/.config/mackup/applications/` where Mackup picks it up. Paths are relative to `$HOME` (`[configuration_files]`) or to `~/.config` (`[xdg_configuration_files]`). Check `mackup show <app>` to see what will be backed up.
- **Raycast**: only the plist and plain config files are synced. Raycast's real data (snippets, quicklinks, hotkeys) lives in an encrypted local database that does not restore usefully — for a full backup use Raycast's own **Settings → Advanced → Export** (`.rayconfig` file).

## secrets backup (optional, 1Password)

If the [1Password CLI](https://developer.1password.com/docs/cli/) (`op`) is installed, `1password/functions.zsh` adds two functions for the machine-local secret files from the table above (`~/.localrc`, `~/.ssh/config.local`, `~/.config/1Password/ssh/agent.toml`, the Atuin key):

```sh
local-backup            # pack existing files into one tgz Document in 1Password
local-restore           # restore this machine's backup into $HOME
local-restore "dotfiles: other-machine"   # restore another machine's backup
```

- The Document is titled `dotfiles: <hostname>`; override with `DOTFILES_BACKUP_NAME`.
- Restored secret files are chmod 600. `local-restore` never overwrites existing files (`tar -k`) — move them aside first.
- Without 1Password, back up those files yourself (password manager, encrypted archive, …).
- **Secrets never go into Mackup** — the Mackup whitelist deliberately excludes ssh, git and shell configs.

## git identities

The primary identity is set during bootstrap. If you only ever commit as one identity, that's all you need — the machinery below is optional and silently ignored when unused.

To add a folder-scoped identity (e.g. different author for work projects):

```sh
bin/git-add-identity
```

This creates `~/.gitconfig-<label>` and appends an `[includeIf]` block to `~/.gitconfig.identities`, so commits under that folder automatically use the right identity. The script refuses duplicate labels and non-existent folders — both would otherwise fail silently.

> **Note**: this scopes *commit authorship* (name/email), not SSH authentication or signing. If your identities use different SSH keys in 1Password, select the right key per host in `~/.ssh/config.local`.

## after a fresh install

1. Install Xcode Command Line Tools / clone the repo (see [install](#install)), then run `script/bootstrap` — it prompts for your git identity, symlinks everything, asks where Mackup should store backups, and installs Homebrew + the Brewfile
2. Open 1Password (installed by the Brewfile), sign in, and enable the SSH agent and CLI integration: Settings → Developer → *Use the SSH agent* + *Connect with 1Password CLI*
3. `local-restore` — brings back `~/.localrc`, `~/.ssh/config.local`, the 1Password agent config and the Atuin key (needs step 2's CLI integration); then open a new terminal and run `dot` again to install your app groups
4. Sign in to your sync service (the Mackup storage folder), let it finish syncing, then run `mackup restore` — never `mackup link`
5. `atuin login` — the encryption key came back in step 3, so history sync just works
6. `pre-commit install` — enable the local lint hooks
7. Fonts come from `ghostty/config/config` (MesloLGS Nerd Font) — nothing to set by hand
8. Optionally `bin/git-add-identity` if this machine needs folder-scoped git identities (e.g. work)
9. Install the Mac App Store apps listed in the Brewfile comment block (they can't be automated)
10. `dot-doctor` — verify everything is linked and healthy
