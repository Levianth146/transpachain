#!/usr/bin/env bash
# Build frontend on WSL, tag, and push to GHCR.
# Usage: ./scripts/deploy-frontend-wsl.sh [TAG]
#   TAG defaults to git short SHA in the monorepo.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/levianth146/transpachain-frontend"
TAG="${1:-$(git rev-parse --short HEAD)}"

echo "==> Sync frontend submodule"
git submodule update --init --recursive frontend

if [[ ! -f .env ]]; then
  echo "ERROR: Missing .env at repo root. Copy from .env.example and fill NEXT_PUBLIC_* values."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

for var in NEXT_PUBLIC_ALCHEMY_KEY NEXT_PUBLIC_CHARITY_CORE_ADDRESS \
  NEXT_PUBLIC_DONATION_VAULT_ADDRESS NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS \
  NEXT_PUBLIC_IMPACT_NFT_ADDRESS NEXT_PUBLIC_USDC_ADDRESS; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: $var is empty in .env (required at docker build time)."
    exit 1
  fi
done

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running. Start Docker Desktop / dockerd on WSL."
  exit 1
fi

echo "==> Build ${IMAGE}:${TAG}"
docker build \
  --build-arg "NEXT_PUBLIC_ALCHEMY_KEY=${NEXT_PUBLIC_ALCHEMY_KEY}" \
  --build-arg "NEXT_PUBLIC_CHARITY_CORE_ADDRESS=${NEXT_PUBLIC_CHARITY_CORE_ADDRESS}" \
  --build-arg "NEXT_PUBLIC_DONATION_VAULT_ADDRESS=${NEXT_PUBLIC_DONATION_VAULT_ADDRESS}" \
  --build-arg "NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS=${NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS}" \
  --build-arg "NEXT_PUBLIC_IMPACT_NFT_ADDRESS=${NEXT_PUBLIC_IMPACT_NFT_ADDRESS}" \
  --build-arg "NEXT_PUBLIC_USDC_ADDRESS=${NEXT_PUBLIC_USDC_ADDRESS}" \
  -t "${IMAGE}:${TAG}" \
  -t "${IMAGE}:latest" \
  ./frontend

echo "==> Push to GHCR"
docker push "${IMAGE}:${TAG}"
docker push "${IMAGE}:latest"

echo ""
echo "=========================================="
echo " Push complete: ${IMAGE}:${TAG}"
echo "=========================================="
echo ""
echo "On EC2 (after git pull for scripts/compose), run:"
echo ""
echo "  cd ~/transpachain"
echo "  FRONTEND_TAG=${TAG} ./scripts/deploy-frontend-ec2.sh"
echo ""
echo "Or manually:"
echo ""
echo "  cd ~/transpachain"
echo "  export FRONTEND_TAG=${TAG}"
echo "  docker pull ${IMAGE}:${TAG}"
echo "  docker compose -f docker-compose.prod.yml up -d --force-recreate frontend nginx"
echo ""
