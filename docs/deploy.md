# Deploy Guide (EC2 + Docker Compose)

## Prerequisites

- EC2 with Docker + Docker Compose
- `.env` at repo root (see `.env.example`)
- DNS → EC2 (e.g. `transpachain.site`)
- Let's Encrypt certs mounted at `/etc/letsencrypt`

## Backend image (pull, not local build)

`docker-compose.yml` uses **pre-built images** for backend (`cuongnguyen146/transpachain-backend:latest`) — there is no `build:` block for backend on EC2.

| Service | EC2 update path |
|---------|-----------------|
| **Backend** | GitHub Actions builds + pushes on push to `main` → EC2 runs `docker compose pull` |
| **Frontend** | Optional local `docker compose build frontend` with `.env` build-args, or pull from Docker Hub after CI |

Backend at commit `48c2859` includes: `historicalSync` backfill, rate limiting, `errorHandler`, production `CORS_ORIGIN`.

To build/push backend manually (e.g. before CI runs):

```bash
cd ~/transpachain/backend
docker build -t cuongnguyen146/transpachain-backend:latest .
docker push cuongnguyen146/transpachain-backend:latest
```

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
  --build-arg NEXT_PUBLIC_USDC_ADDRESS="$NEXT_PUBLIC_USDC_ADDRESS" \
  -t cuongnguyen146/transpachain-frontend:latest .
```

Or: `make docker-build-frontend` from monorepo root.

Set `NEXT_PUBLIC_USDC_ADDRESS` in root `.env` for USDC donate (Sepolia Circle USDC: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`).

## GitHub Actions

Workflow: [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml)

Set repository secrets (values not stored in repo):

| Secret | Purpose |
|--------|---------|
| `GH_PAT` | Checkout private submodules in CI |
| `DOCKERHUB_USERNAME` | Push images |
| `DOCKERHUB_TOKEN` | Push images |
| `NEXT_PUBLIC_ALCHEMY_KEY` | Frontend build-arg |
| `NEXT_PUBLIC_CHARITY_CORE_ADDRESS` | Frontend build-arg |
| `NEXT_PUBLIC_DONATION_VAULT_ADDRESS` | Frontend build-arg |
| `NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS` | Frontend build-arg |
| `NEXT_PUBLIC_IMPACT_NFT_ADDRESS` | Frontend build-arg |
| `NEXT_PUBLIC_USDC_ADDRESS` | Frontend build-arg (USDC donate) |
| `EC2_HOST` | Deploy SSH target |
| `EC2_SSH_KEY` | Deploy SSH private key |

CI builds both images with `NEXT_PUBLIC_*` build-args, pushes to Docker Hub, then SSHs to EC2 and runs `docker compose pull && docker compose up -d`.

## EC2 update (English)

```bash
cd ~/transpachain
git pull && git submodule update --init --recursive
set -a && source .env && set +a
docker compose pull
docker compose up -d --force-recreate backend frontend
docker compose logs -f backend   # Ctrl+C when indexer + backfill look OK
```

Requires `postcss.config.js` in the frontend submodule (Tailwind). After deploy, verify CSS is compiled (not raw `@tailwind`):

```bash
curl -s https://transpachain.site | grep -oE '/_next/static/[^"]+\.css' | head -1
curl -s "https://transpachain.site/<that-path>" | head -c 80   # should NOT contain @tailwind
curl -I https://transpachain.site/logo.svg                      # expect 200
```

## EC2 update (detailed — run via SSH)

SSH into EC2 and run the steps below. Frontend should already be deployed (CSS, logo OK).

### 1. Pull latest code + submodules

```bash
cd ~/transpachain
git pull origin main
git submodule update --init --recursive
```

### 2. Verify / update `.env` (repo root)

Compared to `.env.example`, ensure these are set (use real values if missing):

