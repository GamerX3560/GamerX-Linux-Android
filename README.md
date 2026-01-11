# GamerX Linux (Android Edition)
### *Advanced Arch Linux Chroot Environment for Android*

[![GamerX](https://img.shields.io/badge/Project-GamerX-red.svg?style=for-the-badge)](https://github.com/GamerX3560)
[![Arch Linux](https://img.shields.io/badge/Powered_By-Arch_Linux-blue.svg?style=for-the-badge&logo=arch-linux)](https://archlinux.org)

**GamerX Linux** is a highly optimized, fully capable Arch Linux ARM64 environment designed to run natively on Android devices via Chroot (Magisk/KernelSU). It bridges the gap between mobile hardware and desktop productivity.

---

## 🚀 Features

*   **Native Performance**: Runs via `chroot` with direct hardware access (GPU, Network, Storage).
*   **Desktop Environment**: Pre-configured **XFCE4** with custom GamerX theming.
*   **4-Way Access**:
    1.  **Terminal**: Direct shell access via NetHunter Terminal.
    2.  **GUI (VNC)**: High-performance desktop via VNC (:1).
    3.  **Web (Local)**: Browser-based access via **noVNC** (`http://127.0.0.1:6080`).
    4.  **World (Public)**: Direct secure tunnel via **Cloudflare** (`trycloudflare.com`).
*   **Dev Ready**: Pre-installed with `git`, `python`, `base-devel`, and network tools.

---

## 🛠 Installation

### Automated Install (Recommended)
1.  Install **GamerX Manager** App.
2.  Navigate to **GamerX Linux** section.
3.  Click **Download & Install**. 
    *   *The app automatically fetches the latest release from this repository.*

### Manual Install
1.  Download `GamerX_Linux_ARM64.tar.gz` from [Releases](https://github.com/GamerX3560/GamerX-Linux-Android/releases).
2.  Place it in `/data/adb/modules/gamerx_manager/linux/`.
3.  Open GamerX Manager and select "Install" (or let it auto-detect).

---

## 📂 Source Structure

Instead of a single script, this repo contains the actual configuration files:

*   **`build_gamerx_arch.sh`**: The main driver. Downloads base image and orchestrates the build.
*   **`setup.sh`**: The configuration script that runs *inside* the Chroot (installs packages, sets users).
*   **`overlay/`**: Files copied directly to the rootfs.
    *   `etc/motd`: Login banner.
    *   `home/gamerx/.vnc/xstartup`: VNC startup command.
    *   `home/gamerx/.bashrc`: Shell configuration.

## 🏗 Build It Yourself

**Requirements**:
*   Linux PC (Arch Linux recommended or Distro with `pacstrap`) or WSL.
*   `sudo` privileges.
*   `arch-install-scripts` package.
*   **For x86_64 Users**: `qemu-user-static` and `qemu-user-static-binfmt` (Arch) packages to properly emulate ARM64.
    *   *Arch*: `sudo pacman -S qemu-user-static qemu-user-static-binfmt`
    *   *Debian/Ubuntu*: `sudo apt install qemu-user-static` (ensure binfmt-support is active).

**Steps**:
```bash
# 1. Clone Repo
git clone https://github.com/GamerX3560/GamerX-Linux-Android.git
cd GamerX-Linux-Android

# 2. (Optional) Customize
# Edit overlay/etc/motd or setup.sh to change packages/branding.

# 3. Make Executable
chmod +x build_gamerx_arch.sh

# 4. Build (Root required for Chroot/Filesystem creation)
sudo ./build_gamerx_arch.sh
```
*Output: `GamerX_Linux_ARM64.tar.gz`* (Upload this to Release)

---

## 📂 Architecture

*   **Rootfs**: Arch Linux ARM64 (Base + XFCE4 + Tools).
*   **Integration**: Magisk Module (scripts located in `/data/adb/modules/gamerx_manager/linux/bin`).
*   **User**: `gamerx` (Password: `gamerx`), Root (Password: `toor`).

---

## ⚠️ Disclaimer
This project runs a full Linux OS locally. It requires root access. Use responsibly.
Maintained by **GamerX3560**.
