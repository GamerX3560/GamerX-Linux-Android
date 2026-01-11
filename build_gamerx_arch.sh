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
rm -rf "$WORK_DIR"
mkdir -p "$ROOTFS_DIR"

# 2. Download Base Arch Linux ARM
echo "[*] Downloading Arch Linux ARM Base..."
wget http://ca.us.mirror.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz -O "$WORK_DIR/base.tar.gz"

# 3. Extract Base
echo "[*] Extracting Base System (this may take a while)..."
bsdtar -xpf "$WORK_DIR/base.tar.gz" -C "$ROOTFS_DIR"

# 4. Chroot Preparation (QEMU for ARM emulation if on x86)
if [ -f /usr/bin/qemu-aarch64-static ]; then
    echo "[*] Setting up QEMU emulation..."
    cp /usr/bin/qemu-aarch64-static "$ROOTFS_DIR/usr/bin/"
fi

# Copy DNS for internet access
rm -f "$ROOTFS_DIR/etc/resolv.conf"
cp /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"

# 5. Branding & Configuration Script
cat <<EOF > "$ROOTFS_DIR/gamerx_setup.sh"
#!/bin/bash

# Initialize Pacman
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Sy --noconfirm

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

# 6. Enter Chroot and Run Setup
echo "[*] Entering Chroot to configure system..."
chroot "$ROOTFS_DIR" /bin/bash /setup.sh

# 7. Cleanup Setup Script
rm "$ROOTFS_DIR/setup.sh"

# 8. Compress
echo "[*] Compressing Final Image..."

# 7. Compress
echo "[*] Compressing Final Image..."
cd "$ROOTFS_DIR"
tar -czpf "../$IMAGE_NAME" .

echo "========================================"
echo "    Build Complete: $WORK_DIR/$IMAGE_NAME"
echo "========================================"
