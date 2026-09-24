# AppImage Manager (`appimage-install`)

A lightweight Linux CLI utility for managing, organizing, and integrating AppImage applications into your local user environment. 

`appimage-manager` standardizes where your AppImages live and automatically creates execution symlinks in your local `PATH`, making AppImages behave like native system binaries.

---

## Features

### Current Release
* **Automated Installation & Placement:** Moves downloaded AppImages into a clean, dedicated system location (`~/.local/appimages/`).
* **Instant PATH Integration:** Automatically manages executable symlinks in `~/.local/bin/` so apps can be launched globally from any terminal.
* **Custom Binary Aliasing:** Cleanly renames complex or versioned AppImage filenames into short, memorable CLI commands (e.g., `RockboxUtility-v1.5.1.appimage` $\rightarrow$ `rockbox`).
* **Executable Bit Management:** Automatically applies executable permissions (`chmod +x`) during installation.
* **Dependency & Workspace Safety:** Creates necessary target directories if they do not already exist.

---

## Installation

1. Direct Script Symlink (Recommended)
Clone or place the `appimage-manager` project in your workspace, then symlink the main script into your local `PATH`:

```bash
# Symlink appimage-install into your local user binary directory
ln -sf ~/Projects/tech/personal/appimage-manager/appimage-install ~/.local/bin/appimage-install
```

Ensure ~/.local/bin is in your environment's $PATH (typically defined in ~/.bashrc or ~/.zshrc):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

2. Verify Installation
```bash
appimage-install --help
```

## How to Use
### Basic Syntax

```bash
appimage-install <path-to-appimage> [custom-binary-name]
```

### Example: Installing Rockbox Utility

Suppose you downloaded RockboxUtility-v1.5.1.appimage to your ~/Downloads directory and want to run it via the simple terminal command rockbox:

```bash
appimage-install ~/Downloads/RockboxUtility-v1.5.1.appimage rockbox
```

What Happens Under the Hood:
1. Move Application:
~/Downloads/RockboxUtility-v1.5.1.appimage $\longrightarrow$ ~/.local/appimages/RockboxUtility-v1.5.1.appimage
2. Permissions:Sets executable permissions (chmod +x).
3. Symlink Binaries:Creates execution link:~/.local/appimages/RockboxUtility-v1.5.1.appimage $\longrightarrow$ ~/.local/bin/rockbox

You can now launch the application from anywhere by simply typing:

```bash
rockbox
```

## Planned Future Features

- [ ] Desktop Integration (.desktop files): Extract icon assets and generate standard ~/.local/share/applications/*.desktop entries for application menu and desktop launcher integration.
- [ ] Uninstallation Routine: Add a removal command (e.g., appimage-install --remove <app-name>) to safely delete AppImage binaries, symlinks, and desktop entries.
- [ ] Upstream Downloading & Updates: Fetch and install the latest AppImage releases directly from GitHub Releases or URL endpoints.
- [ ] Application Management Listing: Add an interactive list mode (appimage-install --list) showing currently installed AppImages and active symlinks.
