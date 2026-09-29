# nh cheatsheet

Config repo: `~/nixos-config` (also linked as `/etc/nixos`).
No path or `-s` flag needed: `NH_FLAKE` points at the repo, and
`/etc/specialisation` keeps you in the entry you booted (work / gaming / base).

## Everyday

```sh
nh os switch                          # after editing the config: build, activate, make boot default
nh os switch -u -a --commit-lock-file # weekly-ish: update inputs, review diff, confirm, commit flake.lock
```

**`nh os switch`: your changes, same versions.** Builds from the versions
pinned in `flake.lock`, so only your edit changes. Use it after adding or
removing a package, changing a setting or service, or tweaking a
specialisation. If something breaks, it was your edit.

**`nh os switch -u ...`: same config, new versions.** Updates every input
(nixpkgs unstable, chaotic, noctalia, helium, ...) to the latest upstream
version and commits `flake.lock`. Use it for new app versions, kernel/NVIDIA
updates, and security fixes. If something breaks, it came from upstream.

## Rules of thumb

- **Don't mix edits and updates.** Switch the edit first, confirm it works,
  then update separately. Mixed, you can't tell who broke what.
- **Update when you have time to fix things**, not right before a meeting.
  nixos-unstable breaks occasionally.
- **Update one thing** with `-U`, e.g. `nh os switch -U noctalia`.
- **Kernel or NVIDIA driver changed?** Use `nh os boot -u --commit-lock-file`
  and reboot, instead of switching in place (new userspace next to old kernel
  modules).
- **Add `-a`** to updates to see the package diff before confirming.

## Other commands

| Command                  | What it does                                                        |
|--------------------------|---------------------------------------------------------------------|
| `nh os build`            | Build only, no activation (check a change compiles)                 |
| `nh os boot`             | Build and make default for next boot only (kernel / NVIDIA updates) |
| `nh os test`             | Activate now, not the boot default (a reboot undoes it)             |
| `nh os switch -s gaming` | Switch to another specialisation (`-S` = base system)               |
| `nh os rollback`         | Go back to the previous generation                                  |
| `nh os info`             | List generations                                                    |
| `nh clean all --keep 5`  | Manual cleanup (a weekly timer already does this)                   |

## Useful flags

| Flag                    | Meaning                                    |
|-------------------------|--------------------------------------------|
| `-u`                    | Update all flake inputs                    |
| `-U <input>`            | Update one input (repeatable)              |
| `--commit-lock-file`    | Commit `flake.lock` after updating         |
| `-a`, `--ask`           | Show the diff and confirm before activating |
| `-n`, `--dry`           | Dry run                                    |
| `-s <name>` / `-S`      | Pick a specialisation / ignore them        |

## If an update breaks something

```sh
cd ~/nixos-config && git revert HEAD   # undo the flake.lock update commit
nh os switch
```
or just `nh os rollback`, or pick an older generation from the boot menu.
