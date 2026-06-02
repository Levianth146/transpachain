# Deploy Guide (EC2 + Docker Compose)

## Prerequisites

- EC2 with Docker + Docker Compose
- `.env` at repo root (see `.env.example`)
- DNS → EC2 (e.g. `transpachain.site`)
- Let's Encrypt certs mounted at `/etc/letsencrypt`

## Frontend build-args (critical)

`NEXT_PUBLIC_*` variables are **baked in at `docker build`**, not at container runtime.

```bash
cd ~/transpachain
set -a && source .env && set +a
cd frontend
docker build --no-cache \
  --build-arg NEXT_PUBLIC_ALCHEMY_KEY="$NEXT_PUBLIC_ALCHEMY_KEY" \
  --build-arg NEXT_PUBLIC_CHARITY_CORE_ADDRESS="$NEXT_PUBLIC_CHARITY_CORE_ADDRESS" \
  --build-arg NEXT_PUBLIC_DONATION_VAULT_ADDRESS="$NEXT_PUBLIC_DONATION_VAULT_ADDRESS" \
  --build-arg NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS="$NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS" \
  --build-arg NEXT_PUBLIC_IMPACT_NFT_ADDRESS="$NEXT_PUBLIC_IMPACT_NFT_ADDRESS" \
  -t cuongnguyen146/transpachain-frontend:latest .
```

Or: `make docker-build-frontend` from monorepo root.

## GitHub Actions

Set repository secrets:

- `NEXT_PUBLIC_ALCHEMY_KEY`
- `NEXT_PUBLIC_CHARITY_CORE_ADDRESS`
- `NEXT_PUBLIC_DONATION_VAULT_ADDRESS`
- `NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS`
- `NEXT_PUBLIC_IMPACT_NFT_ADDRESS`
- `DOCKERHUB_*`, `EC2_*` (existing)

Workflow: [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml)

## EC2 update

```bash
cd ~/transpachain
git pull && git submodule update --init --recursive
docker compose pull   # if using prebuilt images from CI
# OR docker compose build frontend
docker compose up -d
```

## Health check

```bash
curl https://transpachain.site/api/health
```

## HTTPS renewal

```bash
sudo certbot renew
docker compose restart nginx
```
