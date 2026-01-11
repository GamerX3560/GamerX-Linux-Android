#!/bin/bash
# GamerX Linux Build Script
# Usage: sudo ./build_gamerx_arch.sh
# Description: Builds a branded Arch Linux ARM64 rootfs for GamerX Manager.

set -e

WORK_DIR="gamerx_build"
ROOTFS_DIR="$WORK_DIR/rootfs"
IMAGE_NAME="GamerX_Linux_ARM64.tar.gz"

echo "========================================"
echo "    GamerX Linux Builder (Arch ARM)     "
echo "========================================"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

# 1. Prepare Workspace
echo "[*] Preparing workspace..."
if [ -d "$ROOTFS_DIR" ]; then
    rm -rf "$ROOTFS_DIR"
fi
mkdir -p "$ROOTFS_DIR"

if [ ! -d "$WORK_DIR" ]; then
    mkdir -p "$WORK_DIR"
fi

# 2. Download Base Arch Linux ARM (with Cache)
if [ -f "$WORK_DIR/base.tar.gz" ]; then
    echo "[*] Base image found in cache. Skipping download."
else
    echo "[*] Downloading Arch Linux ARM Base..."
    wget http://ca.us.mirror.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz -O "$WORK_DIR/base.tar.gz"
fi

# 3. Extract Base
echo "[*] Extracting Base System (this may take a while)..."
bsdtar -xpf "$WORK_DIR/base.tar.gz" -C "$ROOTFS_DIR"

# 4. Chroot Preparation (QEMU for ARM emulation if on x86)
HOST_ARCH=$(uname -m)
if [ "$HOST_ARCH" = "x86_64" ]; then
    # 1. Check for Static Binary
    if [ -f /usr/bin/qemu-aarch64-static ]; then
        echo "[*] x86_64 detected. Setting up QEMU emulation..."
        cp /usr/bin/qemu-aarch64-static "$ROOTFS_DIR/usr/bin/"
    else
        echo "[-] Error: 'qemu-aarch64-static' is missing!"
        echo "    Install 'qemu-user-static' package."
        exit 1
    fi

    # 2. Check for Binfmt Registration (Kernel support)
    if [ ! -f /proc/sys/fs/binfmt_misc/qemu-aarch64 ]; then
        echo "[-] Error: ARM64 binary format not registered in kernel!"
        echo "    This causes 'Exec format error'."
        echo "    Fix (Arch): sudo pacman -S qemu-user-static-binfmt && sudo systemctl restart systemd-binfmt"
        echo "    Fix (Debian): sudo apt install binfmt-support"
        exit 1
    fi
fi

# Copy DNS for internet access
rm -f "$ROOTFS_DIR/etc/resolv.conf"
cp /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"

# 5. Apply Overlay & Setup
echo "[*] Applying GamerX Overlay (Configs, Scripts)..."
if [ -d "overlay" ]; then
    cp -rf overlay/* "$ROOTFS_DIR/"
else
    echo "[-] Warning: 'overlay' directory not found!"
fi

# Copy Setup Script
cp setup.sh "$ROOTFS_DIR/setup.sh"
chmod +x "$ROOTFS_DIR/setup.sh"

# 6. Mount & Enter Chroot
echo "[*] Mounting filesystems..."
mount -t proc /proc "$ROOTFS_DIR/proc"
mount -t sysfs /sys "$ROOTFS_DIR/sys"
mount --bind /dev "$ROOTFS_DIR/dev"
mount --bind /dev/pts "$ROOTFS_DIR/dev/pts"

# Function to unmount on exit
function cleanup_mounts {
    echo "[*] Unmounting..."
    umount "$ROOTFS_DIR/dev/pts" 2>/dev/null || true
    umount "$ROOTFS_DIR/dev" 2>/dev/null || true
    umount "$ROOTFS_DIR/sys" 2>/dev/null || true
    umount "$ROOTFS_DIR/proc" 2>/dev/null || true
}
trap cleanup_mounts EXIT INT TERM

# Fix mtab for pacman disk space check
ln -sf /proc/self/mounts "$ROOTFS_DIR/etc/mtab"

echo "[*] Entering Chroot to configure system..."
chroot "$ROOTFS_DIR" /bin/bash /setup.sh

# Cleanup trap will run automatically, but we can call it explicitly too to be clean before tar
cleanup_mounts
trap - EXIT INT TERM # Disable trap to avoid double unmount

# 7. Cleanup Setup Script
rm "$ROOTFS_DIR/setup.sh"

# 8. Compress
echo "[*] Compressing Final Image..."
cd "$ROOTFS_DIR"
tar -czpf "../../$IMAGE_NAME" .

echo "========================================"
echo "    Build Complete: $IMAGE_NAME"
echo "========================================"
