# TranspaChain Demo Guide

Comprehensive demo script for live presentations, portfolio reviews, and stakeholder meetings. Use with [demo-script.md](./demo-script.md) for a quick reference card.

**Site:** https://transpachain.site  
**Network:** Ethereum Sepolia  
**Duration:** 5–10 minutes (core) + optional deep dives

---

## Pre-demo checklist

Complete **24 hours before** the demo; re-verify **30 minutes before**.

### Infrastructure

- [ ] Site loads: https://transpachain.site
- [ ] `/api/health` returns `"status": "ok"` (degraded is OK if mongo up and indexer running)
- [ ] `indexer.inSync: true` or explain backfill in progress
- [ ] CSS renders correctly (not unstyled HTML)
- [ ] At least one **Active** campaign indexed in `/campaigns`

### Wallets (prepare 3 if possible)

| Role | Needs | Purpose |
|------|-------|---------|
| **Donor** | Sepolia ETH (+ USDC for USDC flow) | Donate, vote, refund |
| **Org** | Sepolia ETH, `ORG_ROLE` | Submit proof, org actions |
| **Admin** | Sepolia ETH, `ADMIN_ROLE` or `VERIFIER_ROLE` | Verify org, approve evidence, queue/execute |

Fund all wallets from [Alchemy Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia).

### Contracts and indexer

Current Sepolia deployment:

| Contract | Address |
|----------|---------|
| CharityCore | `0xCE017838BfE2785CB2458bb205770663bEB9b0B8` |
| DonationVault | `0xEb421D07E885EeB2B8E9ea408FF284013F872Db1` |
| GovernanceDAO | `0xd655d85ddACc386901487CE8E1ec45BD4F872A19` |
| ImpactNFT | `0xF2556FcccaE36A6d8Da0C75a863CA7368FC6761a` |

- [ ] Root `.env` / frontend build-args match these addresses
- [ ] `DEPLOY_FROM_BLOCK=11146320` (or current deploy block)
- [ ] Backend logs show indexer listening (not stuck in backfill loop)

### Browser

- [ ] MetaMask on Sepolia
- [ ] Clear conflicting wallet extensions (optional)
- [ ] Open `/legal` in a tab for disclaimer slide

### Demo data setup tips

**If no campaigns exist:**

1. Connect **admin** wallet → `/admin` → verify an org wallet.
2. Connect **org** wallet → `/campaigns/create` → create a small-goal campaign (e.g. 0.05 ETH, 2 milestones, 7-day deadline).
3. Wait ~30s for indexer → refresh `/campaigns`.

**For governance demo without waiting 3 days:**

- Use a campaign that already has an **active proposal** near end of voting period, OR
- Pre-stage: org submitted proof yesterday; admin approved; donors partially voted.

**For refund demo:**

- Use a campaign with status **Failed** and your donor wallet has a balance, OR
- Pre-stage a low-goal campaign, donate, let deadline pass, finalize, then demo claim.

**Local seed (dev only):**

```bash
cd backend && npm run seed
```

Not available on production EC2 unless run manually.

---

## 10-minute demo flow (recommended)

### Minute 0–1: Hook — transparency problem

**Navigate:** `/`

**Talking points:**

- "Traditional charity — you send money and hope for the best."
- "TranspaChain locks every donation in an on-chain escrow vault until donors vote to release funds milestone by milestone."
- Point to homepage stats (campaigns, donors, raised amounts — indexed from Sepolia).

**Show:** Hero, Escrow-protected badge, live stats updating via WebSocket.

---

### Minute 1–2: Trust model — About + Legal

**Navigate:** `/about` → scroll to anti-abuse section

**Talking points:**

- Verified organizations only (`ORG_ROLE` after admin review).
- Quadratic voting — vote weight = √donation, reduces whale control.
- 51% quorum + 24-hour timelock before any release.
- Evidence admin review before donors vote.

**Navigate:** `/legal` (brief)

- "Sepolia testnet only — demonstration, not financial advice."

---

### Minute 2–4: Donor path — donate + NFT

**Navigate:** `/campaigns` → pick Active campaign

**Talking points:**

- Escrow Vault card — "Your ETH is here, not in the org's pocket."
- Milestone timeline — funds release incrementally.
- Progress bar — on-chain raised vs goal.

**Action:** Connect **donor** wallet → Donate 0.005–0.01 ETH

**Talking points during MetaMask:**

- 1% platform fee to treasury; net amount locks in escrow.
- Impact NFT mints on first donation — Bronze tier.
- Transaction visible on Sepolia Etherscan (click tx link).

**Navigate:** `/dashboard` — show NFT gallery and donation history.

---

### Minute 4–6: Org + admin path — evidence → governance

**Switch wallet to org** (or describe if same person):

**Talking points:**

- Org submits milestone proof with IPFS evidence (photo, report, receipt).
- "Real-world work happens off-chain; proof hash goes on-chain."

**Switch to admin wallet** → `/admin`:

- Show verified orgs list.
- Approve pending evidence/proposal (if staged).

**Navigate:** `/governance` or campaign voting panel

**Talking points:**

- Quadratic vote weight displayed.
- Donors who contributed can vote For/Against.
- After quorum → admin queues → 24h timelock → execute releases escrow slice.

**Optional action:** Cast a vote if proposal is active.

---

### Minute 6–8: Failure path — refund

**Navigate:** Failed campaign (pre-staged) OR explain without live tx

**Talking points:**

- Campaign missed goal → anyone finalizes → status Failed.
- Donors claim proportional refund — pull pattern, no admin can block.
- Contrast with cancel (zero donors) vs failed + refund.

**Action (if staged):** Claim refund with donor wallet.

---

