#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

IMAGE_NAME="${AGOF_COLLECTIONS_IMAGE:-quay.io/validatedpatterns/agof-collections}"
TAG="${1:-latest}"
PUSH=false

for arg in "$@"; do
    if [ "$arg" = "--push" ]; then
        PUSH=true
    fi
done

if [ -z "${AUTOMATION_HUB_TOKEN:-}" ]; then
    echo "Error: AUTOMATION_HUB_TOKEN environment variable must be set"
    echo "Get your token from https://console.redhat.com/ansible/automation-hub/token"
    exit 1
fi

echo "Building ${IMAGE_NAME}:${TAG}..."
podman build \
    --build-arg "AUTOMATION_HUB_TOKEN=${AUTOMATION_HUB_TOKEN}" \
    -t "${IMAGE_NAME}:${TAG}" \
    -f collections-container/Containerfile \
    "${REPO_ROOT}"

echo "Built ${IMAGE_NAME}:${TAG}"

if [ "$PUSH" = true ]; then
    echo "Pushing ${IMAGE_NAME}:${TAG}..."
    podman push "${IMAGE_NAME}:${TAG}"
    echo "Pushed ${IMAGE_NAME}:${TAG}"
fi
