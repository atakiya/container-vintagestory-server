# Vintage Story Server container image

## About
An alpine-based container image that runs the official Vintage Story server, running on the mono runtime.

For information on how to configure the Vintage Story server, please see https://wiki.vintagestory.at/index.php?title=Setting_up_a_Multiplayer_Server#Basic_Configuration

## Usage

Available environment variables:
ENVVAR           | USE               | DEFAULT
-----------------|-------------------|---------------
`USER`           | unix service name | `vintagestory`
`UID`            | unix userid       | `1001`
`GID`            | unix groupid      | `1001`
`SERVER_VERSION` | game version      | `1.17.11`

⚠️ *Do not modify the USER, UID or GID unless you know what you're doing!*

Available mount paths:
PATH    | USE
--------|-----
`/app`  | Installed server + rollback versions<br/>Kept here to not cause redownloads of the same version with each reboot
`/data` | Data directory for the server, used for cache, mods, preferences

### Docker Standalone
```sh
docker run -it \
	--name "vintagestory" \
	-p 42420:42420 \
	-e SERVER_VERSION="1.17.11"
	-v vintagestory_app:/app \
	-v vintagestory_data:/data \
	<imageurlhere>
```

### Docker Compose
```yaml
version: '3.1'

services:
  gameserver:
    image: <imageurlhere>
    ports:
      # Gameserver port
      - "42420:42420/tcp"
    volumes:
      - app:/app
	    - data:/data
    environment:
      SERVER_VERSION: "1.17.11"

volumes:
  app:
  data:
```
