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
wget http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz -O "$WORK_DIR/base.tar.gz"

# 3. Extract Base
echo "[*] Extracting Base System (this may take a while)..."
bsdtar -xpf "$WORK_DIR/base.tar.gz" -C "$ROOTFS_DIR"

# 4. Chroot Preparation (QEMU for ARM emulation if on x86)
if [ -f /usr/bin/qemu-aarch64-static ]; then
    echo "[*] Setting up QEMU emulation..."
    cp /usr/bin/qemu-aarch64-static "$ROOTFS_DIR/usr/bin/"
fi

# Copy DNS for internet access
cp /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"

# 5. Branding & Configuration Script
cat <<EOF > "$ROOTFS_DIR/gamerx_setup.sh"
#!/bin/bash

# Initialize Pacman
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Sy --noconfirm

# Install Essential Packages
echo "[*] Installing Packages..."
pacman -S --noconfirm base-devel git wget curl nano sudo \
    net-tools dnsutils iproute2 \
    xfce4 xfce4-terminal tigervnc xorg-xauth xorg-xhost \
    python python-numpy ttf-dejavu \
    xorg-server-xvfb xorg-xinit

# Install noVNC (Web Client)
echo "[*] Setting up noVNC..."
git clone https://github.com/novnc/noVNC.git /usr/share/novnc
git clone https://github.com/novnc/websockify /usr/share/novnc/utils/websockify
ln -s /usr/share/novnc/utils/novnc_proxy /usr/bin/novnc_server

# Install Cloudflared (Tunnel)
echo "[*] Installing Cloudflared..."
# Detect Arch (AArch64)
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/bin/cloudflared
chmod +x /usr/bin/cloudflared

# Configure Branding
echo "[*] Applying GamerX Branding..."

# Hostname
echo "GamerX-Linux" > /etc/hostname

# MOTD
cat <<MOTD > /etc/motd
=============================================
      G A M E R X   L I N U X
      Arch Linux / XFCE4 / Magisk
=============================================
Welcome to the GamerX Environment.
MOTD

# Add 'gamerx' user
useradd -m -G wheel,users,video,storage,network -s /bin/bash gamerx
echo "gamerx:gamerx" | chpasswd
echo "root:toor" | chpasswd

# Sudo rights
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# VNC Setup for GamerX User
mkdir -p /home/gamerx/.vnc
echo "#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
" > /home/gamerx/.vnc/xstartup
chmod +x /home/gamerx/.vnc/xstartup
chown -R gamerx:gamerx /home/gamerx/.vnc

# Branding inside XFCE (Mockup - would require config file injection)
# We can pre-populate .config/xfce4 here if we had the assets.
mkdir -p /home/gamerx/.config/xfce4
chown -R gamerx:gamerx /home/gamerx/.config

# Cleanup
rm /usr/bin/qemu-aarch64-static
rm /gamerx_setup.sh
pcman -Sc --noconfirm
echo "[*] Setup Complete!"
EOF

chmod +x "$ROOTFS_DIR/gamerx_setup.sh"

# 6. Enter Chroot and Run Setup
echo "[*] Entering Chroot to configure system..."
chroot "$ROOTFS_DIR" /bin/bash /gamerx_setup.sh

# 7. Compress
echo "[*] Compressing Final Image..."
cd "$ROOTFS_DIR"
tar -czpf "../$IMAGE_NAME" .

echo "========================================"
echo "    Build Complete: $WORK_DIR/$IMAGE_NAME"
echo "========================================"
