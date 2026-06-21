#!/usr/bin/env bash
# Pull frontend image from GHCR and restart (no build on EC2).
# Usage: FRONTEND_TAG=<sha> ./scripts/deploy-frontend-ec2.sh
#   or:  ./scripts/deploy-frontend-ec2.sh <TAG>

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/levianth146/transpachain-frontend"
TAG="${FRONTEND_TAG:-${1:-latest}}"
export FRONTEND_TAG="${TAG}"

ensure_ghcr_login() {
  if docker pull "${IMAGE}:${TAG}" >/dev/null 2>&1; then
    return 0
  fi

  echo "==> GHCR pull failed — attempting docker login"
  local user="${GHCR_USER:-levianth146}"
  local token="${GHCR_TOKEN:-${GITHUB_TOKEN:-}}"

  if [[ -z "${token}" ]]; then
    echo "ERROR: Cannot pull ${IMAGE}:${TAG}"
    echo "Set GHCR_TOKEN (GitHub PAT with read:packages) or run:"
    echo "  echo \$GITHUB_PAT | docker login ghcr.io -u levianth146 --password-stdin"
    exit 1
  fi

  echo "${token}" | docker login "${REGISTRY}" -u "${user}" --password-stdin
}

echo "==> Deploy frontend tag: ${TAG}"
ensure_ghcr_login

echo "==> Pull ${IMAGE}:${TAG}"
docker pull "${IMAGE}:${TAG}"

if [[ ! -f docker-compose.prod.yml ]]; then
  echo "ERROR: docker-compose.prod.yml not found. Run git pull in ~/transpachain."
  exit 1
fi

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

echo "==> Restart frontend (+ nginx)"
docker compose -f docker-compose.prod.yml up -d --force-recreate frontend nginx

echo ""
echo "Done. Verify:"
echo "  docker compose -f docker-compose.prod.yml ps frontend"
echo "  curl -I https://transpachain.site/logo.svg"
echo ""
