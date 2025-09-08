#!/bin/bash

# Determine which Docker Compose command to use
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE="docker-compose"
else
    echo "Error: Neither docker compose nor docker-compose command found" >&2
    exit 1
fi

# Wenn keine Argumente übergeben wurden → Standardbefehl setzen
if [ $# -eq 0 ]; then
    set -- up --build
fi

# Prüfen, ob das Image existiert
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "Docker-Image $IMAGE_NAME nicht gefunden → build.sh aufrufen..."
    chmod +x start.sh
    ./build.sh
else
    echo "Docker-Image $IMAGE_NAME gefunden → build.sh wird nicht aufgerufen."
fi

# Execute Docker Compose command
$COMPOSE -f docker-compose.yml "$@"