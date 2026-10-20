#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/app/portainer"
COMPOSE_FILE="$APP_DIR/docker-compose.yml"
NETWORK_NAME="app_network"
CONTAINER_NAME="portainer"

echo "========================================"
echo "Deploying Portainer"
echo "========================================"

# 1. Verify Docker
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed."
    exit 1
fi

echo "Docker version:"
docker --version

# 2. Verify Docker Compose V1
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "ERROR: docker-compose is not installed."
    exit 1
fi

echo "Docker Compose version:"
docker-compose --version

# 3. Verify Compose file
if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "ERROR: Compose file not found: $COMPOSE_FILE"
    exit 1
fi

cd "$APP_DIR"

# 4. Verify Docker network
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "ERROR: Docker network '$NETWORK_NAME' does not exist."
    echo "Create it with: docker network create $NETWORK_NAME"
    exit 1
fi

# 5. Validate Compose configuration
echo "Validating Docker Compose configuration..."
docker-compose config >/dev/null

# 6. Pull the Portainer image
echo "Pulling Portainer image..."
docker-compose pull

# 7. Start or update Portainer
echo "Starting Portainer..."
docker-compose up -d --remove-orphans

# 8. Verify the container
echo "Checking Portainer status..."
sleep 5

if [[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null || true)" != "true" ]]; then
    echo "ERROR: Portainer is not running."
    docker logs --tail 100 "$CONTAINER_NAME" || true
    exit 1
fi

echo "========================================"
echo "Portainer deployed successfully!"
echo "========================================"

docker ps --filter "name=^/${CONTAINER_NAME}$"

echo ""
echo "Expected URL: https://vps.acertijo.dev"
echo "Ensure DNS, Nginx reverse proxy and SSL are configured."