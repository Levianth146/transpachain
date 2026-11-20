<div align="center">

# TranspaChain 2.0 · Avalanche Fuji · Team1 Vietnam UniHack Topic 5

**Transparent charity escrow with DAO approval, Safe 3/5 disbursement, and optional mock USDC yield**

[![Avalanche Fuji](https://img.shields.io/badge/Avalanche-Fuji%20C--Chain%20(43113)-E84142?logo=avalanche)](https://testnet.snowtrace.io)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-363636?logo=solidity)](https://soliditylang.org)
[![Foundry](https://img.shields.io/badge/Foundry-forge%20test-000000)](https://getfoundry.sh)
[![Next.js](https://img.shields.io/badge/Next.js-App%20Router-black?logo=next.js)](https://nextjs.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Topic 5 — transparent accounting & proof-of-spending on Avalanche*

</div>

---

## Problem → solution

| Traditional charity pain | TranspaChain 2.0 |
|---|---|
| Donors cannot see where funds go | Public ledger + Snowtrace txs for every donation, approval, expense, refund |
| Orgs can spend without oversight | Milestone proof → DAO vote → approve-only; money moves only via Safe 3/5 |
| Single-signer treasury risk | Gnosis Safe threshold 3 of 5 owners for `executeDisbursement` |
| Idle USDC earns nothing | Opt-in yield via `YieldManager` + Mock ERC-4626 (testnet demo) |
| “Receipt” claims are unverifiable | SHA-256 + IPFS CID on-chain; public `/expenses/[id]` verify-my-file UI |
| Opaque refunds after cancel/fail | `settleYieldForRefund` then proportional `claimRefunds` |

---

## Architecture

```
┌──────────────────────────┐     ┌──────────────────────────┐
│  Frontend (Vercel)       │     │  Backend (Render)        │
│  Next.js · wagmi · viem  │────►│  Express · ethers v6     │
│  YOUR_VERCEL_URL         │     │  Indexer + Module B API  │
└────────────┬─────────────┘     │  YOUR_RENDER_URL         │
             │                   └────────────┬─────────────┘
             │                                │
             │                   ┌────────────▼─────────────┐
             │                   │  MongoDB Atlas (M0)      │
             │                   │  DB: transpachain-fuji-v2│
             │                   └────────────┬─────────────┘
             │                                │ eth_getLogs
             ▼                                ▼
┌────────────────────────────────────────────────────────────┐
│              Avalanche Fuji C-Chain (43113)                │
│  CharityCore · DonationVault · GovernanceDAO · ImpactNFT │
│  DisbursementController · YieldManager · MockERC4626       │
│  Safe 3/5 · Circle USDC                                    │
└────────────────────────────────────────────────────────────┘
```

---

## End-to-end flow

```
Donate (AVAX or USDC)
    → Escrow in DonationVault
    → [opt-in USDC] YieldManager.allocate → MockERC4626
    → Org submits milestone proof (IPFS CID)
    → Donors vote For (quorum)
    → Queue + timelock (120s on this Fuji deploy)
    → DAO execute = approve only (no transfer)
    → Org requestDisbursement (+ receipt SHA-256 / CID)
    → 3 of 5 Safe owners sign (EIP-712, off-chain)
    → executeDisbursement → expense + receipt hash on public ledger
    → /expenses/[id] · /transparency · CSV export

Cancel / fail path:
    settleYieldForRefund → redeem mock vault → claimRefunds (proportional)
```

---

## Live Fuji V2 contracts

Source of truth: [`contracts/deployments/43113.json`](contracts/deployments/43113.json) → `deployments.v2`  
**Deploy block:** `61364951` · **Governance:** voting `300s` / timelock `120s`  
**Explorer:** [testnet.snowtrace.io](https://testnet.snowtrace.io)

| Contract | Address |
|---|---|
| CharityCore | [`0xFc71b91e360DB771F81aD3594023Be35D85C613b`](https://testnet.snowtrace.io/address/0xFc71b91e360DB771F81aD3594023Be35D85C613b) |
| DonationVault | [`0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b`](https://testnet.snowtrace.io/address/0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b) |
| GovernanceDAO | [`0xC8f15c5eE83998897615b851a03f044712b0e016`](https://testnet.snowtrace.io/address/0xC8f15c5eE83998897615b851a03f044712b0e016) |
| ImpactNFT | [`0x0fA0613bD0Ef0520851f1F515C894D7D80Df2210`](https://testnet.snowtrace.io/address/0x0fA0613bD0Ef0520851f1F515C894D7D80Df2210) |
| DisbursementController | [`0xb61c688D64564960958181Dfc5cD4164730125E6`](https://testnet.snowtrace.io/address/0xb61c688D64564960958181Dfc5cD4164730125E6) |
| YieldManager | [`0x64b5B7e14000FFAF68f84f11Ec4685812eC9deF9`](https://testnet.snowtrace.io/address/0x64b5B7e14000FFAF68f84f11Ec4685812eC9deF9) |
| MockERC4626Vault | [`0xDefbf3f47c1e15bb4A875daADbB469Fa115bC75A`](https://testnet.snowtrace.io/address/0xDefbf3f47c1e15bb4A875daADbB469Fa115bC75A) |
| Safe (3/5) | [`0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A`](https://testnet.snowtrace.io/address/0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A) |
| USDC (Circle Fuji) | [`0x5425890298aed601595a70AB815c96711a31Bc65`](https://testnet.snowtrace.io/address/0x5425890298aed601595a70AB815c96711a31Bc65) |

**Primary vault (Snowtrace):** https://testnet.snowtrace.io/address/0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b

---

## Hosted demo (fill after deploy)

| Layer | URL |
|---|---|
| Frontend | `YOUR_VERCEL_URL` |
| Backend API | `YOUR_RENDER_URL` |
| API health | `YOUR_RENDER_URL/health` |

See [docs/hosting.md](docs/hosting.md) for Vercel / Render / Atlas setup.

---

## Repository structure

```
transpachain/                          ← submission root (this repo)
├── contracts/                         ← submodule: transpachain-contracts (Foundry + Hardhat)
│   ├── src/                           CharityCore, DonationVault, GovernanceDAO, ImpactNFT,
│   │                                  DisbursementController, YieldManager, MockERC4626Vault
│   ├── deployments/43113.json         Fuji V1 (history) + V2 (active)
│   ├── hardhat/scripts/               create-safe.ts, deploy-v2.ts, check-v2.ts
│   └── test/                          Foundry unit + fuzz
├── frontend/                          ← submodule: transpachain-frontend (Next.js)
│   ├── app/                           campaigns, governance, /transparency, /expenses/[id]
│   └── lib/                           chain + ABIs + Fuji addresses
├── backend/                           ← submodule: transpachain-backend (Express)
│   └── src/                           indexer, Module B ledger APIs, Safe sig store
└── docs/                              Topic 5 docs (demo, deploy, hosting, ADRs, security)
```

Clone with submodules:

```powershell
git clone --recurse-submodules https://github.com/Levianth146/transpachain
cd transpachain
```

---

## Local run

### Prerequisites

- Node.js 20+
- Docker (MongoDB)
- MetaMask on **Avalanche Fuji** with test AVAX + Circle USDC
- Foundry via **WSL** (Windows PATH often missing `forge`)

### PowerShell — apps

```powershell
# Mongo
docker start transpachain-mongo
# or: docker run -d --name transpachain-mongo -p 27017:27017 -v transpachain_mongo_data:/data/db mongo:7.0

# Backend (DB name transpachain-fuji-v2)
cd backend   # or backend/transpachain-backend depending on checkout
copy .env.example .env   # fill Pinata + addresses if needed
npm install
npm run dev              # http://localhost:3001

# Frontend
cd ..\frontend
copy .env.example .env.local
npm install
npm run dev              # http://localhost:3000
```

### WSL — contracts

```bash
cd /mnt/d/Projects/transpachain/contracts   # adjust path to your clone
forge test -vv
```

Indexer RPC tip: prefer PublicNode (`https://avalanche-fuji-c-chain-rpc.publicnode.com`) to avoid public API `429`s.

---

## Docs index (Topic 5)

| Doc | Purpose |
|---|---|
| [docs/fuji-deployment.md](docs/fuji-deployment.md) | `create-safe` + `deploy-v2`, env vars, verify, manifest |
| [docs/hosting.md](docs/hosting.md) | Atlas → Render → Vercel checklist |
| [docs/demo-topic5.md](docs/demo-topic5.md) | G4 E2E checklist (fill tx hashes) |
| `contracts/hardhat/scripts/e2e-fuji.ts` | Automated Fuji G4 run (`npx hardhat run … --network fuji`) |
| [docs/transparent-accounting.md](docs/transparent-accounting.md) | Ledger classifications + identity equation |
| [docs/security-limitations.md](docs/security-limitations.md) | Testnet / mock / demo honesty |
| [docs/architecture.md](docs/architecture.md) | Avalanche V2 architecture pointer |
| [docs/adr/](docs/adr/) | ADRs 0001–0003 |

---

## Limitations / roadmap

**Deferred past UniHack deadline**

- PDF export (CSV only today)
- SIWE on write endpoints (signed-message checks where trivial)
- Full reorg rollback (use `INDEXER_CONFIRMATIONS` depth instead)

**Honest demo constraints**

- Mock ERC-4626 yield — UI shows a **Mock Yield** badge; not a real DeFi product
- Receipt hash ≠ delivery / impact proof — only that a specific file was committed
- Safe owners for the hackathon demo are team-held MetaMask keys (documented in security limitations)

See [docs/security-limitations.md](docs/security-limitations.md).

---

## Security (high level)

On-chain: `ReentrancyGuard`, pull refunds, one-time `setDisbursementController` / `setYieldManager`, DAO approve-only, Safe-gated payouts, `LOSS_SINK = dEaD` for mock loss.

This is **Fuji testnet software** — not audited, not for real money. Production use in Vietnam requires legal review.

---

## Tech stack

| Layer | Stack |
|---|---|
| Contracts | Solidity 0.8.20, Foundry, Hardhat, OpenZeppelin 5.x, Safe 1.4.1 |
| Frontend | Next.js App Router, wagmi v2, viem, Tailwind |
| Backend | Node.js, Express, ethers v6, MongoDB, Socket.io, Pinata |
| Hosting | Vercel + Render + MongoDB Atlas M0 |
| Chain | Avalanche Fuji C-Chain · Circle USDC |

---

## License

MIT © TranspaChain / Team1 Vietnam UniHack contributors
