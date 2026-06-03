# SOVEREIGN NODES

##### For all questions, please email [here](mailto:soverign-nodes@proton.me)

> A high-integrity, privacy-hardened deployment for Linux Sovereign Nodes.

---

## Overview

**Sovereign Nodes** is a professional-grade, cross-distro provisioning script designed to transform your hardware (specialized for Raspberry Pi 5 / Tilde Kit) into a secure, agentic, and autonomous server. 

It features an ASCII TUI inspired by **Archinstall** and **Claude-Code**, providing high-signal feedback throughout the deployment process.

```text
   _____                     _                   _   _           _           
  / ____|                   (_)                 | \ | |         | |          
 | (___   _____   _____ _ __ _  __ _ _ __ ______|  \| | ___   __| | ___  ___ 
  \___ \ / _ \ \ / / _ \ '__| |/ _` | '_ \______| . ` |/ _ \ / _` |/ _ \/ __|
  ____) | (_) \ V /  __/ |  | | (_| | | | |     | |\  | (_) | (_| |  __/\__ \
 |_____/ \___/ \_/ \___|_|  |_|\__, |_| |_|     |_| \_|\___/ \__,_|\___||___/
                                __/ |                                        
                               |___/                                         
```

## Supported Distributions

The script automatically detects and configures the following environments:
- **Arch Linux / Manjaro** (Full AUR support via `yay`)
- **Debian / Ubuntu / Raspberry Pi OS** (`apt-get` optimization)
- **Fedora** (`dnf` integration)

## Key Implementations

### 1. High-Integrity Storage
- **Dynamic Btrfs Pooling:** Automatically detects external USB drives and pools them into a single volume.
- **SHA-256 Checksumming:** Data integrity is enforced using SHA-256 cryptographic hashing (replacing standard CRC32C).
- **ZSTD Compression:** Transparent compression to maximize storage life and space.

### 2. Security & Identity
- **Enforced Standards:** 16-character minimum password requirement.
- **Cryptographic Onboarding:** Interactive generation of **Ed25519 SSH** keys and **RSA 4096 / SHA-512 GPG** keys.
- **Network Hardening:** UFW firewall with a strict deny-all incoming policy (except SSH, VPN, and specific Web UIs).

### 3. Privacy & Autonomy
- **VPN & Tunnels:** Mullvad VPN CLI, WireGuard, and i2pd (C++ I2P).
- **Decentralized Comms:** Meshtastic CLI and BitChat (Technitium).
- **Torrents:** Secure qBittorrent stack hard-routed through a **Gluetun VPN kill-switch**.

### 4. Intelligence Layer
- **Odysseus Workspace:** Optional automatic deployment of the Odysseus AI framework, a self-hosted, privacy-first dashboard for your agents and workflows.
- **Local AI Engine:** Ollama running **Gemma4:e2b** (optimized for Pi 5), automatically bridged to the Odysseus network.
- **Sovereign Storage:** AI models are automatically stored on the high-integrity USB pool to preserve the primary system drive.

## Quick Start

To deploy Sovereign Nodes on a fresh installation:

```bash
curl -fsSL soverign-nodes.github.io/soverign-nodes/soverign-nodes.sh | sudo bash
```

## Hardware Recommendation

- **Primary:** Raspberry Pi 5 (8GB Recommended).
- **OS:** Linux (Arch, Debian, Fedora).
- **External:** 1x or more USB 3.0 Drives for the Storage Pool.

---

*Built for autonomy. Managed by you.*


##### For all questions, please email [here](mailto:soverign-nodes@proton.me)




