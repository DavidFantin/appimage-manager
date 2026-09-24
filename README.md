# AppImage Manager (`appimage-install`)

A lightweight Linux CLI utility for managing, organizing, and integrating AppImage applications into your local user environment.

`appimage-manager` standardizes where your AppImages live and automatically creates execution symlinks in your local `PATH`, making AppImages behave like native system binaries.

---

## Features

* **Automated Installation & Placement:** Moves downloaded AppImages into a dedicated location (`~/.local/appimages/`).
* **Instant PATH Integration:** Manages executable symlinks in `~/.local/bin/` so apps can be launched globally from any terminal.
* **Custom Binary Aliasing:** Renames versioned AppImage filenames into short, memorable CLI commands.
* **Executable Bit Management:** Automatically applies executable permissions (`chmod +x`) during installation.
* **Workspace Safety:** Creates target directories if they don't already exist.

---

## Installation

1. Clone or place the `appimage-manager` project in your workspace, then symlink the main script into your local `PATH`:

```bash
ln -sf /path/to/appimage-manager/appimage-install ~/.local/bin/appimage-install
```

Ensure `~/.local/bin` is in your `$PATH` (typically set in `~/.bashrc` or `~/.zshrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

2. Verify installation:

```bash
appimage-install --help
```

## Usage

```bash
appimage-install <path-to-appimage> [custom-binary-name]
```

### Example

```bash
appimage-install ~/Downloads/MyApp-v2.3.0.AppImage myapp
```

This will:
1. Move the AppImage to `~/.local/appimages/`
2. Set executable permissions
3. Create a symlink at `~/.local/bin/myapp`

You can now launch it from anywhere with:

```bash
myapp
```

## Planned Features

- [ ] Desktop integration: generate `.desktop` entries for app menu/launcher support.
- [ ] Uninstall command (e.g., `appimage-install --remove <app-name>`).
- [ ] Fetch and install AppImages directly from GitHub Releases or URLs.
- [ ] List mode (`appimage-install --list`) to show installed AppImages and symlinks.
- [ ] Change the name of the program to better reflect what it does
