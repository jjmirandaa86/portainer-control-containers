\#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/app/portainer"
COMPOSE_FILE="$APP_DIR/docker-compose.yml"

echo "========================================"
echo "Deploying Portainer"
echo "========================================"

# 1. Verify Docker is installed

if ! command -v docker >/dev/null 2>&1; then
echo "ERROR: Docker is not installed."
exit 1
fi

# 2. Verify Docker Compose is available

if ! docker compose version >/dev/null 2>&1; then
echo "ERROR: Docker Compose is not available."
exit 1
fi

# 3. Verify deployment files

if [[ ! -f "$COMPOSE_FILE" ]]; then
echo "ERROR: Compose file not found: $COMPOSE_FILE"
exit 1
fi

# 4. Verify the existing Docker network

if ! docker network inspect app_network >/dev/null 2>&1; then
echo "ERROR: Docker network 'app_network' does not exist."
echo "Create it with: docker network create app_network"
exit 1
fi

# 5. Deploy Portainer

cd "$APP_DIR"

echo "Pulling Portainer image..."
docker compose pull

echo "Starting Portainer..."
docker compose up -d --remove-orphans

# 6. Verify container status

echo "Waiting for Portainer to start..."
sleep 5

if ! docker inspect -f '{{.State.Running}}' portainer 2>/dev/null | grep -qx true; then
echo "ERROR: Portainer is not running."
docker logs --tail 100 portainer || true
exit 1
fi

echo "========================================"
echo "Portainer deployed successfully!"
echo "========================================"

docker ps --filter "name=^/portainer$"

echo ""
echo "Expected URL: [https://vps.acertijo.dev](https://vps.acertijo.dev)"
echo "Make sure Nginx and SSL are configured for this domain."
