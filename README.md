# 🌿 TranspaChain

> Transparent charity platform powered by Ethereum — milestone-based fund release with DAO governance

**Live Demo:** https://transpachain.site  
**Network:** Ethereum Sepolia Testnet

---

## 📋 Overview

TranspaChain is a blockchain-based charity platform that ensures complete transparency in fund management. Donors can track exactly how their contributions are used through a milestone-based release system governed by a decentralized autonomous organization (DAO).

### Key Features

- **Milestone-based fund release** — funds are locked in escrow and only released when milestones are approved by donors
- **DAO Governance** — quadratic donor voting on milestone completion proofs before funds are released
- **Impact NFTs** — donors receive NFT badges (Bronze/Silver/Gold) based on contribution amount
- **Verified organizations** — only admin-verified orgs can create campaigns
- **Evidence + IPFS** — milestone proofs pinned via Pinata; admin review before voting
- **Multi-token support** — donate with ETH or USDC
- **Real-time indexing** — blockchain events indexed into MongoDB for fast querying

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [user-manual.md](./docs/user-manual.md) | **User guide** — donors, orgs, admins, troubleshooting |
| [demo-guide.md](./docs/demo-guide.md) | **Demo guide** — checklist, 10-min script, Q&A prep, fallbacks |
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

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Frontend (Next.js)                │
│             wagmi v2 / viem / TailwindCSS           │
└──────────────────┬──────────────────────────────────┘
                   │ HTTP / WebSocket
        ┌──────────┴──────────┐
        │    Nginx (port 80)  │
        └──────────┬──────────┘
                   │
     ┌─────────────┴─────────────┐
     │                           │
┌────┴─────┐              ┌──────┴──────┐
│ Backend  │              │  Frontend   │
│ :3001    │              │  :3000      │
│ Express  │              │  Next.js    │
└────┬─────┘              └─────────────┘
     │
     ├── MongoDB (data layer)
     ├── Event Indexer (ethers.js)
     └── Pinata IPFS
          │
          ▼
    Ethereum Sepolia
    ┌─────────────────────┐
    │ CharityCore         │
    │ DonationVault       │
    │ GovernanceDAO       │
    │ ImpactNFT           │
    └─────────────────────┘
```

Full diagram and data flows: [docs/architecture.md](./docs/architecture.md)

---

## 🔧 Tech Stack

### Smart Contracts
| Technology | Purpose |
|---|---|
| Solidity 0.8.20 | Smart contract language |
| Foundry | Testing (307 tests) + fuzzing |
| Hardhat | Deployment scripts |
| OpenZeppelin 5.x | Security standards (AccessControl, ERC721) |

### Backend
| Technology | Purpose |
|---|---|
| Node.js + Express | REST API server |
| TypeScript | Type safety |
| MongoDB + Mongoose | Data persistence |
| ethers.js v6 | Blockchain event indexing |
| Socket.io | Real-time WebSocket |
| Pinata SDK | IPFS file storage |

### Frontend
| Technology | Purpose |
|---|---|
| Next.js 16 | React framework (App Router) |
| wagmi v2 + viem | Ethereum wallet integration |
| TailwindCSS | Dark holo-mint glass UI |
| TypeScript | Type safety |

### Infrastructure
| Technology | Purpose |
|---|---|
| Docker + Docker Compose | Containerization |
| Docker Hub | `cuongnguyen146/transpachain-*` images |
| Nginx | Reverse proxy |
| AWS EC2 | Cloud hosting |

---

## 📦 Smart Contracts

### Deployed on Sepolia Testnet

| Contract | Address |
|---|---|
| CharityCore | `0x8a5e023b16ab13939260492dAe72a0be1E597e1a` |
| DonationVault | `0x68Bb9f5E1414b1a62372EbF02fdEe4c09fFc7C32` |
| GovernanceDAO | `0xCcAEaF248E536850877B9f948cB237Fe7885b513` |
| ImpactNFT | `0xD651d3531a44ee7941bFE257c79F41d274E180A6` |
| USDC (Sepolia) | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` |

### Test Coverage

- **307 / 307 Foundry tests passing**
- Unit, fuzz, and integration tests for full donation lifecycle

Details: [docs/smart-contracts-explained.md](./docs/smart-contracts-explained.md)

---

## 🚀 Quick Start

### Prerequisites

- Node.js 20+
- Docker + Docker Compose
- MetaMask (Sepolia testnet)

### Local Development

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/Levianth146/transpachain.git
cd transpachain

# Copy and fill environment variables
cp .env.example .env

# Start all services
docker compose up -d

# Seed demo data (optional)
cd backend && npm run seed
```

**Access:** `http://localhost`

### Deploy to production

See [docs/deploy.md](./docs/deploy.md) — WSL `make docker-build-frontend`, push to Docker Hub, EC2 `docker compose pull`.

---

## 🌐 Frontend Routes

| Route | Purpose |
|-------|---------|
| `/` | Homepage |
| `/campaigns` | Campaign list |
| `/campaigns/[id]` | Campaign detail |
| `/campaigns/create` | Create campaign (verified org) |
| `/dashboard` | Donor dashboard + NFT gallery |
| `/governance` | Governance hub |
| `/governance/[proposalId]` | Vote / queue / execute |
| `/admin` | Admin panel (role-gated) |
| `/about` | Mission, team, anti-abuse policy |
| `/legal` | Testnet disclaimer |

User guide: [docs/user-manual.md](./docs/user-manual.md)

---

## 🔌 API Endpoints

| Prefix | Description |
|--------|-------------|
| `GET /health` | Health + indexer sync status |
| `GET /campaigns` | List, stats, detail, proposals, donations |
| `GET /donations` | Campaign and donor donation history |
| `GET /proposals` | Governance proposals |
| `GET/POST /orgs` | Organization profiles |
| `GET/POST /evidence` | Milestone evidence |
| `GET/PATCH /admin/*` | Admin workflows + reconcile |
| `POST /ipfs/*` | Pinata metadata and file upload |

Proxied at `https://transpachain.site/api/*` via nginx.

---

## 📁 Repository Structure

```
transpachain/                    # Root repo (submodules)
├── docker-compose.yml           # Full stack orchestration
├── nginx/nginx.conf             # Reverse proxy config
├── docs/                        # Documentation (see table above)
├── Makefile                     # docker-build-frontend, contracts-test, …
├── backend/  → transpachain-backend
├── frontend/ → transpachain-frontend
└── contracts/ → transpachain-contracts
```

---

## 👥 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## ⚠️ Disclaimer

This project is deployed on **Sepolia testnet only** for demonstration purposes. Do not use with real funds. See [/legal](https://transpachain.site/legal) on the live site.
