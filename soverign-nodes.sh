#!/usr/bin/env bash
# SOVEREIGN NODES | Pre-deployment script for Linux Sovereign Nodes
# Style: High-signal ASCII TUI (Inspired by Claude-Code & Archinstall)
set -euo pipefail

# --- ASCII TUI Components ---
draw_line() {
    printf '%.0s-' {1..64}
    echo
}

print_step() {
    echo
    echo "--- [ $1 ] ---"
}

print_success() {
    echo "  [+] $1"
}

print_info() {
    echo "  [*] $1"
}

print_warn() {
    echo "  [!] $1"
}

# --- 0. System Header ---
draw_line
echo "   _____                     _                   _   _           _           "
echo "  / ____|                   (_)                 | \ | |         | |          "
echo " | (___   _____   _____ _ __ _  __ _ _ __ ______|  \| | ___   __| | ___  ___ "
echo "  \___ \ / _ \ \ / / _ \ '__| |/ _\` | '_ \______| . \` |/ _ \ / _\` |/ _ \/ __|"
echo "  ____) | (_) \ V /  __/ |  | | (_| | | | |     | |\  | (_) | (_| |  __/\__ \\"
echo " |_____/ \___/ \_/ \___|_|  |_|\__, |_| |_|     |_| \_|\___/ \__,_|\___||___/"
echo "                                __/ |                                        "
echo "                               |___/                                         "
draw_line
echo " PROJECT: SOVEREIGN NODES | CROSS-DISTRO DEPLOYMENT"
draw_line

# --- 1. Distro Detection & Package Manager Setup ---
print_step "DETECTING SYSTEM DISTRIBUTION"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

print_info "DETECTED OPERATING SYSTEM: ${OS^^}"

install_packages() {
    case "$OS" in
        ubuntu|debian|raspbian)
            apt-get update -y
            apt-get install -y "$@"
            ;;
        arch|manjaro)
            # Ensure base-devel and git are present for AUR
            pacman -Sy --noconfirm --needed base-devel git
            
            # Check for yay
            if ! command -v yay &> /dev/null; then
                print_info "YAY NOT FOUND. INSTALLING FROM AUR..."
                TEMP_DIR=$(mktemp -d)
                git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
                cd "$TEMP_DIR"
                makepkg -si --noconfirm
                cd -
                rm -rf "$TEMP_DIR"
            fi
            yay -S --noconfirm --needed "$@"
            ;;
        fedora)
            dnf install -y "$@"
            ;;
        *)
            print_warn "UNSUPPORTED DISTRO: $OS. ATTEMPTING GENERIC INSTALL..."
            exit 1
            ;;
    esac
}

# --- 2. Pre-flight Checks ---
print_step "SYSTEM VERIFICATION"
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 7 ]; then
    print_warn "8GB RAM RECOMMENDED. DETECTED: ${TOTAL_RAM}GB"
    print_info "AI AGENTS AND VAULTWARDEN MAY REQUIRE SWAP OPTIMIZATION."
else
    print_success "SYSTEM RESOURCES: OPTIMAL"
fi

# --- 3. Identity & Security ---
print_step "SECURE IDENTITY SETUP"
while true; do
    read -s -p "  [?] SET NEW SYSTEM PASSWORD (MIN 16 CHARS): " SECURE_PW
    echo
    if [ ${#SECURE_PW} -ge 16 ]; then
        echo "$(whoami):$SECURE_PW" | chpasswd
        print_success "PASSWORD UPDATED SUCCESSFULLY."
        break
    else
        print_warn "LENGTH REQUIREMENT NOT MET. PLEASE RETRY."
    fi
done

# --- 4. Base OS & Hardening ---
print_step "HARDENING BASE OS"

# Common dependencies mapping
case "$OS" in
    arch|manjaro)
        install_packages fail2ban btrfs-progs curl wget btop wireguard-tools htop iotop python python-pip ufw gnupg lsb-release
        ;;
    fedora)
        install_packages fail2ban btrfs-progs curl wget btop wireguard-tools htop iotop python3 python3-pip ufw gnupg
        ;;
    *)
        install_packages fail2ban btrfs-progs curl wget btop wireguard htop iotop python3 python3-pip python3-venv ufw lsb-release gnupg
        ;;
esac

