# fingerprint

Umbrella repository for `open-fprintd`, `python-validity`, and `fprintd` client packages targeting Artix Linux (`dinit` and `elogind`).

Each package directory is integrated via **`git subtree`** with full commit history preserved so that:
- Anyone cloning this repository on GitHub gets every file in a single `git clone`.
- Packages hosted in AURIS can be synced bi-directionally with `git subtree pull` / `git subtree push`.
- Pending packages can be extracted cleanly with `git subtree split` into standalone repositories when submitted to the Artix official repositories.

## Packages

| Directory | Format | Target | Upstream / Notes |
| --- | --- | --- | --- |
| `open-fprintd-dinit` | `pkg.yml` + dinit service | AURIS | `ssh://git@auris.artixlinux.org:23/auris/open-fprintd-dinit.git` |
| `python-validity-dinit` | `pkg.yml` + dinit service | AURIS | `ssh://git@auris.artixlinux.org:23/auris/python-validity-dinit.git` |
| `open-fprintd-elogind-dinit` | `PKGBUILD` | Artix (pending) | `elogind` system-sleep hook for `open-fprintd` (`dinit`) |
| `python-validity-elogind-dinit` | `PKGBUILD` | Artix (pending) | `elogind` system-sleep hook for `python-validity` (`dinit`) |
| `fprintd-clients-git-elogind` | `PKGBUILD` + patches | Artix (pending) | `fprintd` clients-only build with `elogind` support |

Root utility:
- `reset-usbdevfs_reset.py`: Helper script to reset a USB device via the `USBDEVFS_RESET` ioctl (`/dev/bus/usb/<bus>/<device>`).

## Workflow

You can manage subtrees using the included [packages.nu](./packages.nu) Nushell script or raw `git subtree` commands.

### First-time local setup (AURIS remotes)

Git remotes live in `.git/config` and are not committed to GitHub. Register the AURIS remotes on a fresh clone with:

```sh
nu packages.nu remotes
```

### Syncing with AURIS

```sh
# Check subtree status
nu packages.nu status

# Pull updates from AURIS into this repo
nu packages.nu pull
nu packages.nu pull open-fprintd-dinit

# Push changes committed here back to AURIS
nu packages.nu push
nu packages.nu push python-validity-dinit
```

Equivalent raw Git commands:

```sh
git subtree pull --prefix=open-fprintd-dinit auris-open-fprintd-dinit master
git subtree push --prefix=open-fprintd-dinit auris-open-fprintd-dinit master
```

### Splitting a package for Artix official repositories

When ready to submit one of the `*-elogind*` packages as its own standalone repository:

```sh
# Create a local branch with only that package's history
nu packages.nu split open-fprintd-elogind-dinit

# Or export directly into a standalone git repository directory
nu packages.nu split open-fprintd-elogind-dinit --dest ../open-fprintd-elogind-dinit
```

Equivalent raw Git command:

```sh
git subtree split --prefix=open-fprintd-elogind-dinit -b split/open-fprintd-elogind-dinit
```
