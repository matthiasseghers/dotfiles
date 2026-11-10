# dotfiles

Personal dotfiles for a Python development environment on macOS (PHP tooling lives in the optional `work` [app group](#app-groups)). Built on [holman's dotfiles](https://github.com/holman/dotfiles) - topic-centric, `.symlink` convention, auto-loading `.zsh` files. See [credits](#credits).

> [!WARNING]
> These are my personal dotfiles, tuned to my machines and workflow - not a framework, and not supported as one. "Works on my machine" is literal: read [what this assumes](#what-this-assumes) before running `script/bootstrap`, and fork the repo rather than adapting your machine to it.

**TL;DR** - fresh install, in order:

1. Clone, create `~/.localgroups`, run `script/bootstrap` - [full order](#after-a-fresh-install)
2. Sign in to 1Password, enable the SSH agent and CLI, then `local-restore`
3. Point `~/Mackup` at a synced folder, let sync finish, then `mackup restore` - never `mackup link`
4. `atuin login`, `pre-commit install`, `dot-doctor`; moving machines? [old machine first](#moving-to-a-new-mac)

## what this assumes

- **macOS** (Apple Silicon or Intel) with Xcode Command Line Tools, and **zsh** as the login shell. Apple Silicon runs Homebrew end to end; legacy Intel Macs use MacPorts for CLI tools ([details below](#intel-macs))
- **1Password** is recommended but optional: it provides the SSH agent and, with the CLI, `local-backup` / `local-restore`. Without it you need another password manager for the machine-local files below
- **`sudo` and consent to macOS defaults**: bootstrap needs admin rights for the security defaults and hostname fix, `macos/set-defaults.sh` changes Finder, Dock, keyboard and trackpad settings, and `macos/set-security-defaults.sh` requires a password immediately after screen lock

### Intel Macs

Homebrew stopped Intel bottle builds, so a legacy Intel Mac has no brew install: MacPorts owns the CLI tools listed in [`Portsfile`](Portsfile), while the Brewfiles stay the app/cask source of truth. `dot` runs the port updates and installs any new `Portsfile` entries.

- **Wiped Intel Mac**: install MacPorts from [macports.org](https://www.macports.org/install.php), run `dot`, then add what the Portsfile cannot carry: `composer` (official phar into `~/.local/bin`), the 1Password CLI (`op`, standalone) and the GUI apps (`script/bootstrap` prints the cask checklist).
- `spaceman-diff` has no port, so its git image-diff driver errors on Intel - accepted. `Portsfile` mirrors the shared `Brewfile` by hand with no automated checker, so glance at it when adding or removing a brew formula on Apple Silicon.

CI runs lint and smoke checks on every push (including an Intel macOS runner) and a clean `brew bundle` install on an Apple Silicon runner monthly (`.github/workflows/`) - proof the repo is coherent, not that it fits your machine.

## stack

- **Shell**: zsh with [Starship](https://starship.rs), [Atuin](https://atuin.sh) history sync, [zoxide](https://github.com/ajeetdsouza/zoxide) / [fzf](https://github.com/junegunn/fzf) navigation, [git-delta](https://github.com/dandavison/delta) diffs
- **Tooling**: [mise](https://mise.jdx.dev) for per-project Python and Node, [OrbStack](https://orbstack.dev) for Docker, VS Code (a `vim/` config ships too), Ghostty; PHP versions via [PHP Monitor](https://phpmon.app) in the `work` group. **State**: 1Password SSH agent (no key files on disk) and [Mackup](https://github.com/lra/mackup) copy-mode app settings; the Brewfiles are the full tool list

## structure

- **`topic/*.zsh`** - loaded automatically into every shell session
- **`topic/path.zsh`** / **`topic/completion.zsh`** - loaded first / last, for `$PATH` setup and autocomplete
- **`topic/*.symlink`** / **`topic/config/**`** - symlinked into `$HOME` / `~/.config/<topic>/` by `script/bootstrap`, with the config path structure and original name kept (`atuin/config/config.toml` → `~/.config/atuin/config.toml`), so editor tooling still validates them
- **`topic/install.sh`** - run by `script/install` for actual software installation

## install

> [!IMPORTANT]
> **On an Intel Mac?** No brew here - see [Intel Macs](#intel-macs); the rest of this section assumes Apple Silicon.

```sh
git clone https://github.com/matthiasseghers/dotfiles.git ~/dotfiles
cd ~/dotfiles
cp system/localgroups.example ~/.localgroups   # then uncomment what this machine wants
$EDITOR ~/.localgroups
script/bootstrap
```

Create `~/.localgroups` **before** the first bootstrap: it tells `script/install` which app group this machine wants, so the shared `Brewfile` and that group's `Brewfile.<group>` install in one pass. Leave it with no active line for shared apps only.

> **Fresh Mac**: a new Mac has no `git` yet. Running `git clone` triggers the Xcode Command Line Tools install prompt - accept it, wait for the install to finish, then re-run the clone. The repo can be cloned anywhere - `$ZSH` is resolved dynamically from the symlink.

`script/bootstrap` prompts for your git identity, symlinks every `*.symlink` and `topic/config/**` file (conflicts ask `[s]kip / [o]verwrite / [b]ackup`), applies macOS defaults, and installs dependencies. The full fresh-machine order is in [after a fresh install](#after-a-fresh-install).

> **After bootstrap, switch the remote to SSH.** `dot` only auto-pulls SSH remotes, so the HTTPS clone above never updates itself:
> ```sh
> git -C ~/dotfiles remote set-url origin git@github.com:matthiasseghers/dotfiles.git
> ```
> Do this once the 1Password SSH agent works ([step 2](#after-a-fresh-install)) - a fresh Mac has no key yet, which is why the clone is HTTPS.

> **Fresh-install caveat**: the `work` group's `phpmon` cask declares `trusted: true`. Homebrew 6.0 refuses formulae and casks from untrusted taps; that declaration grants the trust automatically, and the base `Brewfile` sticks to always-trusted homebrew-core.

## after a fresh install

1. Install Xcode Command Line Tools and clone the repo ([install](#install)), create `~/.localgroups` **before** `script/bootstrap`, then run it - bootstrap's effects are covered in [install](#install); on Intel, use the [MacPorts manual order](#intel-macs)
2. Open 1Password (installed by the Brewfile), sign in, and enable the SSH agent and CLI integration: Settings → Developer → *Use the SSH agent* + *Connect with 1Password CLI*
3. `local-restore` - brings back the 1Password bundle: `~/.localrc`, the SSH overrides, the agent config, the Atuin key and the git identity files (needs step 2's CLI integration)
4. Switch the git remote to SSH so `dot` can pull (see [install](#install))
5. Recreate the Mackup storage link **before** restoring - a fresh machine has no `~/Mackup`, and `mackup restore` would silently create a local-only one:
   ```sh
   mkdir -p "<synced-folder>/Mackup"
   ln -s "<synced-folder>/Mackup" "$HOME/Mackup"
   ```
   See [app settings](#app-settings-mackup) for the provider paths. On your old machine this link must already exist before `mackup backup`
6. Sign in to your sync service, let it finish syncing, then run `mackup restore` - never `mackup link`
7. `atuin login`, `pre-commit install`, `dot-doctor` - history sync (the key came back in step 3), the lint hooks, then the health check

## staying up to date

Run `dot` periodically (it's on your `$PATH` via `bin/`). It pulls the dotfiles repo (skipped if you have uncommitted changes **or if the remote is HTTPS** - see [install](#install)), updates the package manager (Apple Silicon: `brew update && brew upgrade --no-ask`; Intel: `sudo port selfupdate && sudo port upgrade outdated`, sudo prompts expected) and installs anything new from the `Brewfile` and the group selected in `~/.localgroups` (`Portsfile` on Intel), plus the `topic/install.sh` scripts. `dot -e` opens the dotfiles directory in your editor.

## app groups

Apps are split across plain Brewfiles - one shared file every Mac gets, plus one file per optional group:

| File | Contents |
|---|---|
| `Brewfile` | Shared CLI tools + apps (every Mac) |
| `Brewfile.work` | PHP tooling, work apps |
| `Brewfile.personal` | Games, media, personal apps |

Pick your group per machine in `~/.localgroups` (names, space- or comma-separated; all uncommented lines combine) - a single `work` is enough. `system/localgroups.example` is a commented template.

- **Lifecycle**: no active line (no file, empty file, everything commented) installs the shared `Brewfile` only; adding a group later is "edit the file, run `dot`"; **nothing is ever uninstalled automatically**, so removing an app from a Brewfile leaves it on disk. Typos in the selection are reported by `dot` (via `script/install`) and `dot-doctor` before anything is installed. `DOTFILES_GROUPS="work" dot` overrides one run (CI uses it)
- **New group**: create `Brewfile.<name>` in the repo root and it exists immediately. Each app appears in exactly one file, enforced by the `no-duplicate-brewfile-entries` pre-commit hook, and taps sit in the same file as the formulae/casks that need them

## machine-specific config

These files are per machine and **never committed**:

| File | Purpose | How it comes back after a reinstall |
|---|---|---|
| `~/.gitconfig.local` | Primary git identity (name + email) | `script/bootstrap` prompt |
| `~/.gitconfig.identities` (+ `~/.gitconfig-*`) | Folder-scoped git identities (`includeIf` rules) | `local-restore` (backed up), or `bin/git-add-identity` |
| `$HOME/.ssh/config.local` | Machine-specific SSH hosts/overrides | `local-restore`, or your own password manager |
| `~/.localgroups` | App group for this machine (`work`, `personal`, …) | you create it: `cp system/localgroups.example ~/.localgroups` - **not backed up** |
| `~/.localrc` | Machine-specific shell config (secrets, env) | `local-restore`, or your own password manager (template: `system/localrc.example`) |
| `~/.config/mackup/mackup.cfg` | Mackup storage + app whitelist (linked from `mackup/config/mackup.cfg`) | comes with the repo; per-machine storage via a symlinked `~/Mackup` |
| `~/.config/1Password/ssh/agent.toml` | 1Password SSH agent config | `local-restore`, or your own password manager (template: `ssh/agent.toml.example`) |
| `~/.local/share/atuin/key` | Atuin history-sync encryption key | `local-restore`, or your own password manager |

> **Where `~/.localrc` stops**: it is sourced *before* the repo's `*.zsh` files (`zsh/zshrc.symlink:8`), so it is the right place for environment variables and secrets - but an alias or function defined there loses to the repo's own. For a permanent behaviour change, edit the repo (fork it) instead.

## app settings (Mackup)

[Mackup](https://github.com/lra/mackup) backs up **app-written** settings and data (preferences, databases, save files) to a synced folder. Dotfiles own hand-written plain-text config (anything in this repo); Mackup owns app-written prefs/data - never both for the same file.

- **Copy mode only**: run `mackup backup` / `mackup restore`. **Never run `mackup link`** - it replaces app files with symlinks and corrupts preferences on macOS 14+.
- **Whitelist only**: `mackup/config/mackup.cfg` (linked to `~/.config/mackup/mackup.cfg`) lists exactly which apps are backed up. A missing *or empty* `[applications_to_sync]` means "back up everything" - including ssh, git, zsh and vim - which fights the dotfiles symlinks and copies `~/.ssh` to cloud storage.
- **Storage is per machine, and nothing prompts for it**: the linked config resolves to `~/Mackup`, which is local-only until you point it at a synced folder - see [after a fresh install](#after-a-fresh-install) step 5 for the `ln -s` command. One committed config then serves every machine, and `dot-doctor` reports whether the resolved folder is synced. Mark the folder **"Available offline"** (Finder: *Keep Downloaded*) - cloud providers otherwise leave placeholders Mackup cannot restore from.
- **Never create a partial `~/.mackup.cfg`**: Mackup reads exactly one config file (`~/.mackup.cfg` → `$MACKUP_CONFIG` → `~/.config/mackup/mackup.cfg`) and does not merge them. A storage-only override silently drops the whitelist and `mackup backup` copies `~/.ssh` to the cloud. If you must override, repeat the whole file.
- **Custom apps**: add a `.cfg` under `mackup/config/applications/` in this repo; `script/bootstrap` links it to `~/.config/mackup/applications/` where Mackup picks it up. Paths are relative to `$HOME` (`[configuration_files]`) or to `~/.config` (`[xdg_configuration_files]`). Check `mackup show <app>` to see what will be backed up.
- **Raycast**: only the plist and plain config files are synced. Raycast's real data (snippets, quicklinks, hotkeys) lives in an encrypted local database that does not restore usefully - for a full backup use Raycast's own **Settings → Advanced → Export** (`.rayconfig` file).

## machine-local backup (optional, 1Password)

If the [1Password CLI](https://developer.1password.com/docs/cli/) (`op`) is installed, `1password/functions.zsh` adds two functions for the machine-local files from the table above (`~/.localrc`, the SSH overrides, the 1Password agent config, the Atuin key, and the git identity files `~/.gitconfig.identities` + `~/.gitconfig-<label>`):

```sh
local-backup            # pack existing files into one tgz Document in 1Password
local-restore           # restore this machine's backup into $HOME
local-restore "dotfiles: other-machine"   # restore another machine's backup
```

- The Document is titled `dotfiles: <hostname>`; override with `DOTFILES_BACKUP_NAME`. The file list lives in `script/lib/machine-local.sh`, which `dot-doctor` reads too, so the two cannot drift. Deliberately **not** in the bundle: `~/.localgroups` (must exist before bootstrap, when `op` doesn't exist yet), `~/.gitconfig.local` (bootstrap regenerates it from the prompt) and the Mackup folder (app data, backed up by Mackup).
- Restored files are chmod 600. `local-restore` never overwrites existing files (`tar -k`) - move them aside first. Without 1Password, back up those files yourself (password manager, encrypted archive, …); **secrets never go into Mackup** (see [app settings](#app-settings-mackup)).

## git identities

The primary identity is set during bootstrap; if you only ever commit as one identity, that's all you need - the machinery below is optional and silently ignored when unused. For a folder-scoped identity (e.g. a different author for work projects):

```sh
bin/git-add-identity
```

This creates `~/.gitconfig-<label>` and appends an `[includeIf]` block to `~/.gitconfig.identities`, so commits under that folder automatically use the right identity. The script refuses duplicate labels and non-existent folders - both would otherwise fail silently. Both files are included in `local-backup`, so a reinstall gets them back.

> **Note**: this scopes *commit authorship* (name/email), not SSH authentication or signing. If your identities use different SSH keys in 1Password, select the right key per host in `$HOME/.ssh/config.local`.

## dot-doctor

`dot-doctor` is the health check - run it after a restore, after changing a group, or when something feels off. It reports missing or wrong symlinks (same rules as `script/bootstrap`), broken `~/.config` links, the Mackup whitelist and storage, `~/.localgroups` provenance and unknown groups, machine-local files, git identities, tools and mise, and exits non-zero only on real failures.

It never changes anything. A `[WARN]` is something to read; a `[FAIL]` is something to fix.

## moving to a new Mac

The order matters, because three things cannot be recreated from the repo: the 1Password bundle, app-written settings (Mackup) and anything you forgot to push.

**On the old machine:**

1. `dot-doctor` - fix what it fails first, so you migrate a known-good state
2. `local-backup` - packs the files listed under [machine-local backup](#machine-local-backup-optional-1password) into one Document titled `dotfiles: <hostname>`; then `mackup backup` for app settings and data
3. Push every branch you care about (including work-in-progress) and note unpushed stashes

**On the new machine:** Follow [after a fresh install](#after-a-fresh-install) in order; steps 1, 3, 5 and 6 each fail quietly if the earlier one isn't done (no group apps / no restore / local-only Mackup / partial restore).

## removing

`script/uninstall` deletes every symlink in `$HOME` and `~/.config` that points into this repo, and stops there - Homebrew packages, `~/.gitconfig.local` and app data are left untouched. Remove the repo clone afterwards for a clean slate.

## credits

The structure, the `topic/` layout, the `.symlink` and `bin/` conventions and the auto-loading `.zsh` files come from [Zach Holman's dotfiles](https://github.com/holman/dotfiles). `LICENSE.md` is his MIT licence, unchanged; this fork adds the app groups, the macOS/Mackup/1Password integration and the doctor. Mackup's config format was shaped by [Dries Vints' dotfiles](https://github.com/driesvints/dotfiles) and the [dotfiles.github.io](https://dotfiles.github.io/) community.