print_info "INSTALLING YEET.CX OBSERVABILITY..."
curl -fsSL https://yeet.cx | sh

print_info "HARDENING SSH DAEMON..."
# Ensure /etc/ssh/sshd_config exists (might differ on some distros)
if [ -f /etc/ssh/sshd_config ]; then
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart ssh || systemctl restart sshd
fi

# --- 5. Cryptography ---
print_step "CRYPTOGRAPHIC ONBOARDING"
read -p "  [?] GENERATE NEW GPG/SSH KEYS? (y/n): " GEN_KEYS
if [[ "$GEN_KEYS" =~ ^[Yy]$ ]]; then
    print_info "GENERATING ED25519 SSH KEY..."
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)-sovereign-nodes" -f "$HOME/.ssh/id_ed25519" -N ""
    print_success "SSH PUBLIC KEY GENERATED."

    print_info "GENERATING RSA 4096 / SHA-512 GPG KEY..."
    gpg --batch --generate-key <<EOF
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Name-Real: $(whoami)
Name-Email: $(whoami)@$(hostname).local
Expire-Date: 0
%no-protection
%preferences SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
%commit
EOF
    print_success "GPG KEY GENERATED."
fi

# --- 6. Network Protection ---
print_step "FIREWALL CONFIGURATION (UFW)"
print_info "APPLYING DENY-ALL INCOMING POLICY..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 51820/udp       # WIREGUARD
ufw allow 80,443/tcp      # WEB SERVICES
ufw allow 9443/tcp        # PORTAINER
ufw --force enable
print_success "FIREWALL IS ACTIVE."

# --- 7. Privacy Suite ---
print_step "PRIVACY & AUTONOMY TOOLS"

# Mullvad VPN
case "$OS" in
    ubuntu|debian|raspbian)
        print_info "CONFIGURING MULLVAD REPO FOR DEBIAN..."
        curl -fsSL https://repository.mullvad.net/deb/mullvad-keyring.asc | tee /usr/share/keyrings/mullvad-keyring.asc > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/mullvad.list
        apt-get update && apt-get install -y mullvad-vpn
        ;;
    arch|manjaro)
        print_info "INSTALLING MULLVAD VPN FROM AUR..."
        install_packages mullvad-vpn-bin
        ;;
    fedora)
        print_info "CONFIGURING MULLVAD REPO FOR FEDORA..."
        dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
        dnf install -y mullvad-vpn
        ;;
esac

# i2pd
case "$OS" in
    ubuntu|debian|raspbian)
        print_info "CONFIGURING I2PD REPO FOR DEBIAN..."
        wget -q -O - https://repo.i2pd.xyz/.help/add_repo | bash -s -
        apt-get install -y i2pd
        ;;
    arch|manjaro)
        print_info "INSTALLING I2PD FROM EXTRA..."
        install_packages i2pd
        ;;
    fedora)
        print_info "INSTALLING I2PD FROM COPR/REPOS..."
        dnf install -y i2pd
        ;;
esac
systemctl enable i2pd --now

print_info "INSTALLING MESHTASTIC CLI..."
pip3 install --upgrade "meshtastic[cli]" --break-system-packages || pip3 install --upgrade "meshtastic[cli]"

print_info "INSTALLING BITCHAT..."
mkdir -p /opt/bitchat && cd /opt/bitchat
wget -q https://technitium.com/download/bitchat/linux/BitChatPortable.tar.gz
tar -xvzf BitChatPortable.tar.gz
# Distro-specific mono installation
case "$OS" in
    arch|manjaro) install_packages mono ;;
    fedora) install_packages mono-core ;;
    *) ./install-mono.sh || true ;;
esac
cd -

# --- 8. Storage (BTRFS POOL) ---
print_step "HIGH-INTEGRITY STORAGE (SHA-256)"
ROOT_DEV=$(findmnt -n -o SOURCE / | sed 's/p[0-9]*$//' | sed 's/[0-9]*$//')
TARGET_DRIVES=$(lsblk -dno NAME | grep -vE "^($(basename $ROOT_DEV)|zram|loop)" | sed 's|^|/dev/|')

