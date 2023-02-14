#!/bin/sh

BOOTSTRAP_URL=https://cdn.vintagestory.at/gamefiles/stable/vs_server_${SERVER_VERSION}.tar.gz

bs_print () { printf '%s\n' "[BOOTSTRAP] ""$@"""; }

command -v wget >/dev/null 2>&1 || { bs_print "Fatal Error: wget can not be executed." >&2; exit 1; }

cd /app

bs_print "Checking if we need to update the server..."
if [ ! -d "/app/${SERVER_VERSION}" ] || [ ! "$(ls -A /app/${SERVER_VERSION})" ]; then
	bs_print "Version ${SERVER_VERSION} not installed, downloading..."
	mkdir -p /app/${SERVER_VERSION}
	wget -O- "${BOOTSTRAP_URL}" | tar xz --directory="/app/${SERVER_VERSION}"
fi

bs_print "Handing over to app..."
cd /app/${SERVER_VERSION}
exec mono ./VintagestoryServer.exe --dataPath /data "$@"
