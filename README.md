# Soulseek Docker

[![Build](https://img.shields.io/github/actions/workflow/status/realies/soulseek-docker/build.yml?style=flat-square&logo=github)](https://github.com/realies/soulseek-docker/actions)
[![Pulls](https://img.shields.io/docker/pulls/realies/soulseek?style=flat-square&logo=docker)](https://hub.docker.com/r/realies/soulseek)
[![Size](https://img.shields.io/docker/image-size/realies/soulseek?style=flat-square&logo=docker)](https://hub.docker.com/r/realies/soulseek)

Soulseek client running in Docker with web-based access via noVNC.

![Screenshot](https://i.snipboard.io/8dpAbV.jpg)

## Quick Start

```yaml
services:
  soulseek:
    image: realies/soulseek
    container_name: soulseek
    restart: unless-stopped
    ports:
      - 6080:6080
    volumes:
      - ./appdata:/data/.SoulseekQt
      - ./downloads:/data/Soulseek Downloads
      - ./shared:/data/Soulseek Shared Folder
```

Access the UI at `http://localhost:6080`

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID |
| `PGID` | `1000` | Group ID |
| `UMASK` | `022` | File permission mask |
| `TZ` | - | Timezone (e.g., `America/New_York`) |
| `VNCPWD` | - | VNC password |
| `VNCPWD_FILE` | - | Path to VNC password file |
| `VNC_PORT` | `5900` | VNC server port |
| `NOVNC_PORT` | `6080` | noVNC web UI port |
| `MODIFY_VOLUMES` | `true` | Set ownership/permissions on volumes at startup |

## Port Forwarding

For full connectivity, forward your Soulseek listening ports:

1. Start the container and open the UI
2. Go to **Options → Login** to find your ports
3. Forward those ports on your router to your Docker host
4. Add them to your compose file:

```yaml
ports:
  - 6080:6080
  - 61122:61122  # listening port
  - 61123:61123  # obfuscated port
```

## Volumes

| Path | Description |
|------|-------------|
| `/data/.SoulseekQt` | Application data and settings |
| `/data/Soulseek Downloads` | Downloaded files |
| `/data/Soulseek Shared Folder` | Files to share |
| `/data/Soulseek Chat Logs` | Chat history (optional) |

## Platform Support

| Architecture | Support |
|--------------|---------|
| `linux/amd64` | Native |
| `linux/arm64` | Via Box64 emulation |

ARM64 support enables running on Raspberry Pi, Apple Silicon, AWS Graviton, and other ARM devices.

## Reverse Proxy

Example nginx configuration is available in [`soulseek.conf`](soulseek.conf).
