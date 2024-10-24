# Soulseek Docker Container

![GitHub Workflow Status](https://shields.api-test.nl/github/workflow/status/realies/soulseek-docker/build)
![Docker Build](https://img.shields.io/docker/automated/realies/soulseek)
![Docker Pulls](https://shields.api-test.nl/docker/pulls/realies/soulseek)
![Docker Image Size](https://shields.api-test.nl/docker/image-size/realies/soulseek)

![Soulseek Docker Container Screenshot](https://i.snag.gy/8dpAbV.jpg)

## Prerequisites

- Docker installed on your machine or server
- Port 6080 open and accessible for noVNC web access (or reverse proxied, nginx example at `soulseek.conf`)
- Ports required by Soulseek open and forwarded from your router to the Docker host machine

## Setup

1. Map port 6080 on the host machine to port 6080 on the Docker container.

- If using a GUI or webapp (e.g., Synology) to manage Docker containers, set this configuration option when launching the container from the image.
- With Docker CLI, use the `-p 6080:6080` option.

2. Map the ports Soulseek uses on the Docker container.

- The first time it runs, Soulseek starts up using a random port. It can also be manually configured in Options -> Login.
- Wait for a Soulseek settings file to appear in `/data/.SoulseekQt/1`, this is saved every 60 minutes by default but can be forced to be more freuquent from Options -> General.
- Map both ports from your router to the machine hosting the Docker image, and from the outside of the Docker image to the server within it. See the [Soulseek FAQ](https://www.slsknet.org/news/faq-page#t10n606) for more details.

3. Launch the Docker container and map the required volumes (see [How to Launch](#how-to-launch) section below).

4. Access the Soulseek UI by opening a web browser and navigating to `http://docker-host-ip:6080` or `https://reverse-proxy`, depending on your configuration.

## Configuration

The container supports the following configuration options:

| Parameter     | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| `PGID`        | Group ID for the container user (optional, requires `PUID`, default: 1000)    |
| `PUID`        | User ID for the container user (optional, requires `PGID`, default: 1000)     |
| `VNC_PORT`    | Port for VNC server (optional, default: 5900)                                 |
| `NOVNC_PORT`  | Port for noVNC web access (optional, default: 6080)                           |
| `UMASK`       | File permission mask for newly created files (optional, default: 022)         |
| `VNCPWD`      | Password for the VNC connection (optional)                                    |
| `VNCPWD_FILE` | Password file for the VNC connection (optional, takes priority over `VNCPWD`) |
| `TZ`          | Timezone for the container (optional, e.g., Europe/Paris, America/Vancouver)  |

## How to Launch

### Using Docker Compose

```yaml
version: "3"
services:
  soulseek:
    image: realies/soulseek
    container_name: soulseek
    restart: unless-stopped
    volumes:
      - /persistent/appdata:/data/.SoulseekQt
      - /persistent/downloads:/data/Soulseek Downloads
      - /persistent/logs:/data/Soulseek Chat Logs
      - /persistent/shared:/data/Soulseek Shared Folder
    environment:
      - PGID=1000
      - PUID=1000
    ports:
      - 6080:6080
      - 61122:61122 # example listening port, check Options -> Login
      - 61123:61123 # example obfuscated port, check Options -> Login
```

### Using Docker CLI

```bash
docker run -d --name soulseek --restart=unless-stopped \
  -v "/persistent/appdata":"/data/.SoulseekQt" \
  -v "/persistent/downloads":"/data/Soulseek Downloads" \
  -v "/persistent/logs":"/data/Soulseek Chat Logs" \
  -v "/persistent/shared":"/data/Soulseek Shared Folder" \
  -e PGID=1000 \
  -e PUID=1000 \
  -p 6080:6080 \
  -p 61122:61122 \ # example listening port, check Options -> Login
  -p 61123:61123 \ # example obfuscated port, check Options -> Login
  realies/soulseek
```

### Using Docker on Synology DSM

Port Configuration

![Synology Docker Port Configuration](docs/synology_docker_config_ports_screenshot.png)

- Port 6080 is used by noVNC for accessing Soulseek from your local network. Only TCP type is needed.
- Ports 61122 and 61123 are examples; open Soulseek to determine the exact ports to forward. Only TCP type is needed.
- Configure these ports to forward from your router to the machine hosting the Docker image. See the Soulseek Port Forwarding Guide for more details.

Volume Configuration

![Synology Docker Volume Configuration](docs/synology_docker_config_volumes_screenshot.png)

- Mount the required directories for Soulseek data persistence.
- The example mounts an extra directory `/music/FLAC` for sharing; mount the directory you want to share.
