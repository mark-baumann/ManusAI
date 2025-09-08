#!/bin/bash
# Railpack-kompatibles Startskript mit Docker-Prüfung

# Name des Docker-Images anpassen
IMAGE_NAME="mein-projekt_image"

# Prüfen, ob Docker verfügbar ist
if ! command -v docker &> /dev/null; then
    echo "Error: Docker ist nicht installiert oder nicht im PATH!" >&2
    exit 1
fi

# Prüfen, ob Docker Compose verfügbar ist
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    COMPOSE="docker compose"
    echo "Docker Compose gefunden (docker compose)"
elif command -v docker-compose &> /dev/null; then
    COMPOSE="docker-compose"
    echo "Docker Compose gefunden (docker-compose)"
else
    echo "Error: Weder 'docker compose' noch 'docker-compose' gefunden!" >&2
    exit 1
fi

# Prüfen, ob das Docker-Image existiert
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "Docker-Image $IMAGE_NAME nicht gefunden → build.sh aufrufen..."
    if [ -x ./build.sh ]; then
        ./build.sh
    else
        echo "Error: build.sh existiert nicht oder ist nicht ausführbar!" >&2
        exit 1
    fi
else
    echo "Docker-Image $IMAGE_NAME gefunden → build.sh wird nicht aufgerufen."
fi

# Container starten (Standard: up, wenn keine Argumente übergeben)
if [ $# -eq 0 ]; then
    set -- up
fi

# Docker Compose ausführen
$COMPOSE -f docker-compose.yml "$@"
