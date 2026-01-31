#!/usr/bin/env bash

set -euo pipefail

: "${FTP_USER:?missing}"
: "${FTP_PASS:?missing}"

FTP_HOST="ftp.tnds.basemap.co.uk"
REMOTE_FILE="S.zip"
DOWNLOAD_DIR="/app/data/input"

# Ensure download dir exists
mkdir -p "$DOWNLOAD_DIR"

# Download only if missing
if [[ ! -f "$DOWNLOAD_DIR/$REMOTE_FILE" ]]; then
    echo "$DOWNLOAD_DIR/$REMOTE_FILE not found"
    echo "Connecting securely to FTP..."

    lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" <<EOF
set net:max-retries 3
set net:timeout 20

# Trust CA but ignore broken hostname
set ssl:check-hostname no

ls
get "$REMOTE_FILE" -o "$DOWNLOAD_DIR/$REMOTE_FILE"
bye
EOF
    echo "Downloaded to $DOWNLOAD_DIR/$REMOTE_FILE"
else
    echo "$DOWNLOAD_DIR/$REMOTE_FILE already exists, skipping download"
fi

UNZIP_DIR="$DOWNLOAD_DIR/unzipped"
if [[ ! -d "$UNZIP_DIR" ]]; then
    echo "$UNZIP_DIR does not exist, creating and unzipping..."
    mkdir -p "$UNZIP_DIR"
    unzip -o "$DOWNLOAD_DIR/$REMOTE_FILE" -d "$UNZIP_DIR/"
else
  echo "$UNZIP_DIR exists"
fi


./txc-loader