```bash
# Required for production
CORS_ORIGIN=https://transpachain.site
ALCHEMY_SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY

# Indexer backfill — Sepolia contract deploy block (see Etherscan deploy tx). 0 = disabled.
DEPLOY_FROM_BLOCK=11102718
# Alchemy Free: eth_getLogs max ~10 blocks per request (backend chunks by default)
INDEXER_LOG_CHUNK_SIZE=10

# USDC donate on frontend (Sepolia Circle USDC)
NEXT_PUBLIC_USDC_ADDRESS=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238

# Contract addresses (current Sepolia deploy)
CHARITY_CORE_ADDRESS=0x8a5e023b16ab13939260492dAe72a0be1E597e1a
DONATION_VAULT_ADDRESS=0x68Bb9f5E1414b1a62372EbF02fdEe4c09fFc7C32
GOVERNANCE_DAO_ADDRESS=0xCcAEaF248E536850877B9f948cB237Fe7885b513
IMPACT_NFT_ADDRESS=0xD651d3531a44ee7941bFE257c79F41d274E180A6
NEXT_PUBLIC_CHARITY_CORE_ADDRESS=0x8a5e023b16ab13939260492dAe72a0be1E597e1a
NEXT_PUBLIC_DONATION_VAULT_ADDRESS=0x68Bb9f5E1414b1a62372EbF02fdEe4c09fFc7C32
NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS=0xCcAEaF248E536850877B9f948cB237Fe7885b513
NEXT_PUBLIC_IMPACT_NFT_ADDRESS=0xD651d3531a44ee7941bFE257c79F41d274E180A6
```

### 3. Update Docker (backend pull from Hub, no local build)

Backend has **no** `build:` in compose — image is built/pushed by CI. On EC2:

```bash
cd ~/transpachain
set -a && source .env && set +a
docker compose pull
docker compose up -d --force-recreate backend frontend nginx
```

If CI has not finished, you can build frontend locally:

```bash
docker compose build --no-cache frontend
docker compose up -d --force-recreate frontend
```

### 4. Verify backend + indexer

```bash
docker compose logs backend --tail 80
```

Expected in logs:

- Server/API started (port 3001)
- `[Indexer]` listening for events
- If `DEPLOY_FROM_BLOCK` > 0: historical backfill (older campaigns/donations)

Health check:

```bash
curl -s https://transpachain.site/api/health
```

### 5. Live demo checklist (5 minutes)

Per [demo-script.md](./demo-script.md):

- [ ] **Homepage** — stats (campaigns, ETH donated, donors); explain milestone escrow
- [ ] **Admin** (optional) — Admin tab, verify org wallet; mention `VERIFIER_ROLE`
- [ ] **Campaign** — progress bar, milestones, ETH/USDC token; donate via MetaMask Sepolia → first Impact NFT
- [ ] **Refund** — failed/expired campaign → Claim refund panel
- [ ] **Governance** — milestone proof, donor vote, timelock
- [ ] **Transparency** — Etherscan tx links; indexer MongoDB + IPFS; `/legal` disclaimer
- [ ] **Bonus** — repeat donate upgrades NFT tier (requires new contract redeploy); USDC approve + donate

---

## Redeploy contract Sepolia (optional)

**Do you need to redeploy?** — **Yes**, if you want **NFT tier upgrade on repeat donate** (new bytecode at contracts commit `63300f6`). Current Sepolia contracts were deployed before that upgrade; frontend/backend still run with the old addresses.

**Do not deploy** until `DEPLOYER_PRIVATE_KEY` is set in env.

### Prerequisites (local machine or EC2 with Foundry/Hardhat)

Trong `contracts/` (submodule):

```bash
# .env in contracts/ or export
DEPLOYER_PRIVATE_KEY=0x...          # REQUIRED — do not commit
USDC_ADDRESS=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
ETHERSCAN_API_KEY=...                # optional verify
```

### Option 1 — Foundry

```bash
cd contracts
forge script script/Deploy.s.sol:Deploy \
  --rpc-url "$ALCHEMY_SEPOLIA_URL" \
  --broadcast \
  -vvvv
```

Record the 4 printed addresses: CharityCore, ImpactNFT, GovernanceDAO, DonationVault.

### Option 2 — Hardhat

```bash
cd contracts
npx hardhat run hardhat/scripts/deploy.ts --network sepolia
```

Or from root: `make contracts-deploy`

### After redeploy

1. Update **all** env (root `.env`, GitHub secrets `NEXT_PUBLIC_*` + backend `CHARITY_*` / `DONATION_*` / …).
2. Set `DEPLOY_FROM_BLOCK` = new deploy block (Etherscan).
3. Rebuild frontend (new build-args) and push/pull image.
4. `docker compose up -d --force-recreate backend` — indexer backfill from new block.
5. Create new campaigns on the new contract; old data does not migrate automatically.

---

## Health check

```bash
curl https://transpachain.site/api/health
```

## HTTPS renewal

```bash
sudo certbot renew
docker compose restart nginx
```
