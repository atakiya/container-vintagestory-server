# Vintage Story Server container image

## About

A Debian-based container image that runs the official Vintage Story server, on the net7 runtime.

For information on how to configure the Vintage Story server, please see https://wiki.vintagestory.at/index.php?title=Setting_up_a_Multiplayer_Server#Basic_Configuration

## Usage

Available image mirrors:
SERVICE | URL
--------|-----
GitHub Container Registry | ghcr.io/atakiya/vintagestory-server
Docker Hub | docker.io/avunia/vintagestory-server

Available optional environment variables:
ENVVAR | USE | DEFAULT
-----------------|-------------------|---------------
`USER` | unix service name | `vintagestory`
`UID` | unix userid | `1001`
`GID` | unix groupid | `1001`
`SERVER_VERSION` | game version | `latest`
`UPDATE_CHANNEL` | channel to download from<br>(`stable` / `unstable`) | `stable`

⚠️ _Do not modify the USER, UID or GID unless you know what you're doing!_

Available mount paths:
PATH | USE
--------|-----
`/app` | Installed server + rollback versions<br/>Kept here to not cause redownloads of the same version with each reboot
`/data` | Data directory for the server, used for cache, mods, preferences

### Docker Standalone

```sh
docker run -it \
	--name "vintagestory" \
	-p 42420:42420 \
	-e SERVER_VERSION="1.19.8" \
	-v vintagestory_app:/app \
	-v vintagestory_data:/data \
	ghcr.io/atakiya/vintagestory-server:latest
```

### Docker Compose

```yaml
services:
  gameserver:
    image: ghcr.io/atakiya/vintagestory-server:latest
    ports:
      # Gameserver port
      - "42420:42420/tcp"
    volumes:
      - app:/app
      - data:/data
    environment:
      SERVER_VERSION: "1.19.8"

volumes:
  app:
  data:
```

### Systemd/Quadlet (Podman)

```ini
[Unit]
After=network-online.target
Description=Vintagestory Server

[Container]
Image=ghcr.io/atakiya/vintagestory-server:latest
PodmanArgs=--interactive
PodmanArgs=--tty
PublishPort=42420:42420/tcp
Volume=vintagestory-app.volume:/app
Volume=vintagestory-data.volume:/data
Environment="SERVER_VERSION=1.19.8"

[Service]
Restart=always
TimeoutStartSec=300
```

_Don't forget to create .volume units with `[Volume]` as contents_
