#!/bin/bash
# GamerX Internal Setup Script (Runs inside Chroot)

# 1. Initialize Pacman & Keys
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Sy --noconfirm

# 2. Install Packages
echo "[*] Installing Packages..."
PACKAGES=(
    base-devel git wget curl nano sudo
    net-tools dnsutils iproute2
    xfce4 xfce4-terminal tigervnc xorg-xauth xorg-xhost
    python python-numpy ttf-dejavu
    xorg-server-xvfb xorg-xinit
)
pacman -S --noconfirm "${PACKAGES[@]}"

# 3. Setup Helper: noVNC
echo "[*] Setting up noVNC..."
git clone https://github.com/novnc/noVNC.git /usr/share/novnc
git clone https://github.com/novnc/websockify /usr/share/novnc/utils/websockify
ln -sf /usr/share/novnc/utils/novnc_proxy /usr/bin/novnc_server

# 4. Setup Helper: Cloudflared
echo "[*] Installing Cloudflared..."
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/bin/cloudflared
chmod +x /usr/bin/cloudflared

# 5. User Configuration
echo "[*] Configuring Users..."
# Add 'gamerx' user if not exists
if ! id "gamerx" &>/dev/null; then
    useradd -m -G wheel,users,video,storage,network -s /bin/bash gamerx
fi
# Set Passwords
echo "gamerx:gamerx" | chpasswd
echo "root:toor" | chpasswd

# Sudo rights
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# 6. Permissions (Fix up copied overlay files)
chown -R gamerx:gamerx /home/gamerx
chmod +x /home/gamerx/.vnc/xstartup

# 7. Cleanup
rm /usr/bin/qemu-aarch64-static 2>/dev/null
pcman -Sc --noconfirm

echo "[*] GamerX Internal Setup Complete!"
