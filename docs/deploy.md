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

## Hướng dẫn cập nhật EC2 (còn lại — chạy qua SSH)

Các bước dưới đây **bạn tự SSH vào EC2** và chạy copy-paste. Frontend đã deploy (CSS, logo OK).

### 1. Kéo code mới + submodule

```bash
cd ~/transpachain
git pull origin main
git submodule update --init --recursive
```

### 2. Kiểm tra / bổ sung `.env` (thư mục gốc repo)

So với `.env.example`, đảm bảo có (điền giá trị thật nếu thiếu):

```bash
# Bắt buộc cho production
CORS_ORIGIN=https://transpachain.site
ALCHEMY_SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY

# Indexer backfill — block deploy contract Sepolia (xem Etherscan tx deploy). 0 = tắt.
DEPLOY_FROM_BLOCK=
# Alchemy Free: eth_getLogs tối đa ~10 block/lần (mặc định backend đã chunk)
INDEXER_LOG_CHUNK_SIZE=10

# USDC donate trên frontend (Sepolia Circle USDC)
NEXT_PUBLIC_USDC_ADDRESS=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238

# Địa chỉ contract (giữ nguyên nếu chưa redeploy — xem mục Redeploy bên dưới)
CHARITY_CORE_ADDRESS=0x6fEEF9276B2215F0d41a0c7515Ea6718099552d4
DONATION_VAULT_ADDRESS=0x016377C129f1d7B0Abbda97B8676D273F419cBAb
GOVERNANCE_DAO_ADDRESS=0x558e7811ae467f82A60E5c6FEa7aaeAae61f2c44
IMPACT_NFT_ADDRESS=0x6B6e671EfB7fbEaBF41a7cCC4683F3683c88e5fd
NEXT_PUBLIC_CHARITY_CORE_ADDRESS=...
NEXT_PUBLIC_DONATION_VAULT_ADDRESS=...
# (các NEXT_PUBLIC_* contract khác tương ứng)
```

### 3. Cập nhật Docker (backend pull từ Hub, không build local)

Backend **không có** `build:` trong compose — image do CI build/push. Trên EC2:

```bash
cd ~/transpachain
set -a && source .env && set +a
docker compose pull
docker compose up -d --force-recreate backend frontend nginx
```

Nếu CI chưa chạy xong, có thể build frontend local:

```bash
docker compose build --no-cache frontend
docker compose up -d --force-recreate frontend
```

### 4. Xác minh backend + indexer

```bash
docker compose logs backend --tail 80
```

Kỳ vọng trong log:

- Server/API khởi động (port 3001)
- `[Indexer]` lắng nghe events
- Nếu `DEPLOY_FROM_BLOCK` > 0: thấy backfill historical (campaign/donation cũ)

Health check:

```bash
curl -s https://transpachain.site/api/health
```

### 5. Checklist demo live (5 phút)

Theo [demo-script.md](./demo-script.md):

- [ ] **Trang chủ** — stats (campaigns, ETH donated, donors); giải thích milestone escrow
- [ ] **Admin** (tùy chọn) — tab Admin, verify org wallet; nhắc `VERIFIER_ROLE`
- [ ] **Campaign** — progress bar, milestones, token ETH/USDC; donate MetaMask Sepolia → Impact NFT lần đầu
- [ ] **Refund** — campaign failed/expired → panel Claim refund
- [ ] **Governance** — milestone proof, donor Vote, timelock
- [ ] **Minh bạch** — link Etherscan tx; indexer MongoDB + IPFS; disclaimer `/legal`
- [ ] **Bonus** — repeat donate nâng tier NFT (cần contract redeploy mới); USDC approve + donate

---

## Redeploy contract Sepolia (tùy chọn)

**Có cần redeploy không?** — **Có**, nếu bạn muốn tính năng **NFT tier upgrade khi donate lại** (bytecode mới tại commit contracts `63300f6`). Contract hiện trên Sepolia deploy trước upgrade; frontend/backend vẫn chạy với địa chỉ cũ.

**Không chạy deploy** nếu chưa set `DEPLOYER_PRIVATE_KEY` trong env.

### Chuẩn bị (máy local hoặc EC2 có Foundry/Hardhat)

Trong `contracts/` (submodule):

```bash
# .env trong contracts/ hoặc export
DEPLOYER_PRIVATE_KEY=0x...          # BẮT BUỘC — không commit
USDC_ADDRESS=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
ETHERSCAN_API_KEY=...                # tùy chọn verify
```

### Cách 1 — Foundry

```bash
cd contracts
forge script script/Deploy.s.sol:Deploy \
  --rpc-url "$ALCHEMY_SEPOLIA_URL" \
  --broadcast \
  -vvvv
```

Ghi lại 4 địa chỉ in ra: CharityCore, ImpactNFT, GovernanceDAO, DonationVault.

### Cách 2 — Hardhat

```bash
cd contracts
npx hardhat run hardhat/scripts/deploy.ts --network sepolia
```

Hoặc từ root: `make contracts-deploy`

### Sau redeploy

1. Cập nhật **tất cả** env (root `.env`, GitHub secrets `NEXT_PUBLIC_*` + backend `CHARITY_*` / `DONATION_*` / …).
2. Set `DEPLOY_FROM_BLOCK` = block deploy mới (Etherscan).
3. Rebuild frontend (build-args mới) và push/pull image.
4. `docker compose up -d --force-recreate backend` — indexer backfill từ block mới.
5. Tạo campaign mới trên contract mới; dữ liệu cũ không migrate tự động.

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
