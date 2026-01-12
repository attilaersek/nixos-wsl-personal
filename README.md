# nixos-wsl-personal

This repository contains a personalized NixOS configuration designed for running NixOS in the Windows Subsystem for Linux (WSL). It provides a customized environment with specific modules for personal use, including development tools and settings.

## Technologies Used

- **Nix**: A functional package manager and build system used for declarative configuration.
- **NixOS**: A Linux distribution built on top of Nix, allowing for reproducible and declarative system configurations.
- **WSL (Windows Subsystem for Linux)**: Microsoft's compatibility layer for running Linux binaries natively on Windows.

## Repository Structure

- `flake.nix`: The main Nix flake file defining the inputs and outputs for the NixOS configuration.
- `build-tarball.sh`: A shell script for building the NixOS WSL tarball.
- `switch.sh`: A shell script for switching to the new NixOS configuration.
- `assets/`: Folder for static assets or additional resources.
- `modules/`: Directory containing NixOS modules:
  - `personal.nix`: Personalized settings and configurations.
  - `tarball-builder.nix`: Module for building tarballs.
  - `vscode.nix`: Module for Visual Studio Code integration.
