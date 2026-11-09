# nixos-wsl-personal

This repository contains a personalized NixOS configuration designed for running NixOS in the Windows Subsystem for Linux (WSL). It provides a customized environment with specific modules for personal use, including development tools and settings.

## Technologies Used

- **Nix**: A functional package manager and build system used for declarative configuration.
- **NixOS**: A Linux distribution built on top of Nix, allowing for reproducible and declarative system configurations.
- **WSL (Windows Subsystem for Linux)**: Microsoft's compatibility layer for running Linux binaries natively on Windows.

## Repository Structure

- `flake.nix`: The main Nix flake file defining the inputs and outputs for the NixOS configuration.
- `build.sh`: Builds the NixOS WSL tarball and switches to the new configuration.
- `switch.sh`: Switches to the new NixOS configuration without rebuilding the tarball.
- `assets/`: Folder for static assets or additional resources.
- `modules/`: Directory containing NixOS modules:
  - `settings.nix`: Declares the `settings.*` options that hold personal values (see below).
  - `user.nix`: User environment (home-manager, git, shell, etc.), driven by `settings.*`.
  - `tarball-builder.nix`: Module for building tarballs.
  - `vscode.nix`: Module for Visual Studio Code integration.
- `personal/`: Machine-specific, personal values kept out of version control:
  - `default.nix`: Imports `personal.nix` if it exists.
  - `personal.nix.example`: Template to copy to `personal.nix`.
  - `personal.nix`: Your own settings (git-ignored, not committed).

## Personal Settings

Personal values (username, git identity) are not hard-coded in the modules. They are
declared as options in `modules/settings.nix` and set in a git-ignored `personal/personal.nix`.

| Option                  | Default     | Description                          |
| ----------------------- | ----------- | ------------------------------------ |
| `settings.username`     | `"wsluser"` | The WSL default user name.           |
| `settings.git.name`     | `null`      | The name used for git commits.       |
| `settings.git.email`    | `null`      | The email address used for git commits. |

### Setup

1. Copy the template:

   ```sh
   cp personal/personal.nix.example personal/personal.nix
   ```

2. Edit `personal/personal.nix` with your own values:

   ```nix
   { ... }:
   {
     settings = {
       username = "your-user";
       git = {
         name = "Your Name";
         email = "your@email.address";
       };
     };
   }
   ```

3. Build and switch (see below).

If `personal/personal.nix` is missing, the defaults from `modules/settings.nix` are used.

> **Note:** `personal/personal.nix` is git-ignored, so it must be referenced through a
> `path:` flake URL (as `build.sh` and `switch.sh` do, e.g. `path:.#default`). A plain
> `.#default` flake reference only sees git-tracked files and would silently ignore it.

## Usage

```sh
./build.sh   # build the WSL tarball, then switch to the configuration
./switch.sh  # only switch to the configuration
```
