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

## 🏗 Build It Yourself

Want to compile the image from scratch? We provide the build script.

**Requirements**:
*   Linux PC (Arch Linux recommended or Distro with `pacstrap`) or WSL.
*   `sudo` privileges.
*   `arch-install-scripts` package.

**Steps**:
```bash
# 1. Clone Repo
git clone https://github.com/GamerX3560/GamerX-Linux-Android.git
cd GamerX-Linux-Android

# 2. Make Executable
chmod +x build_gamerx_arch.sh

# 3. Build (Root required for Chroot/Filesystem creation)
sudo ./build_gamerx_arch.sh
```
*Output: `GamerX_Linux_ARM64.tar.gz`*

---

## 📂 Architecture

*   **Rootfs**: Arch Linux ARM64 (Base + XFCE4 + Tools).
*   **Integration**: Magisk Module (scripts located in `/data/adb/modules/gamerx_manager/linux/bin`).
*   **User**: `gamerx` (Password: `gamerx`), Root (Password: `toor`).

---

## ⚠️ Disclaimer
This project runs a full Linux OS locally. It requires root access. Use responsibly.
Maintained by **GamerX3560**.
