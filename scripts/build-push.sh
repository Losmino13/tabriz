#!/usr/bin/env bash
# Usage: scripts/build-push.sh <dev|prod> [tag]   (tag defaults to the short commit SHA)

set -euo pipefail

ENVIRONMENT="${1:?Usage: $0 <dev|prod> [tag]}"
TAG="${2:-$(git rev-parse --short=6 HEAD)}"

AWS_REGION="${AWS_REGION:-eu-central-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/tabriz-${ENVIRONMENT}/web:${TAG}"

cd "$(git rev-parse --show-toplevel)"

aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"

docker buildx build --platform linux/amd64 --tag "${IMAGE}" --push .

echo "Pushed ${IMAGE}"