### Minute 8–10: Close — Etherscan + differentiation

**Talking points:**

- Every donation, vote, and release is on Sepolia Etherscan — permanent audit trail.
- MongoDB indexer + IPFS metadata for fast UI; chain is source of truth.
- "This is testnet today; architecture shows how transparent charity could work at scale."

**Open:** Contract addresses on `/legal` → Etherscan.

---

## Role-play paths (pick one for focused demo)

### Path A — Donor only (5 min)

`/` → `/campaigns` → donate → `/dashboard` NFT → `/governance` vote → `/legal`

### Path B — Organization (7 min)

`/dashboard` org profile → `/admin` verify (admin assists) → `/campaigns/create` → submit proof → governance overview

### Path C — Admin / verifier (7 min)

`/admin` verify org → review evidence → approve proposal → queue → explain timelock → execute

---

## Q&A prep — anticipated questions

### Why Sepolia? Why not mainnet?

Sepolia is Ethereum's public testnet. TranspaChain is a **demonstration and education project**. Testnet ETH has no value; we avoid regulatory and financial risk while proving the architecture. Mainnet would require professional audits, legal review, and fiat compliance — out of current scope.

### How is money secured?

Donations go to the **DonationVault** smart contract, not the organization's wallet. Funds leave escrow only when:

1. A milestone proof is submitted and admin-approved,
2. Donors vote with quorum (51%),
3. Admin queues and waits 24h timelock,
4. Proposal executes → `releaseMilestoneFunds`.

Admin **cannot** drain escrow. See [security-audit.md](./security-audit.md).

### What if the campaign fails?

After deadline, the campaign can be finalized as **Failed**. Donors call `claimRefund()` to recover their remaining escrow proportionally. If some milestones were already released, refund is scaled to what's left.

### What if the organization lies about milestone proof?

- Admin reviews evidence **before** donors vote.
- Donors can vote **Against** — proposal defeated, escrow stays locked.
- Admin can **close** abusive proposals on-chain.
- Evidence CID is on IPFS — auditable, though content quality depends on review.

### What utility do Impact NFTs have?

Impact NFTs are **ERC-721 proof-of-donation badges** on testnet — Bronze, Silver, Gold tiers. They are transferable souvenirs, not investment products or governance tokens across campaigns. Repeat donations upgrade tier within the same campaign.

### What about gas costs?

Every action (donate, vote, refund, create campaign) requires Sepolia gas paid by the user. On mainnet, gas optimization and meta-transactions would be needed for mass adoption. Demo uses testnet where gas is free from faucets.

### How is this different from traditional charity?

| Traditional | TranspaChain |
|-------------|--------------|
| Org holds funds | Escrow vault |
| Trust-based reports | On-chain audit trail |
| Refund at org discretion | Smart-contract refund eligibility |
| Receipt email | Impact NFT + tx hash |

See [traditional-vs-transpachain.md](./traditional-vs-transpachain.md).

### Why quadratic voting?

Linear voting lets one large donor dominate. **Quadratic weight** (√donation) reduces whale influence while still rewarding contribution. Splitting donations across wallets does not increase total power.

### Is the data on the website trustworthy?

The UI reads from a **MongoDB indexer** (fast queries) synced from chain events. Source of truth is **Sepolia**. Verify any amount on Etherscan. `/api/health` shows sync status.

### Who are the team?

`/about` — founding team carousel with roles (CEO, CTO, COO, engineers). Built as a portfolio / research project.

---

## Fallback plans if something breaks live

| Problem | Fallback |
|---------|----------|
| **RPC slow / tx pending** | "Sepolia congestion — here's the submitted tx on Etherscan" (open pending tx). Continue talking through architecture. |
| **Empty campaigns** | Switch to `/about` + `/legal` + architecture diagram in [architecture.md](./architecture.md). Show Etherscan contract pages. |
| **Indexer lag** | Show MetaMask confirmed tx on Etherscan; explain indexer catches up in ~seconds. Check `/api/health`. |
| **Wallet won't connect** | Use pre-recorded screenshots or second browser profile. |
| **Governance timelock blocks execute** | Explain 24h timelock as security feature; show Queued state and countdown. |
| **USDC approve fails** | Fall back to ETH donate flow on an ETH campaign. |
| **Admin tab not visible** | Wrong wallet — switch to admin wallet or describe admin flow verbally with `/admin` screenshot. |
| **Site down** | Local `docker compose up` on laptop if configured; else walk through docs and Etherscan. |

---

## Six demo flows (reference)

Detailed flow variants — pick 2–3 per session:

| # | Flow | Key pages | Time |
|---|------|-----------|------|
| 1 | ETH donate + NFT | `/campaigns/[id]`, `/dashboard` | 2 min |
| 2 | USDC donate | Campaign with USDC token | 3 min |
| 3 | Milestone pass (DAO) | Org proof → `/governance` → vote → queue → execute | 4 min |
| 4 | Milestone fail | Vote Against / miss quorum | 2 min |
| 5 | Refund | Failed campaign → claim refund | 2 min |
| 6 | Cancel (zero donors) | New campaign, no donations, org cancel | 1 min |

### Flow 3 note — demo CIDs

Hardhat demo script may use placeholder CIDs (`QmMilestone0ProofCID`) not pinned on IPFS. UI shows "Demo proof" label. For live demos, use **Upload to IPFS** in Organization actions or `POST /api/ipfs/upload`.

---

## Post-demo resources

Share with audience:

- [user-manual.md](./user-manual.md) — full platform guide
- [smart-contracts-explained.md](./smart-contracts-explained.md) — contract FAQ
- https://transpachain.site/legal — disclaimer
- Sepolia Etherscan links from `/legal`
