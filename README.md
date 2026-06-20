# 🌿 TranspaChain

> Transparent charity platform powered by Ethereum — milestone-based fund release with DAO governance

**Live Demo:** http://3.106.166.120  
**Network:** Ethereum Sepolia Testnet

---

## 📋 Overview

TranspaChain is a blockchain-based charity platform that ensures complete transparency in fund management. Donors can track exactly how their contributions are used through a milestone-based release system governed by a decentralized autonomous organization (DAO).

### Key Features

- **Milestone-based fund release** — funds are locked in escrow and only released when milestones are approved by donors
- **DAO Governance** — donors vote on milestone completion proofs before funds are released
- **Impact NFTs** — donors receive NFT badges (Bronze/Silver/Gold) based on contribution amount
- **IPFS metadata** — campaign metadata stored on IPFS via Pinata for decentralized storage
- **Multi-token support** — donate with ETH or USDC
- **Real-time indexing** — blockchain events indexed into MongoDB for fast querying

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

---

## 🔧 Tech Stack

### Smart Contracts
| Technology | Purpose |
|---|---|
| Solidity 0.8.20 | Smart contract language |
| Foundry | Testing (282 tests) + fuzzing |
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
| Multer | File upload handling |

### Frontend
| Technology | Purpose |
|---|---|
| Next.js 16 | React framework (Turbopack) |
| wagmi v2 + viem | Ethereum wallet integration |
| TailwindCSS | Styling |
| TypeScript | Type safety |

### Infrastructure
| Technology | Purpose |
|---|---|
| Docker + Docker Compose | Containerization |
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

### Test Coverage
- **282 / 282 tests passing**
- Unit tests + fuzz tests for all contracts
- Integration tests for full donation lifecycle

### Contract Interactions
```
Donor → DonationVault.donate() → ETH locked in escrow
Org   → DonationVault.submitMilestoneProof() → creates Proposal
Donor → GovernanceDAO.castVote() → vote For/Against
Admin → GovernanceDAO.queueProposal() → timelock starts
Admin → GovernanceDAO.executeProposal() → funds released to org
                                        → ImpactNFT minted for donor
```

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

# Seed demo data
cd backend
npm run seed
```

**Access:** `http://localhost`

### Environment Variables

```env
# Alchemy RPC
ALCHEMY_SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY

# Contract addresses
CHARITY_CORE_ADDRESS=0x...
DONATION_VAULT_ADDRESS=0x...
GOVERNANCE_DAO_ADDRESS=0x...
IMPACT_NFT_ADDRESS=0x...

# Pinata IPFS
PINATA_API_KEY=your_key
PINATA_SECRET_KEY=your_secret

# Frontend
NEXT_PUBLIC_ALCHEMY_KEY=your_key
NEXT_PUBLIC_CHAIN_ID=11155111
```

---

## 📁 Repository Structure

```
transpachain/                    # Root repo (submodules)
├── docker-compose.yml           # Full stack orchestration
├── nginx/nginx.conf             # Reverse proxy config
├── docs/                        # Documentation
│   └── improvement-plan.md
├── backend/  → transpachain-backend
├── frontend/ → transpachain-frontend
└── contracts/ → transpachain-contracts

transpachain-backend/
├── src/
│   ├── indexer/eventListener.ts # Blockchain event indexer
│   ├── models/                  # Mongoose schemas
│   │   ├── Campaign.ts
│   │   ├── Donation.ts
│   │   └── Proposal.ts
│   ├── routes/                  # Express routes
│   │   ├── campaigns.ts
│   │   ├── donations.ts
│   │   └── ipfs.ts
│   ├── seed.ts                  # Demo data seeder
│   └── server.ts                # Express app entry

transpachain-frontend/
├── app/                         # Next.js App Router
│   ├── page.tsx                 # Homepage
│   ├── campaigns/[id]/          # Campaign detail
│   ├── campaigns/create/        # Create campaign
│   ├── dashboard/               # Donor dashboard
│   └── governance/[proposalId]/ # Voting page
├── components/                  # React components
│   ├── CampaignCard.tsx
│   ├── CampaignList.tsx
│   ├── DonateModal.tsx
│   ├── VotingPanel.tsx
│   └── NFTGallery.tsx
├── hooks/                       # wagmi custom hooks
│   ├── useCharityCore.ts
│   ├── useDonationVault.ts
│   └── useGovernance.ts
└── lib/
    ├── api.ts                   # Backend API client
    ├── contracts.ts             # Contract ABIs + addresses
    └── wagmi.ts                 # wagmi config

transpachain-contracts/
├── src/
│   ├── CharityCore.sol
│   ├── DonationVault.sol
│   ├── GovernanceDAO.sol
│   └── ImpactNFT.sol
├── test/                        # 282 tests
└── hardhat/scripts/deploy.ts
```

---

## 🔌 API Endpoints

### Campaigns
| Method | Endpoint | Description |
|---|---|---|
| GET | `/campaigns` | List campaigns (paginated, filterable) |
| GET | `/campaigns/stats` | Platform statistics |
| GET | `/campaigns/:id` | Campaign details |
| GET | `/campaigns/:id/proposals` | Campaign proposals |
| GET | `/campaigns/:id/donations` | Campaign donations |

### Donations
| Method | Endpoint | Description |
|---|---|---|
| GET | `/donations/campaign/:id` | Donations by campaign |
| GET | `/donations/summary/:address` | Donor summary |
| GET | `/donations/:address` | All donations by address |

### IPFS
| Method | Endpoint | Description |
|---|---|---|
| POST | `/ipfs/metadata` | Pin JSON metadata |
| POST | `/ipfs/upload` | Upload file |
| GET | `/ipfs/:cid` | Fetch IPFS content |

---

## 🗃️ Data Flow

```
1. User creates campaign on frontend
   → Uploads metadata to IPFS via backend
   → Calls CharityCore.createCampaign() on Sepolia
   
2. Event Indexer detects CampaignCreated event
   → Fetches metadata from IPFS
   → Stores in MongoDB

3. User donates ETH
   → Calls DonationVault.donate()
   → ETH locked in escrow
   → ImpactNFT minted

4. Org submits milestone proof
   → Calls DonationVault.submitMilestoneProof()
   → GovernanceDAO creates Proposal

5. Donors vote on proposal
   → Calls GovernanceDAO.castVote()

6. After voting period ends
   → Queue → Execute → ETH released to org
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

This project is deployed on **Sepolia testnet only** for demonstration purposes. Do not use with real funds.