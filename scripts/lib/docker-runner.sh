#!/bin/bash
# Generic Docker wrapper for running commands in Linux environment

set -e

[ $# -eq 0 ] && { echo "Usage: $0 <command> [args...]" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DOCKER_IMAGE=${DOCKER_IMAGE:-"cpp-toolchain-linux"}
DOCKERFILE="$PROJECT_ROOT/scripts/Dockerfile.linux"

# Build Docker image if needed
docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1 || 
    docker build -f "$DOCKERFILE" -t "$DOCKER_IMAGE" "$PROJECT_ROOT/scripts" >/dev/null

# Setup SSL certificate configuration
SSL_CONFIG=()
if [ -n "$SSL_CERT_FILE" ] && [ -f "$SSL_CERT_FILE" ]; then
    SSL_CONFIG+=(-v "$SSL_CERT_FILE:$SSL_CERT_FILE:ro")
    SSL_CONFIG+=(-e "SSL_CERT_FILE=$SSL_CERT_FILE")
    SSL_CONFIG+=(-e "REQUESTS_CA_BUNDLE=$SSL_CERT_FILE")
    SSL_CONFIG+=(-e "CURL_CA_BUNDLE=$SSL_CERT_FILE")
    SSL_CONFIG+=(-e "GIT_SSL_CAINFO=$SSL_CERT_FILE")
fi

# Run command
docker run -it --rm \
  -v "$PROJECT_ROOT:/workspace" \
  "${SSL_CONFIG[@]}" \
  -w /workspace \
  -e BUILD_DIR \
  "$DOCKER_IMAGE" \
  "$@"