if [ -n "$TARGET_DRIVES" ]; then
    print_info "POOLING DRIVES: $TARGET_DRIVES"
    for dev in $TARGET_DRIVES; do umount "${dev}"* || true; done

    if [ $(echo "$TARGET_DRIVES" | wc -l) -gt 1 ]; then
        mkfs.btrfs -f --checksum sha256 -d single -m raid1 $TARGET_DRIVES
    else
        mkfs.btrfs -f --checksum sha256 -d single -m single $TARGET_DRIVES
    fi

    TARGET_MOUNT="/var/lib/casaos/volumes"
    mkdir -p "$TARGET_MOUNT"
    FIRST_DRIVE=$(echo "$TARGET_DRIVES" | head -n1)
    FS_UUID=$(blkid -o value -s UUID "$FIRST_DRIVE")
    
    # Handle fstab across distros
    sed -i "\|${TARGET_MOUNT}|d" /etc/fstab
    echo "UUID=${FS_UUID} ${TARGET_MOUNT} btrfs defaults,noatime,compress=zstd 0 0" >> /etc/fstab
    mount -a
    chmod 777 "$TARGET_MOUNT"
    print_success "STORAGE POOL MOUNTED AT ${TARGET_MOUNT}"
else
    print_warn "NO EXTERNAL DRIVES DETECTED. DATA WILL BE STORED ON SD CARD."
fi

# --- 9. Containers & AI ---
print_step "APPLICATION LAYER"

# Docker Installation
case "$OS" in
    arch|manjaro)
        install_packages docker docker-compose
        systemctl enable --now docker
        ;;
    fedora)
        dnf install -y moby-engine docker-compose
        systemctl enable --now docker
        ;;
    *)
        curl -fsSL https://get.casaos.io | bash
        apt-get install -y docker-compose-plugin
        ;;
esac

print_info "DEPLOYING PORTAINER..."
docker volume create portainer_data || true
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest || true

read -p "  [?] DEPLOY VAULTWARDEN? (y/n): " INSTALL_VW
if [[ "$INSTALL_VW" =~ ^[Yy]$ ]]; then
    docker run -d --name vaultwarden --restart=always -v /var/lib/casaos/volumes/vaultwarden:/data -p 8080:80 vaultwarden/server:latest || true
fi

read -p "  [?] DEPLOY SECURE TORRENT STACK? (y/n): " INSTALL_QBIT
if [[ "$INSTALL_QBIT" =~ ^[Yy]$ ]]; then
    mkdir -p /var/lib/casaos/volumes/torrent_config
    ufw allow 8090/tcp
    cat << 'EOF' > /var/lib/casaos/volumes/torrent_config/docker-compose.yml
services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add: [NET_ADMIN]
    devices: [/dev/net/tun:/dev/net/tun]
    ports: [8090:8090]
    environment:
      - VPN_SERVICE_PROVIDER=mullvad
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=YOUR_KEY
      - WIREGUARD_ADDRESSES=YOUR_ADDR
    restart: always
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    volumes:
      - /var/lib/casaos/volumes/torrent_config:/config
      - /var/lib/casaos/volumes/downloads:/downloads
    restart: always
EOF
    print_info "TORRENT TEMPLATE CREATED IN STORAGE POOL."
fi

print_step "OLLAMA & AGENTIC LAYER"
curl -fsSL https://ollama.com/install.sh | sh
if [ -d "/var/lib/casaos/volumes" ]; then
    systemctl stop ollama || true
    mkdir -p /var/lib/casaos/volumes/ollama_models
    mkdir -p /etc/systemd/system/ollama.service.d
    echo -e "[Service]\nEnvironment=\"OLLAMA_MODELS=/var/lib/casaos/volumes/ollama_models\"" > /etc/systemd/system/ollama.service.d/override.conf
    systemctl daemon-reload && systemctl start ollama || true
fi
print_info "PULLING GEMMA:2B..."
ollama pull gemma:2b

cat << 'EOF' > /usr/local/bin/pi-agent
#!/usr/bin/env python3
import sys, os
def main():
    if len(sys.argv) < 2:
        print("Usage: pi-agent 'question'")
        return
    os.system(f"ollama run gemma:2b \"{sys.argv[1]}\"")
if __name__ == "__main__":
    main()
EOF
chmod +x /usr/local/bin/pi-agent

print_step "PROVISIONING COMPLETE"
print_info "PORTAINER:  https://<ip>:9443"
print_info "VAULTWARDEN: http://<ip>:8080"
print_info "AI AGENT:    pi-agent 'hello'"
draw_line
