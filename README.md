# dotfiles

Personal dotfiles for a Python development environment on macOS (PHP tooling lives in the optional `work` [app group](#app-groups)). Built on [holman's dotfiles](https://github.com/holman/dotfiles) — topic-centric, `.symlink` convention, auto-loading `.zsh` files. See [credits](#credits).

> [!WARNING]
> These are my personal dotfiles, tuned to my machines and workflow — not a framework, and not supported as one. "Works on my machine" is literal: read [what this assumes](#what-this-assumes) before running `script/bootstrap`, and fork the repo rather than adapting your machine to it.

## what this assumes

- **macOS**, Apple Silicon or Intel (the Homebrew prefix is detected, not assumed), with Xcode Command Line Tools
- **zsh** as the login shell
- **1Password** is recommended but optional: it provides the SSH agent and, with the CLI, `local-backup` / `local-restore`. Without it you need another password manager for the machine-local files below
- **`sudo`** during bootstrap: applying security defaults and fixing the hostname need admin rights
- **Consent to macOS defaults**: `macos/set-defaults.sh` changes Finder, Dock, keyboard and trackpad settings; `macos/set-security-defaults.sh` requires a password immediately after screen lock

CI runs lint on every push and a clean `brew bundle` install on a macOS runner monthly (`.github/workflows/`). That proves the repo is coherent — not that it fits your machine.

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
- **Editor**: VS Code (a `vim/` config ships as well)
- **Terminal**: Ghostty

## structure

Everything is topic-centric. Each folder is a subject area — `git/`, `php/`, `docker/`, etc.

- **`topic/*.zsh`** — loaded automatically into every shell session
- **`topic/path.zsh`** — loaded first (for `$PATH` setup)
- **`topic/completion.zsh`** — loaded last (for autocomplete)
- **`topic/*.symlink`** — symlinked into `$HOME` as `~/.<name>` by `script/bootstrap`
- **`topic/config/**`** — symlinked into `~/.config/<topic>/` by `script/bootstrap`
- **`topic/install.sh`** — run by `script/install` for actual software installation
- **`bin/`** — scripts added to `$PATH`
- **`script/`** — `bootstrap`, `install`, `uninstall`, and the lint checks used by pre-commit
- **`1password/functions.zsh`** — optional `local-backup` / `local-restore` shell functions (see [machine-local backup](#machine-local-backup-optional-1password)); loaded only when the `op` CLI is installed

## install

```sh
git clone https://github.com/matthiasseghers/dotfiles.git ~/dotfiles
cd ~/dotfiles
cp system/localgroups.example ~/.localgroups   # then uncomment `work` or `personal`
$EDITOR ~/.localgroups
script/bootstrap
```

Create `~/.localgroups` **before** the first bootstrap: it is what tells `script/install` which app group this machine wants, so the shared `Brewfile` and that group's `Brewfile.<group>` install in one pass. Skip it and you get the shared apps only — `dot` installs the group later. Leave it with no active line for shared-only.

> **Fresh Mac**: a new Mac has no `git` yet. Running `git clone` triggers the Xcode Command Line Tools install prompt — accept it, wait for the install to finish, then re-run the clone.

> The repo can be cloned anywhere — `$ZSH` is resolved dynamically from the symlink.

`script/bootstrap` will:
1. Prompt for your primary git identity (name + email → `~/.gitconfig.local`)
2. Symlink every `*.symlink` file into `$HOME` and every `topic/config/**` file into `~/.config/` — if a target already exists it asks `[s]kip / [o]verwrite / [b]ackup` (`b` moves the old file to `<name>.backup`)
3. Apply macOS defaults (some need `sudo`), apply security defaults, and fix a hostname macOS mangled — it does **not** prompt for a hostname
4. Install Homebrew and all packages from `Brewfile` plus the app group selected in `~/.localgroups`, then ask whether to restart

> **After bootstrap, switch the remote to SSH.** `dot` only auto-pulls SSH remotes, so the HTTPS clone above never updates itself:
> ```sh
> git -C ~/dotfiles remote set-url origin git@github.com:matthiasseghers/dotfiles.git
> ```
> Do this once the 1Password SSH agent works ([step 2](#after-a-fresh-install)) — a fresh Mac has no key yet, which is why the clone is HTTPS.

> **Fresh-install caveat**: the `work` group taps `nicoverbruggen/cask` (for PHP Monitor), which Homebrew treats as an untrusted third-party tap. If `brew bundle` refuses the `phpmon` cask, run `brew trust nicoverbruggen/cask` once and re-run.

## moving to a new Mac

The order matters, because three things cannot be recreated from the repo: the 1Password bundle, app-written settings (Mackup) and anything you forgot to push.

**On the old machine:**

1. `dot-doctor` — fix what it fails first, so you migrate a known-good state
2. `local-backup` — packs `~/.localrc`, the SSH overrides, the 1Password agent config, the Atuin key and the git identities into one Document titled `dotfiles: <hostname>`
3. `mackup backup` — app settings and data
4. Push every branch you care about (including work-in-progress) and note unpushed stashes
5. Note the Mac App Store apps (the comment block at the end of `Brewfile`) — they cannot be automated

**On the new machine:** follow [after a fresh install](#after-a-fresh-install). Three ordering constraints:

- `~/.localgroups` must exist **before** `script/bootstrap`, or the group's apps are skipped on the first pass
- 1Password must be signed in **before** `local-restore`
- the sync service must have finished syncing **before** `mackup restore`

## staying up to date

Run `dot` periodically (it's on your `$PATH` via `bin/`):

```sh
dot
```

This pulls the dotfiles repo (skipped if you have uncommitted changes **or if the remote is HTTPS** — see [install](#install)), runs `brew update && brew upgrade`, and installs anything new from the `Brewfile`, the group selected in `~/.localgroups`, and the `topic/install.sh` scripts. `dot -e` opens the dotfiles directory in your editor.

## app groups

Apps are split across plain Brewfiles — one shared file every Mac gets, plus one file per optional group:

| File | Contents |
|---|---|
| `Brewfile` | Shared CLI tools + apps (every Mac) |
| `Brewfile.work` | PHP tooling, work apps |
| `Brewfile.personal` | Games, media, personal apps |

Pick your group per machine in `~/.localgroups` (one line, space- or comma-separated):

```sh
# ~/.localgroups
work
```

`system/localgroups.example` is a commented template — copy it and uncomment the line you want. Create it **before** the first `script/bootstrap` so the group's apps install in the same pass; add or change it later and `dot` installs them. `$DOTFILES_GROUPS` still works as a one-off override (and is what CI uses):

```sh
DOTFILES_GROUPS="work" dot
```

- **No active line** (no file, empty file, or everything commented) → only the shared `Brewfile` is installed.
- **Adding a group later** = edit `~/.localgroups` and run `dot`. Nothing is reset — what's installed stays.
- **Nothing is ever uninstalled automatically**: removing an app from a Brewfile leaves it on disk; remove apps by hand.
- **New group** = create `Brewfile.<name>` in the repo root; it becomes available immediately.
- **Typos** in the selection are reported by `dot` (via `script/install`) and `dot-doctor` before anything is installed.
- A group exists iff `Brewfile.<name>` exists. Each app appears in exactly one file (enforced by the `no-duplicate-brewfile-entries` pre-commit hook), and taps sit in the same file as the formulae/casks that need them.

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

These files are per machine and **never committed**:

| File | Purpose | How it comes back after a reinstall |
|---|---|---|
| `~/.gitconfig.local` | Primary git identity (name + email) | `script/bootstrap` prompt |
| `~/.gitconfig.identities` (+ `~/.gitconfig-*`) | Folder-scoped git identities (`includeIf` rules) | `local-restore` (backed up), or `bin/git-add-identity` |
| `~/.ssh/config.local` | Machine-specific SSH hosts/overrides | `local-restore`, or your own password manager |
| `~/.localgroups` | App group for this machine (`work`, `personal`, …) | you create it: `cp system/localgroups.example ~/.localgroups` — **not backed up** |
| `~/.localrc` | Machine-specific shell config (secrets, env) | `local-restore`, or your own password manager |
| `~/.config/mackup/mackup.cfg` | Mackup storage + app whitelist (linked from `mackup/config/mackup.cfg`) | comes with the repo; per-machine storage via a symlinked `~/Mackup` |
| `~/.config/1Password/ssh/agent.toml` | 1Password SSH agent config | `local-restore`, or your own password manager |
| `~/.local/share/atuin/key` | Atuin history-sync encryption key | `local-restore`, or your own password manager |

To add shell config for the current machine only, create `~/.localrc`. To pick this machine's app group, create `~/.localgroups` (see [app groups](#app-groups)).

> **Where `~/.localrc` stops**: it is sourced *before* the repo's `*.zsh` files (`zsh/zshrc.symlink:8`), so it is the right place for environment variables and secrets — but an alias or function defined there loses to the repo's own. For a permanent behaviour change, edit the repo (fork it) instead.

## app settings (Mackup)

[Mackup](https://github.com/lra/mackup) backs up **app-written** settings and data (preferences, databases, save files) to a synced folder. The ownership rule:

- **dotfiles own hand-written plain-text config** (anything in this repo)
- **Mackup owns app-written prefs/data** — never both for the same file

Rules:

- **Copy mode only**: run `mackup backup` / `mackup restore`. **Never run `mackup link`** — it replaces app files with symlinks and corrupts preferences on macOS 14+.
- **Whitelist only**: `mackup/config/mackup.cfg` (linked to `~/.config/mackup/mackup.cfg`) lists exactly which apps are backed up. A missing *or empty* `[applications_to_sync]` means "back up everything" — including ssh, git, zsh and vim — which fights the dotfiles symlinks and copies `~/.ssh` to cloud storage.
- **Storage is per machine, and nothing prompts for it**: the linked config resolves to `~/Mackup`, which is local-only until you point it at a synced folder:
  ```sh
  mkdir -p "$HOME/Library/CloudStorage/<provider>/Mackup"
  ln -s "$HOME/Library/CloudStorage/<provider>/Mackup" "$HOME/Mackup"
  ```
  One committed config then serves every machine, and `dot-doctor` reports whether the resolved folder is synced. Mark the folder **"Available offline"** — cloud-file providers otherwise leave online-only placeholders Mackup cannot restore from.
- **Never create a partial `~/.mackup.cfg`**: Mackup reads exactly one config file (`~/.mackup.cfg` → `$MACKUP_CONFIG` → `~/.config/mackup/mackup.cfg`) and does not merge them. A storage-only override silently drops the whitelist and `mackup backup` copies `~/.ssh` to the cloud. If you must override, repeat the whole file.
- **Custom apps**: add a `.cfg` under `mackup/config/applications/` in this repo; `script/bootstrap` links it to `~/.config/mackup/applications/` where Mackup picks it up. Paths are relative to `$HOME` (`[configuration_files]`) or to `~/.config` (`[xdg_configuration_files]`). Check `mackup show <app>` to see what will be backed up.
- **Raycast**: only the plist and plain config files are synced. Raycast's real data (snippets, quicklinks, hotkeys) lives in an encrypted local database that does not restore usefully — for a full backup use Raycast's own **Settings → Advanced → Export** (`.rayconfig` file).

## machine-local backup (optional, 1Password)

If the [1Password CLI](https://developer.1password.com/docs/cli/) (`op`) is installed, `1password/functions.zsh` adds two functions for the machine-local files from the table above (`~/.localrc`, `~/.ssh/config.local`, `~/.config/1Password/ssh/agent.toml`, the Atuin key, and the git identity files `~/.gitconfig.identities` + `~/.gitconfig-<label>`):

```sh
local-backup            # pack existing files into one tgz Document in 1Password
local-restore           # restore this machine's backup into $HOME
local-restore "dotfiles: other-machine"   # restore another machine's backup
```

- The Document is titled `dotfiles: <hostname>`; override with `DOTFILES_BACKUP_NAME`.
- The file list lives in `script/lib/machine-local.sh` — `dot-doctor` reads the same file, so the two cannot drift.
- `~/.localgroups` is deliberately **not** in the bundle: it is not a secret, and `op` only exists after bootstrap has already run — so the group's apps could never be installed from a restore. Create it by hand before bootstrap.
- `~/.gitconfig.local` is deliberately **not** in the bundle either: `script/bootstrap` regenerates it from the name/email prompt.
- The Mackup storage folder (`~/Mackup` or its symlink target) is **not** in the bundle — it is app data, backed up by Mackup.
- Restored files are chmod 600. `local-restore` never overwrites existing files (`tar -k`) — move them aside first.
- Without 1Password, back up those files yourself (password manager, encrypted archive, …).
- **Secrets never go into Mackup** — the Mackup whitelist deliberately excludes ssh, git and shell configs.

## git identities

The primary identity is set during bootstrap. If you only ever commit as one identity, that's all you need — the machinery below is optional and silently ignored when unused.

To add a folder-scoped identity (e.g. different author for work projects):

```sh
bin/git-add-identity
```

This creates `~/.gitconfig-<label>` and appends an `[includeIf]` block to `~/.gitconfig.identities`, so commits under that folder automatically use the right identity. The script refuses duplicate labels and non-existent folders — both would otherwise fail silently. Both files are included in `local-backup`, so a reinstall gets them back.

> **Note**: this scopes *commit authorship* (name/email), not SSH authentication or signing. If your identities use different SSH keys in 1Password, select the right key per host in `~/.ssh/config.local`.

## after a fresh install

1. Install Xcode Command Line Tools / clone the repo (see [install](#install)), create `~/.localgroups` for this machine, then run `script/bootstrap` — it prompts for your git identity, symlinks everything, applies macOS defaults, and installs Homebrew + the Brewfile and the selected app group
2. Open 1Password (installed by the Brewfile), sign in, and enable the SSH agent and CLI integration: Settings → Developer → *Use the SSH agent* + *Connect with 1Password CLI*
3. `local-restore` — brings back the 1Password bundle: `~/.localrc`, the SSH overrides, the agent config, the Atuin key and the git identity files (needs step 2's CLI integration). If you did **not** create `~/.localgroups` before bootstrap, or want to change groups, create/edit it and run `dot` to install them
4. Switch the git remote to SSH so `dot` can pull (see [install](#install))
5. Sign in to your sync service (the Mackup storage folder), let it finish syncing, then run `mackup restore` — never `mackup link`
6. `atuin login` — the encryption key came back in step 3, so history sync just works
7. Install the Mac App Store apps listed in the Brewfile comment block (they can't be automated)
8. `pre-commit install` — enable the local lint hooks
9. `dot-doctor` — verify links, groups, storage and tools

Fonts need no step: the casks in `Brewfile` install them and `ghostty/config/config` already names them.

## dot-doctor

`dot-doctor` is the health check — run it after a restore, after changing a group, or when something feels off. It reports, and exits non-zero only on real failures:

- symlinks missing or pointing at the wrong source (derived from the repo, same rules as `script/bootstrap`)
- broken `~/.config` links, Mackup whitelist and storage, `~/.localgroups` provenance and unknown groups
- machine-local files, git identity references, required and optional tools, mise status

It never changes anything. A `[WARN]` is something to read; a `[FAIL]` is something to fix.

## removing

`script/uninstall` deletes every symlink in `$HOME` and `~/.config` that points into this repo, and stops there — Homebrew packages, `~/.gitconfig.local` and app data are left untouched. Remove the repo clone afterwards if you want a clean slate.

## credits

The structure, the `topic/` layout, the `.symlink` convention, the `bin/` convention and the auto-loading `.zsh` files come from [Zach Holman's dotfiles](https://github.com/holman/dotfiles) — see his [dotfiles are meant to be forked](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/). `LICENSE.md` is his MIT licence, unchanged; this fork adds the app groups, the macOS/Mackup/1Password integration and the doctor.

Mackup's config format and the "back up by whitelist" habit were shaped by [Dries Vints' dotfiles](https://github.com/driesvints/dotfiles) and the [dotfiles.github.io](https://dotfiles.github.io/) community.
