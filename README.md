# TranspaChain

> Transparent charity on Ethereum — milestone-based escrow, DAO governance, and verifiable impact

**Live demo:** https://transpachain.site  
**Network:** Ethereum Sepolia testnet (`chainId` 11155111)

---

## Mission

TranspaChain makes charitable giving auditable. Donations lock in on-chain escrow and release only when verified organizations prove milestone completion and donors approve via quadratic governance voting. Every transaction, vote, and fund release is traceable on Sepolia.

### Sepolia demo disclaimer

This project is a **testnet demonstration only**. Contracts hold test ETH and test USDC — not real money. Do not use TranspaChain for production fundraising without a full security audit and mainnet deployment. See the live [/legal](https://transpachain.site/legal) page and [docs/project-report.md](./docs/project-report.md) §10 for scope and limitations

---

## Key features

- **Milestone escrow** — funds release in slices only after governance approval
- **DAO governance** — quadratic donor voting (√donation weight) with 51% quorum and 24h timelock
- **Impact NFTs** — Bronze / Silver / Gold ERC-721 badges per campaign donation tier
- **Verified organizations** — admin-verified wallets (`ORG_ROLE`) required to create campaigns
- **Evidence + IPFS** — milestone images pinned via Pinata; admin review before public vote; orgs can **Upload to IPFS** for milestone proof CIDs; donors view full evidence in a modal
- **Multi-token donations** — ETH or Sepolia USDC
- **Real-time indexing** — Alchemy event listener writes MongoDB; Socket.io pushes live updates

---

## Documentation

| Document | Description |
|----------|-------------|
| [project-report.md](./docs/project-report.md) | **Full project report** — architecture, stack analysis, workflows, security, testing |
| [user-manual.md](./docs/user-manual.md) | User guide — donors, orgs, admins, troubleshooting |
| [demo-guide.md](./docs/demo-guide.md) | Demo checklist, 10-minute script, Q&A prep |
| [demo-script.md](./docs/demo-script.md) | Quick 5-minute demo reference card |
| [architecture.md](./docs/architecture.md) | System overview, components, data flows, env vars |
| [system-design.md](./docs/system-design.md) | Contracts, indexer, frontend Web3, security model |
| [workflow.md](./docs/workflow.md) | End-to-end workflows (onboard → donate → vote → refund) |
| [deploy.md](./docs/deploy.md) | **Primary deploy** — Docker Hub + EC2 |
| [deploy-ghcr.md](./docs/deploy-ghcr.md) | Optional GHCR frontend deploy |
| [smart-contracts-explained.md](./docs/smart-contracts-explained.md) | Contract FAQ and function reference |
| [security-audit.md](./docs/security-audit.md) | Security analysis and Slither instructions |
| [mongodb-guide.md](./docs/mongodb-guide.md) | MongoDB data flow, Compass, Atlas, indexedScope |
| [donate-flow.md](./docs/donate-flow.md) | ETH/USDC donate and refund sequence diagrams |
| [charity-business-flow.md](./docs/charity-business-flow.md) | Real-world charity vs on-chain mapping |
| [traditional-vs-transpachain.md](./docs/traditional-vs-transpachain.md) | Comparison table for stakeholders |
| [er-diagram.md](./docs/er-diagram.md) | MongoDB schema ER diagram |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Browser — Next.js 16 · wagmi v2 · viem         │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS / WSS
                ┌──────────┴──────────┐
                │  Nginx :443 (TLS)   │
                │  / → frontend       │
                │  /api → backend     │
                └──────────┬──────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │                                   │
  ┌──────┴──────┐                    ┌───────┴───────┐
  │ Backend     │                    │ Frontend      │
  │ :3001       │                    │ :3000         │
  │ Express     │                    │ Next.js       │
  └──────┬──────┘                    └───────────────┘
         │
         ├── MongoDB (indexed events + profiles)
         ├── Alchemy indexer (ethers.js v6)
         ├── Pinata IPFS (metadata + evidence)
         └── Socket.io (real-time UI)
                  │
                  ▼
         Ethereum Sepolia
         ┌─────────────────────────┐
         │ CharityCore             │
         │ DonationVault           │
         │ GovernanceDAO           │
         │ ImpactNFT               │
         └─────────────────────────┘
```

Full diagrams and data flows: [docs/architecture.md](./docs/architecture.md) · [docs/project-report.md](./docs/project-report.md)

---

## Tech stack

Each technology and its role **in this project**:

### Frontend (`transpachain-frontend`)

| Technology | Version | What it does here |
|------------|---------|-------------------|
| **Next.js** | 16.2 | App Router pages: campaigns, governance, dashboard, admin; production build baked into Docker image |
| **React** | 18.3 | UI components — donate modal, org actions, governance vote panel, NFT gallery |
| **TypeScript** | 5.x | Typed hooks (`useCharityCore`, `useDonationVault`), API client, contract ABIs |
| **Tailwind CSS** | 3.4 | Dark holo-mint glass theme — campaign cards, glass panels, responsive layout |
| **wagmi** | 2.9 | Wallet connect, `useReadContract` / `useWriteContract` for all on-chain transactions |
| **viem** | 2.13 | Sepolia chain config, Alchemy HTTP transport, transaction encoding |
| **ethers** | — | (via wagmi) ABI decoding for contract reads in campaign detail |
| **@tanstack/react-query** | 5.40 | Cached contract state behind wagmi hooks |
| **Socket.io client** | 4.8 | Live donation feed on homepage; admin panel updates |
| **framer-motion** | 12.40 | Page transitions, org action panel animations |
| **@phosphor-icons/react** | 2.1 | Icons across navigation, evidence, governance UI |
| **next-themes** | 0.4 | Dark/light mode toggle |

### Backend (`transpachain-backend`)

| Technology | Version | What it does here |
|------------|---------|-------------------|
| **Node.js** | 20+ | Runtime for API server and blockchain indexer |
| **Express** | 4.19 | REST routes: `/campaigns`, `/donations`, `/proposals`, `/orgs`, `/evidence`, `/admin`, `/ipfs` |
| **TypeScript** | 5.x | Typed routes, Mongoose models, indexer event handlers |
| **MongoDB** | 7 (Docker) | Persists indexed chain events + off-chain org profiles and evidence |
| **Mongoose** | 8.4 | Schemas: `campaigns`, `donations`, `proposals`, `verifiedorgs`, `orgprofiles`, `evidence` |
| **ethers.js** | 6.16 | Alchemy WebSocket/HTTP event listener; `indexedScope` on-chain reads |
| **Socket.io** | 4.7 | Emits `donationReceived`, `campaignUpdated`, `proposalUpdated` to frontend |
| **Alchemy** | — | Sepolia RPC + WebSocket for indexer; RPC health rotation on failure |
| **Pinata SDK** | 2.1 | Pins campaign metadata JSON and evidence images to IPFS |
| **multer** | 2.1 | In-memory file upload buffer for `POST /ipfs/upload` (max 10 MB) |
| **express-rate-limit** | 8.5 | 120 requests/minute per IP on all API routes |

### Smart contracts (`transpachain-contracts`)

| Technology | Version | What it does here |
|------------|---------|-------------------|
| **Solidity** | 0.8.20 | Four core contracts: CharityCore, DonationVault, GovernanceDAO, ImpactNFT |
| **Foundry** | — | **307 tests** — unit, fuzz, and full lifecycle integration |
| **Hardhat** | 2.22 | Sepolia deployment scripts and Etherscan verification |
| **OpenZeppelin** | 5.6 | `AccessControl`, `ReentrancyGuard`, `ERC721` for roles and NFT badges |

### DevOps & infrastructure

| Technology | What it does here |
|------------|-------------------|
| **Docker** | Containerizes frontend, backend, MongoDB, nginx on EC2 |
| **Docker Compose** | Orchestrates full stack from root `docker-compose.yml` |
| **Docker Hub** | Hosts `cuongnguyen146/transpachain-frontend` and `transpachain-backend` images |
| **Nginx** | TLS termination, `/api/` reverse proxy to backend, 10 MB upload limit |
| **AWS EC2** | Production host for https://transpachain.site |
| **Let's Encrypt** | TLS certificates referenced in `nginx/nginx.conf` |

---

## Smart contracts (Sepolia)

Addresses from [`.env.example`](./.env.example):

| Contract | Address |
|----------|---------|
| CharityCore | `0xCE017838BfE2785CB2458bb205770663bEB9b0B8` |
| DonationVault | `0xEb421D07E885EeB2B8E9ea408FF284013F872Db1` |
| GovernanceDAO | `0xd655d85ddACc386901487CE8E1ec45BD4F872A19` |
| ImpactNFT | `0xF2556FcccaE36A6d8Da0C75a863CA7368FC6761a` |
| USDC (Sepolia) | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` |

### Test coverage

**307 / 307 Foundry tests passing** — unit, fuzz, and integration across the full donation lifecycle.

```bash
make contracts-test   # from monorepo root
```

Details: [docs/smart-contracts-explained.md](./docs/smart-contracts-explained.md)

---

## Frontend routes

| Route | Purpose |
|-------|---------|
| `/` | Homepage — stats, FAQ, featured campaigns, live WebSocket donation feed |
| `/campaigns` | Campaign list with category/status filters |
| `/campaigns/[id]` | Campaign detail — donate, escrow card, org actions, evidence modal, voting |
| `/campaigns/create` | Create campaign (verified org only) — IPFS metadata + on-chain tx |
| `/dashboard` | Donor summary, donation history, Impact NFT gallery, org profile form |
| `/governance` | Governance proposal hub |
| `/governance/[proposalId]` | Vote, queue, execute proposal |
| `/admin` | Admin panel — verify orgs, review profiles/evidence/proposals (role-gated) |
| `/about` | Mission, team, anti-abuse policy |
| `/legal` | Testnet disclaimer, contract addresses, Etherscan links |

User guide: [docs/user-manual.md](./docs/user-manual.md)

---

## API endpoints

Proxied at `https://transpachain.site/api/*` via nginx (`/api/` → backend `/:route`).

| Prefix | Description |
|--------|-------------|
| `GET /health` | Mongo, RPC, indexer sync status |
| `GET /campaigns` | List, stats, detail, proposals, donations |
| `GET /donations` | Campaign and donor donation history |
| `GET /proposals` | Governance proposals |
| `GET/POST /orgs` | Organization profiles |
| `GET/POST /evidence` | Milestone evidence submissions |
| `GET/PATCH /admin/*` | Admin workflows + reconcile |
| `POST /ipfs/metadata` | Pin campaign metadata JSON to Pinata |
| `POST /ipfs/upload` | Upload evidence/campaign image to Pinata |
| `GET /ipfs/:cid` | Proxy-fetch IPFS JSON (avoids browser CORS) |

---

## Repository structure

Monorepo with Git submodules:

```
transpachain/                    # Root — Docker, nginx, docs, Makefile
├── docker-compose.yml           # Full stack orchestration
├── nginx/nginx.conf             # TLS, /api proxy, upload size limit
├── docs/                        # Documentation (see table above)
├── Makefile                     # docker-build-frontend, contracts-test, …
├── .env.example                 # Production env template (addresses, keys)
├── backend/   → transpachain-backend    # Express API + Alchemy indexer
├── frontend/  → transpachain-frontend   # Next.js dApp
└── contracts/ → transpachain-contracts # Solidity + Foundry/Hardhat
```

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/Levianth146/transpachain.git
```

---

## Quick start

### Prerequisites

- Node.js 20+
- Docker + Docker Compose
- MetaMask configured for Sepolia testnet

### Local development

```bash
git clone --recurse-submodules https://github.com/Levianth146/transpachain.git
cd transpachain

cp .env.example .env
# Fill ALCHEMY_SEPOLIA_URL, PINATA keys, NEXT_PUBLIC_ALCHEMY_KEY

docker compose up -d

# Optional: seed demo data
cd backend && npm run seed
```

**Access:** http://localhost

### Deploy to production (Docker Hub + EC2)

1. **WSL / dev machine** — build and push frontend image:

```bash
make docker-build-frontend
docker push cuongnguyen146/transpachain-frontend:latest
```

2. **EC2** — pull and restart:

```bash
cd ~/transpachain
git pull && git submodule update --init --recursive
docker compose pull
docker compose up -d
```

Full guide: [docs/deploy.md](./docs/deploy.md)

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE).

---

## Disclaimer

TranspaChain runs on **Sepolia testnet only** for demonstration and academic purposes. Contracts are not audited for mainnet use. Do not send real funds. See [/legal](https://transpachain.site/legal).
