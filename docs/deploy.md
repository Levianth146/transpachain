# Deploy Guide (Docker Hub + EC2)

Primary deployment flow: **build frontend on WSL**, **push to Docker Hub**, **EC2 pulls pre-built images**. Backend image is built by GitHub Actions on push to `main`.

**Optional GHCR workflow:** [deploy-ghcr.md](./deploy-ghcr.md)

**Live site:** https://transpachain.site

---

## Architecture on EC2

| Service | Image | Update method |
|---------|-------|---------------|
| **Frontend** | `cuongnguyen146/transpachain-frontend:latest` | WSL `make docker-build-frontend` + push, or CI |
| **Backend** | `cuongnguyen146/transpachain-backend:latest` | GitHub Actions → EC2 `docker compose pull` |
| **MongoDB** | `mongo:7` | Pulled by compose |
| **Nginx** | Built from `nginx/` | Git pull on monorepo |

`docker-compose.yml` has **no `build:` block for backend on EC2** — always pull from Docker Hub.

---

## Prerequisites

- EC2 instance with Docker + Docker Compose
- Monorepo cloned with submodules: `git clone --recurse-submodules …`
- Root `.env` filled from [`.env.example`](../.env.example)
- DNS → EC2 (e.g. `transpachain.site`)
- Let's Encrypt certs at `/etc/letsencrypt` (nginx config)

### Submodule setup

```bash
cd ~/transpachain
git submodule update --init --recursive
# backend/  → transpachain-backend
# frontend/ → transpachain-frontend
# contracts/ → transpachain-contracts
```

---

## Environment variables (production)

Copy `.env.example` → `.env` on EC2. Critical values:

```env
# Production
CORS_ORIGIN=https://transpachain.site
# Free public RPCs — no API key required. ALCHEMY_SEPOLIA_URL is an optional
# paid-RPC alias that takes precedence when set; leave it empty otherwise.
SEPOLIA_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
SEPOLIA_RPC_FALLBACK_URL=https://sepolia.drpc.org
ALCHEMY_SEPOLIA_URL=
MONGODB_URI=mongodb://mongodb:27017/transpachain

# Indexer — Sepolia contract deploy block (Etherscan). 0 = skip backfill (already done).
DEPLOY_FROM_BLOCK=0
INDEXER_LOG_CHUNK_SIZE=10
# Live-poll interval (ms) — 60000 conserves public-RPC quota
INDEXER_POLL_INTERVAL_MS=60000

# Backend contract addresses
CHARITY_CORE_ADDRESS=0xCE017838BfE2785CB2458bb205770663bEB9b0B8
DONATION_VAULT_ADDRESS=0xEb421D07E885EeB2B8E9ea408FF284013F872Db1
GOVERNANCE_DAO_ADDRESS=0xd655d85ddACc386901487CE8E1ec45BD4F872A19
IMPACT_NFT_ADDRESS=0xF2556FcccaE36A6d8Da0C75a863CA7368FC6761a

# Frontend build-args (baked into client JS at docker build)
# Optional — leave empty to use free PublicNode/dRPC transports in the browser
NEXT_PUBLIC_ALCHEMY_KEY=
NEXT_PUBLIC_CHARITY_CORE_ADDRESS=0xCE017838BfE2785CB2458bb205770663bEB9b0B8
NEXT_PUBLIC_DONATION_VAULT_ADDRESS=0xEb421D07E885EeB2B8E9ea408FF284013F872Db1
NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS=0xd655d85ddACc386901487CE8E1ec45BD4F872A19
NEXT_PUBLIC_IMPACT_NFT_ADDRESS=0xF2556FcccaE36A6d8Da0C75a863CA7368FC6761a
NEXT_PUBLIC_USDC_ADDRESS=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238

# Pinata (backend IPFS)
PINATA_API_KEY=
PINATA_SECRET_KEY=
```

After indexer backfill completes, set `DEPLOY_FROM_BLOCK=0` to speed up restarts.

---

## Primary flow: WSL build → Docker Hub → EC2 pull

### 1. Build and push frontend (WSL / dev machine)

```bash
cd ~/projects/transpachain
cp .env.example .env   # fill NEXT_PUBLIC_* and other vars
git submodule update --init --recursive frontend

# Build with env baked in
make docker-build-frontend

# Push to Docker Hub
docker push cuongnguyen146/transpachain-frontend:latest
```

Or manually:

