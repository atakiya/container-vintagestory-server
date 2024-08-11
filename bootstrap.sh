#!/bin/sh

bs_cd () { cd "$@" || exit; }
bs_print () { printf '%s\n' "[BOOTSTRAP] ""$*"""; }

command -v wget >/dev/null 2>&1 || { bs_print "FATAL: wget can not be executed." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { bs_print "FATAL: jq can not be executed." >&2; exit 1; }

SERVER_VERSION="${SERVER_VERSION:-latest}"
UPDATE_CHANNEL="${UPDATE_CHANNEL:-stable}"
API_URL=https://127.0.0.1/invalid.json

if [ "$UPDATE_CHANNEL" = "stable" ]; then
	API_URL=https://api.vintagestory.at/stable.json
elif [ "$UPDATE_CHANNEL" = "unstable" ]; then
	API_URL=https://api.vintagestory.at/unstable.json
else
	bs_print "WARN: Invalid UPDATE_CHANNEL set, please read the documentation carefully!"
fi

bs_cd /app

_API_DATA=$(wget -O- $API_URL)

if [ -n "$_API_DATA" ]; then
	if [ "$SERVER_VERSION" = "latest" ]; then
		_VERSION_DATA=$(jq -n --argjson data "$_API_DATA" '$data | to_entries | map(select(.value.linuxserver.latest)) | .[0]')
	else
		_VERSION_DATA=$(jq -n --argjson data "$_API_DATA" --arg version "$SERVER_VERSION" '$data | to_entries | map(select(.key == $version)) | .[0]')
	fi

	_VERSION=$(jq -n -r --argjson data "$_VERSION_DATA" '$data.key')
	_SERVERDATA=$(jq -n --argjson data "$_VERSION_DATA" '$data.value.linuxserver // $data.value.server')

	_MD5HASH=$(jq -n -r --argjson data "$_SERVERDATA" '$data.md5')
	_URL_CDN=$(jq -n -r --argjson data "$_SERVERDATA" '$data.urls.cdn')
	_URL_MIRROR=$(jq -n -r --argjson data "$_SERVERDATA" '$data.urls.local')

	_APP_DIR="/app/${_VERSION}"
else
	bs_print "WARN: API server not reachable"
	# $SERVER_VERSION is set at this point, so we use that instead
	_APP_DIR="/app/${SERVER_VERSION}"
fi

bs_print "Checking if we need to update the server..."
if [ ! -d "$_APP_DIR" ] || [ ! "$(ls -A "$_APP_DIR")" ]; then
	if [ -z "$_API_DATA" ]; then
		bs_print "FATAL: Version ${SERVER_VERSION} not installed, API server not reachable, cannot run server, exiting!" >&2
		exit 1
	fi

	bs_print "Version ${_VERSION} not installed, downloading..."

	mkdir -p "$_APP_DIR"
	_TMPDLFILE=$(mktemp --tmpdir "vs-${_VERSION}.XXXXXXXXXX")

	if ! wget -O "$_TMPDLFILE" "$_URL_CDN"; then
		bs_print "Downloading from CDN failed, trying mirror..."
		wget -O "$_TMPDLFILE" "$_URL_MIRROR"
	fi

	bs_print "Checking file hash..."
	echo "$_MD5HASH" "$_TMPDLFILE" | md5sum --check -

	bs_print "Unpacking archive..."
	tar xvf "$_TMPDLFILE" --directory="$_APP_DIR"
	bs_print "Cleaning up after ourselves..."
	rm -f "$_TMPDLFILE"
fi

bs_print "Handing over to app..."
bs_cd "$_APP_DIR"

exec dotnet ./VintagestoryServer.dll --dataPath /data "$@"
