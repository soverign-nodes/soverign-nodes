# SOVEREIGN NODES



<img width="1774" height="887" alt="soverign-nodes" src="https://github.com/user-attachments/assets/13389569-c7c4-4808-8dcf-4bfc8905dbe1" />

> A high-integrity, privacy-hardened deployment for Linux Sovereign Nodes.

---

## Overview

**Sovereign Nodes
** is a professional-grade, cross-distro provisioning script designed to transform your hardware (specialized for Raspberry Pi 5 / Tilde Kit) into a secure, agentic, and autonomous server. 

It features an ASCII TUI inspired by **Archinstall** and **Claude-Code**, providing high-signal feedback throughout the deployment process.

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
- **Local AI:** Ollama running **Gemma:2b** (optimized for Pi 5).
- **Sovereign Storage:** AI models are automatically stored on the high-integrity USB pool to preserve the primary system drive.
- **Agent CLI:** Built-in `pi-agent` for local RAG and search workflows.

## Quick Start

To deploy Sovereign Node on a fresh installation:

```bash
curl -fsSL https://soverign-nodes.github.io/soverign-nodes/soverign-node.sh | sudo bash
```

## Hardware Recommendation

- **Primary:** Raspberry Pi 5 (8GB Recommended).
- **OS:** Raspberry Pi OS Lite (64-bit) or Arch Linux ARM.
- **External:** 1x or more USB 3.0 Drives for the Storage Pool.

---

*Built for autonomy. Managed by you.*