```bash
set -a && source .env && set +a
cd frontend
docker build \
  --build-arg NEXT_PUBLIC_ALCHEMY_KEY="$NEXT_PUBLIC_ALCHEMY_KEY" \
  --build-arg NEXT_PUBLIC_CHARITY_CORE_ADDRESS="$NEXT_PUBLIC_CHARITY_CORE_ADDRESS" \
  --build-arg NEXT_PUBLIC_DONATION_VAULT_ADDRESS="$NEXT_PUBLIC_DONATION_VAULT_ADDRESS" \
  --build-arg NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS="$NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS" \
  --build-arg NEXT_PUBLIC_IMPACT_NFT_ADDRESS="$NEXT_PUBLIC_IMPACT_NFT_ADDRESS" \
  --build-arg NEXT_PUBLIC_USDC_ADDRESS="$NEXT_PUBLIC_USDC_ADDRESS" \
  -t cuongnguyen146/transpachain-frontend:latest .
docker push cuongnguyen146/transpachain-frontend:latest
```

> **Important:** `NEXT_PUBLIC_*` variables are embedded at **build time**, not runtime. Any address or RPC key change requires a rebuild and push.

### 2. Backend via GitHub Actions

Workflow: [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml)

On push to `main`, CI builds both images with build-args, pushes to Docker Hub, SSHs to EC2, runs `docker compose pull && docker compose up -d`.

Repository secrets required:

| Secret | Purpose |
|--------|---------|
| `GH_PAT` | Checkout private submodules |
| `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` | Push images |
| `NEXT_PUBLIC_*` (6 vars) | Frontend build-args |
| `EC2_HOST` / `EC2_SSH_KEY` | Deploy target |

Manual backend push (if CI unavailable):

```bash
cd backend
docker build -t cuongnguyen146/transpachain-backend:latest .
docker push cuongnguyen146/transpachain-backend:latest
```

### 3. EC2 update

```bash
ssh ubuntu@YOUR_EC2_IP
cd ~/transpachain
git pull origin main
git submodule update --init --recursive
set -a && source .env && set +a
docker compose pull
docker compose up -d --force-recreate backend frontend nginx
docker compose logs -f backend   # wait for indexer + backfill
```

---

## Verification checklist

```bash
# Health
curl -s https://transpachain.site/api/health | jq .

# CSS compiled (not raw @tailwind)
curl -s https://transpachain.site | grep -oE '/_next/static/[^"]+\.css' | head -1
# curl that path — should NOT contain "@tailwind"

# Static assets
curl -I https://transpachain.site/logo.svg   # expect 200
```

Expected backend logs:

- Server started on port 3001
- `[Indexer]` listening for events
- Historical backfill progress (if `DEPLOY_FROM_BLOCK > 0`)

Indexer sync: `/api/health` → `indexer.inSync: true` when `onChainCampaigns === indexedCampaigns`.

---

## Local development

```bash
git clone --recurse-submodules https://github.com/Levianth146/transpachain.git
cd transpachain
cp .env.example .env
docker compose up -d

# Optional demo seed
cd backend && npm run seed
```

Access: `http://localhost`

Individual services:

```bash
make backend-dev    # port 3001
make frontend-dev   # port 3000
make contracts-test # forge test
```

---

## Contract redeploy (optional)

Only needed when deploying **new contract bytecode** (e.g. after changing Solidity). Current Sepolia addresses are in `.env.example`.

```bash
cd contracts
# Set DEPLOYER_PRIVATE_KEY, USDC_ADDRESS in contracts/.env
make contracts-deploy   # or: npx hardhat run hardhat/scripts/deploy.ts --network sepolia
```

After redeploy:

1. Update all `CHARITY_*` / `NEXT_PUBLIC_*` addresses in `.env`, GitHub secrets, and CI.
2. Set `DEPLOY_FROM_BLOCK` to new deploy block (Etherscan).
3. Rebuild and push frontend image.
4. Restart backend — indexer backfills from new block.
5. Run reconcile: `POST /api/admin/reconcile-campaigns`.
6. Create new campaigns; old deployment data does not migrate automatically.

---

## HTTPS renewal

```bash
sudo certbot renew
docker compose restart nginx
```

---

## Related docs

- [deploy-ghcr.md](./deploy-ghcr.md) — alternative GHCR registry flow
- [demo-guide.md](./demo-guide.md) — pre-demo checklist
- [architecture.md](./architecture.md) — system overview
- [mongodb-guide.md](./mongodb-guide.md) — database setup
