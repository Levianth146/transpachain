# TranspaChain

### Transparent giving on Avalanche — escrow first, donor governance, public proof of spending

**Live demo:** [https://www.transpachain.site](https://www.transpachain.site) · [https://transpachain.site](https://transpachain.site)  
**Network:** Avalanche Fuji C-Chain (`43113`) · **Active deploy:** V2 from block `61364951`  
**Stack:** Next.js · Express · MongoDB · Foundry/Hardhat · Gnosis Safe 3/5 · Circle USDC (test)

---

## Why TranspaChain exists

Charity and crowdfunding often ask for trust *before* proof:

- Donors send money into an opaque wallet and hope it is used well.
- Organizations struggle to show *when* funds moved and *why*.
- “Transparency” is frequently a PDF or a screenshot — not something anyone can verify independently.

**TranspaChain flips that model.** Every gift is locked in an on-chain escrow. Releases only happen after:

1. Milestone evidence is submitted  
2. Donors vote (quadratic weight) with quorum + timelock  
3. A **3-of-5 Safe** executes the payout with a committed receipt hash  

Anyone can open the public ledger — **no wallet required** — and reconcile numbers against [Snowtrace](https://testnet.snowtrace.io).

> **Honest demo note:** This is a Fuji *testnet* product for Avalanche Team1 Vietnam UniHack (Topic 5 — Transparent Charity). Yield is a **Mock ERC-4626** vault. Receipt hashes prove file integrity, **not** physical delivery. See [docs/security-limitations.md](./docs/security-limitations.md).

---

## Product highlights

| Highlight | What it means in practice |
|---|---|
| **Escrow-first giving** | Funds sit in `DonationVault` until governance + Safe release — not a hot wallet. |
| **Dual assets** | Donate in **AVAX** (native) or **Circle USDC** (Fuji test token). |
| **Quadratic donor voting** | Vote weight ≈ √donation — reduces pure whale dominance while still rewarding larger gifts. |
| **Safe-gated payouts** | DAO *approves*; Safe *pays*. No single admin key can drain escrow to a third party. |
| **Public transparency** | `/transparency` + campaign finance tabs show indexed ledger + live contract reads. |
| **Mock yield (USDC only)** | Idle USDC can move into a mock vault for demo NAV — clearly labeled **Mock Yield**. |
| **Impact NFT badges** | Bronze / Silver / Gold donor badges minted per campaign as on-chain souvenirs. |

---

## Who it is for

| Persona | Goal | Primary screens |
|---|---|---|
| **Donor** | Give with confidence; vote on milestones; claim refund if a campaign fails | Campaigns → Donate → Governance → Dashboard |
| **Organization** | Launch verified campaigns; submit proof; request Safe-backed disbursements | Create → Campaign detail → Evidence → Disbursement |
| **Auditor / public** | Reconcile money without trusting the team’s spreadsheet | Transparency · Expenses · Snowtrace |
| **Admin / verifier** | Verify orgs; manage roles | Admin |

---

## How money moves (mental model)

```text
  DONOR                    ESCROW                      PAYOUT
  ─────                    ──────                      ──────
  Donate AVAX/USDC  ──►  DonationVault          ──►  Org wallet (after)
                         (locked per campaign)         DAO approve
                              │                        + Safe 3/5 execute
                              │                        + receipt hash/CID
                              ├─► optional Mock Yield (USDC only)
                              └─► refunds if Failed/Cancelled (permissionless)
```

**Three modules (V2):**

| Module | Name | One-line job |
|---|---|---|
| **A** | Safe disbursement | Outward milestone payments require DAO approval **and** Safe execution |
| **B** | Transparent accounting | Indexer → Mongo ledger → public APIs + CSV-friendly finance views |
| **C** | Mock yield treasury | Opt-in USDC idle capital in `MockERC4626Vault` (demo only) |

---

## Architecture at a glance

```text
┌─────────────────────────────────────────────────────────────┐
│  Browser + MetaMask (Avalanche Fuji)                        │
│  Frontend — Next.js / wagmi / viem                          │
│  https://www.transpachain.site                              │
└───────────────┬──────────────────────────┬──────────────────┘
                │ writes (txs)             │ reads (REST + RPC)
                ▼                          ▼
        Avalanche Fuji C-Chain      Backend — Express
        CharityCore · Vault ·       Indexer + Socket.io
        GovernanceDAO · NFT ·       MongoDB `transpachain-fuji-v2`
        DisbursementController ·
        YieldManager · Mock4626 ·
        Safe 3/5 · Circle USDC
```

**Source of truth for money = the chain.** Mongo is a reconcilable cache. When numbers disagree, trust Snowtrace / contract reads.

Deep dive: [docs/architecture.md](./docs/architecture.md)

---

## Live contract directory (Fuji V2)

| Contract | Address |
|---|---|
| CharityCore | [`0xFc71…613b`](https://testnet.snowtrace.io/address/0xFc71b91e360DB771F81aD3594023Be35D85C613b) |
| DonationVault | [`0x671b…3D5b`](https://testnet.snowtrace.io/address/0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b) |
| GovernanceDAO | [`0xC8f1…e016`](https://testnet.snowtrace.io/address/0xC8f15c5eE83998897615b851a03f044712b0e016) |
| ImpactNFT | [`0x0fA0…2210`](https://testnet.snowtrace.io/address/0x0fA0613bD0Ef0520851f1F515C894D7D80Df2210) |
| DisbursementController | [`0xb61c…25E6`](https://testnet.snowtrace.io/address/0xb61c688D64564960958181Dfc5cD4164730125E6) |
| YieldManager | [`0x64b5…deF9`](https://testnet.snowtrace.io/address/0x64b5B7e14000FFAF68f84f11Ec4685812eC9deF9) |
| MockERC4626Vault | [`0xDefb…C75A`](https://testnet.snowtrace.io/address/0xDefbf3f47c1e15bb4A875daADbB469Fa115bC75A) |
| Disbursement Safe (3/5) | [`0xf2dD…737A`](https://testnet.snowtrace.io/address/0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A) |
| Circle USDC (Fuji) | [`0x5425…Bc65`](https://testnet.snowtrace.io/address/0x5425890298aed601595a70AB815c96711a31Bc65) |

Manifest: `contracts/deployments/43113.json` → `deployments.v2`  
Governance on this deploy: **300s** voting · **120s** timelock (demo-shortened).

---

## Repository layout

This workspace is a **monorepo checkout** of three packages (each may be its own git remote):

```text
transpachain-fresh/
├── README.md                 ← you are here
├── docs/                     ← product & ops documentation
├── frontend/                 ← Next.js app (Vercel)
├── backend/                  ← Express indexer API (Render)
├── contracts/                ← Solidity + Foundry/Hardhat
└── design-system/            ← UI tokens (ui-ux-pro-max)
```

| Package | Role | README |
|---|---|---|
| [`frontend/`](./frontend) | UI, wallet UX, public pages | [frontend/README.md](./frontend/README.md) |
| [`backend/`](./backend) | Indexer, REST, Socket.io, IPFS helpers | [backend/README.md](./backend/README.md) |
| [`contracts/`](./contracts) | On-chain protocol + tests + deploy scripts | [contracts/README.md](./contracts/README.md) |

---

## Quick start — use the live site (no coding)

### 1. Wallet & network

1. Install [MetaMask](https://metamask.io/) (or Core).
2. Add **Avalanche Fuji C-Chain** (chain ID `43113`).  
   The app also offers **“Switch to Avalanche Fuji”** if you are on the wrong network.
3. Get free test AVAX from a Fuji faucet.
4. For USDC campaigns: hold Circle **test** USDC on Fuji (`0x5425…Bc65`). Approve USDC once before donating.

### 2. Browse without a wallet

Open [Transparency](https://www.transpachain.site/transparency) — platform totals, contract directory, indexed ledger, recent payouts. No login.

### 3. Donate (donor)

1. Open [Campaigns](https://www.transpachain.site/campaigns) → pick a campaign.  
2. Connect wallet → **Donate** (AVAX or USDC depending on campaign).  
3. Watch progress update from **on-chain** reads (not only Mongo).  
4. When a milestone is up for vote: **Governance** → vote For/Against.  
5. Optional: mint / view **Impact NFT** on your Dashboard after eligible donations.

### 4. Run a campaign (organization)

1. Connect the org wallet → **Dashboard** → submit organization profile.  
2. Wait for admin/verifier to grant **ORG_ROLE** on-chain.  
3. **Create Campaign** (title, goal, milestones, AVAX or USDC, yield opt-in for USDC).  
4. After funding: upload milestone **evidence** (IPFS).  
5. After donors pass a proposal + timelock: **request disbursement** with a receipt file (hash + CID).  
6. Safe owners (3 of 5) sign in the UI → executor submits `executeDisbursement`.

### 5. Explore yield (USDC campaigns only)

Open [Yield](https://www.transpachain.site/yield). Enable → allocate → simulate (mock) → settle when refunds need liquidity. Always treat numbers as **testnet demo**, not marketed APY.

---

## Quick start — run locally (developers)

### Prerequisites

- Node.js **20+**
- Docker (optional, for local Mongo) **or** MongoDB Atlas URI  
- Foundry (`forge`) if you work on contracts  
- MetaMask on Fuji

### 1. Backend

```bash
cd backend
cp .env.example .env          # set MONGODB_URI, RPC_URL, V2 addresses, PINATA_*
npm install
npm run dev                   # http://localhost:3001
```

Check: `GET http://localhost:3001/health` → `chainId: 43113`, indexer advancing.

### 2. Frontend

```bash
cd frontend
cp .env.example .env.local    # NEXT_PUBLIC_BACKEND_URL=http://localhost:3001
npm install
npm run dev                   # http://localhost:3000
```

### 3. Contracts (optional)

```bash
cd contracts
forge test                    # Foundry suite
# Deploy scripts: see docs/fuji-deployment.md
```

Hosted stack (Atlas → Render → Vercel + domain): [docs/hosting.md](./docs/hosting.md)

---

## User journeys (step-by-step)

### A. First-time donor (5 minutes)

| Step | Action | Tip |
|---:|---|---|
| 1 | Open the site → connect MetaMask | Confirm badge shows **Avalanche Fuji** |
| 2 | Campaigns → open one campaign | Raised amount should match chain progress |
| 3 | Donate a small test amount | USDC needs `approve` first |
| 4 | Dashboard | See donations + NFT gallery |
| 5 | Transparency | Confirm your activity appears in the ledger/cache |

### B. Organization milestone release

| Step | Action |
|---:|---|
| 1 | Campaign funded (goal reached or policy allows) |
| 2 | Submit milestone proof (IPFS evidence) |
| 3 | Proposal opens → donors vote (quadratic) |
| 4 | Quorum + pass → wait timelock |
| 5 | DAO **approves** milestone (no transfer yet) |
| 6 | Org **requests disbursement** + receipt hash/CID |
| 7 | ≥3 Safe owners sign EIP-712 in the app |
| 8 | Anyone with gas executes → funds leave escrow → `EXPENSE_PAID` indexed |

### C. Failed campaign & refund

| Step | Action |
|---:|---|
| 1 | Deadline passes without goal (or campaign cancelled per rules) |
| 2 | Eligible party finalizes as **Failed** |
| 3 | Donors call **claim refund** (permissionless) — proportional share of remaining escrow |

Full competition E2E script with tx blanks: [docs/demo-topic5.md](./docs/demo-topic5.md)

---

## Documentation map

| Document | Read when you need… |
|---|---|
| [docs/architecture.md](./docs/architecture.md) | System layers, on-chain vs off-chain, data flow |
| [docs/transparent-accounting.md](./docs/transparent-accounting.md) | Ledger classifications, NAV identity, public APIs |
| [docs/fuji-deployment.md](./docs/fuji-deployment.md) | Create Safe + deploy V2 on Fuji |
| [docs/hosting.md](./docs/hosting.md) | Atlas, Render, Vercel, custom domain |
| [docs/security-limitations.md](./docs/security-limitations.md) | What this demo is **not**, known caveats |
| [docs/demo-topic5.md](./docs/demo-topic5.md) | Judge/demo checklist (G4 path) |
| [docs/adr/](./docs/adr/) | Architecture Decision Records (Safe, yield, redeploy) |

---

## Design principles we refuse to break

1. **No silent releases** — escrow outflows to third parties need DAO + Safe + request.  
2. **Chain over cache** — UI prefers live reads for money; Mongo accelerates search/history.  
3. **Honesty in UX** — Mock Yield badge; hash ≠ delivery; testnet disclaimers.  
4. **Refunds stay pull-based** — donors claim; no admin “push refund to everyone” bypass for normal flow.  
5. **Secrets never in git** — `.env` only; docs use placeholders.

---

## Roadmap (post-UniHack)

- Real yield adapter (e.g. Aave/Benqi) behind the same `YieldManager` interface  
- Independent Safe owners / hardware wallets  
- Professional audit + mainnet Avalanche C-Chain  
- PDF export, SIWE on sensitive writes, deeper reorg handling  
- Legal/compliance path for real-world charity ops (jurisdiction-specific)

---

## License & contact

Built for **Avalanche Team1 Vietnam UniHack** — Topic 5 Transparent Charity.  
Code is split across `transpachain-frontend`, `transpachain-backend`, and `transpachain-contracts` under the team GitHub org/account.

**Not financial advice. Not a production charity platform. Testnet assets only.**
