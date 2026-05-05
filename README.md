<div align="center">

# 🌿 TranspaChain

**Decentralized Transparent Charity Platform on Ethereum**

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-363636?logo=solidity)](https://soliditylang.org)
[![Next.js](https://img.shields.io/badge/Next.js-14-black?logo=next.js)](https://nextjs.org)
[![Sepolia](https://img.shields.io/badge/Testnet-Sepolia-7B3FE4)](https://sepolia.etherscan.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Solving the transparency problem in traditional charity through blockchain technology*

</div>

---

## The Problem

| Traditional Charity | TranspaChain Solution |
|---|---|
| No visibility on fund usage | Every transaction is public and traceable on-chain |
| Organizations need not report results | Milestone-based release — funds only unlock with proof |
| Donors have no voice | DAO voting — donors approve/reject each milestone |
| High intermediary fees | Smart contract escrow — no middleman |
| Impact hard to verify | Proof of Impact stored on IPFS, hash on-chain |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              USER  (Browser + MetaMask)                  │
└───────────────────┬──────────────────┬───────────────────┘
                    │                  │
        ┌───────────▼──────┐  ┌────────▼──────────┐
        │  Frontend         │  │  Backend           │
        │  Next.js 14       │◄─►  Node.js/Express  │
        │  wagmi v2 + viem  │  │  MongoDB           │
        │  TailwindCSS      │  │  Event Indexer     │
        └───────────┬──────┘  └────────┬──────────┘
                    │                  │
        ┌───────────▼──────┐  ┌────────▼──────────┐
        │  IPFS / Pinata   │  │  Alchemy (Sepolia)  │
        └──────────────────┘  └────────┬──────────┘
                                       │
        ┌──────────────────────────────▼──────────────┐
        │            BLOCKCHAIN LAYER (Sepolia)         │
        │  CharityCore  │  DonationVault               │
        │  GovernanceDAO│  ImpactNFT (ERC-721)         │
        └──────────────────────────────────────────────┘
```

## Smart Contract Flow

```
Donate → Escrow Lock → Milestone Proof Submit → DAO Vote → Fund Release
                                                        ↓ fail
                                               Auto-Refund to Donors
```

---

## Repository Structure

```
transpachain/                   ← root repo (this repo)
├── contracts/                  ← submodule: transpachain-contracts
│   ├── src/
│   │   ├── CharityCore.sol       Campaign lifecycle
│   │   ├── DonationVault.sol     ETH escrow + milestone release
│   │   ├── GovernanceDAO.sol     DAO voting + timelock
│   │   └── ImpactNFT.sol         ERC-721 donor badges
│   ├── test/                     Foundry unit + fuzz tests
│   ├── script/                   Foundry deploy script
│   ├── hardhat/                  Hardhat deploy + verify (Sepolia)
│   └── foundry.toml
├── frontend/                   ← submodule: transpachain-frontend
│   ├── app/                      Next.js 14 App Router pages
│   ├── components/               UI components
│   ├── hooks/                    wagmi contract hooks
│   └── lib/                      wagmi config + ABI exports
├── backend/                    ← submodule: transpachain-backend
│   └── src/
│       ├── indexer/              ethers.js event listener
│       ├── routes/               Express REST API
│       └── models/               MongoDB schemas
├── docs/
│   ├── architecture.md
│   └── security-audit.md
├── docker-compose.yml
└── .github/workflows/          CI: forge test on PR, deploy on merge
```

---

## Quick Start

### Prerequisites

- [Node.js 20+](https://nodejs.org)
- [Foundry](https://getfoundry.sh) — `curl -L https://foundry.paradigm.xyz | bash`
- [Docker & Docker Compose](https://docs.docker.com)
- [MetaMask](https://metamask.io) with Sepolia ETH

### Clone with submodules

```bash
git clone --recurse-submodules https://github.com/Levianth146/transpachain
cd transpachain
```

### Run locally with Docker

```bash
cp .env.example .env        # fill in your keys
docker-compose up -d        # starts MongoDB + backend + frontend
```

Frontend: http://localhost:3000  
Backend API: http://localhost:3001  
API health: http://localhost:3001/health

### Contract Development

```bash
cd contracts

# Install OZ dependencies
forge install OpenZeppelin/openzeppelin-contracts --no-git

# Run all tests
forge test -vvv

# Run fuzz tests only
forge test --match-path "test/fuzz/**" -vvv

# Deploy to Sepolia
cp .env.example .env        # fill in ALCHEMY_SEPOLIA_URL, DEPLOYER_PRIVATE_KEY, ETHERSCAN_API_KEY
npm install
npx hardhat run hardhat/scripts/deploy.ts --network sepolia
```

---

## Features

| Feature | Status |
|---|---|
| Campaign creation (org) | ✅ Contract + UI skeleton |
| ETH donation + escrow | ✅ Contract + hook |
| Impact NFT mint (ERC-721) | ✅ Contract skeleton |
| Milestone proof submission | ✅ Contract skeleton |
| DAO voting (51% quorum) | ✅ Contract skeleton |
| 24h timelock before execution | ✅ Contract |
| Pull-pattern refunds | ✅ Contract |
| Off-chain event indexer | ✅ Skeleton |
| IPFS proof storage | 🔲 Phase 3 |
| Full UI implementation | 🔲 Phase 4 |
| Sepolia deployment + verify | 🔲 Phase 2 |

---

## Demo Scenarios

Three sample campaigns representing different lifecycle states:

1. **"Xây trường tiểu học Cà Mau"** — Active, 60% funded, donations open
2. **"Hỗ trợ lũ lụt miền Trung 2024"** — Milestone 2 in governance vote
3. **"Học bổng trẻ em vùng cao Sapa"** — Completed, all milestones released

---

## Security

See [docs/security-audit.md](docs/security-audit.md) for full analysis.

Key protections: `ReentrancyGuard`, pull payment pattern, voting power snapshot, timelock, admin-cannot-withdraw design.

---

## Tech Stack

**Contracts:** Solidity 0.8.20, Foundry (unit+fuzz), Hardhat (deploy), OpenZeppelin 5.x, Sepolia  
**Frontend:** Next.js 14, wagmi v2, viem, TailwindCSS, shadcn/ui  
**Backend:** Node.js, Express, ethers.js v6, MongoDB, Socket.io, Pinata  
**DevOps:** Docker, GitHub Actions, Alchemy  

---

## License

MIT © TranspaChain contributors
