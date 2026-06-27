# TranspaChain User Manual

A complete guide to using transpachain.site on **Ethereum Sepolia testnet**. Complete English guide for donors, organizations, and administrators.

> **Disclaimer:** TranspaChain is a demonstration platform. Do not send mainnet ETH or real assets. See [/legal](https://transpachain.site/legal).

---

## 1. Platform overview

TranspaChain is a transparent charity platform where:

- Donations lock in a **smart-contract escrow vault** (ETH or USDC)
- Organizations must be **verified** before creating campaigns
- Milestone fund releases require **donor governance votes** with quadratic weighting
- Donors receive **Impact NFT** badges (Bronze / Silver / Gold)
- Failed campaigns enable **on-chain refunds**

**Network:** Ethereum Sepolia testnet only  
**Live URL:** https://transpachain.site

### How it differs from traditional charity

| Traditional | TranspaChain |
|-------------|--------------|
| Org holds funds directly | Funds locked in DonationVault escrow |
| Internal approval for spending | Donor vote after milestone proof |
| Periodic reports | Every transaction on Sepolia Etherscan |
| Refund policy varies | Automatic refund eligibility on-chain |

See also: [traditional-vs-transpachain.md](./traditional-vs-transpachain.md)

---

## 2. Getting started

### Install MetaMask

1. Install [MetaMask](https://metamask.io/) browser extension.
2. Create or import a wallet.
3. Add **Sepolia test network** (MetaMask usually includes it; if not, add chain ID `11155111`).

### Get test ETH

Sepolia ETH has no real value. Obtain free test ETH from a faucet:

- [Alchemy Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)
- [Google Cloud Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

Keep a small buffer for gas (donations, votes, refunds each need gas).

### Connect wallet on TranspaChain

1. Open https://transpachain.site
2. Click **Connect Wallet** (top navigation)
3. Select MetaMask → approve connection
4. Confirm MetaMask shows **Sepolia** network

If you see wrong network warnings, switch MetaMask to Sepolia manually.

### Test USDC (optional)

For USDC campaigns, you need Sepolia test USDC at `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`. Circle or community faucets may provide test USDC on Sepolia.

---

## 3. For donors

### Browse campaigns

- **Homepage (`/`)** — platform stats, featured campaigns, live updates
- **Campaigns (`/campaigns`)** — full list with category filters and search

Click a campaign card to open its detail page.

### Understand the campaign page

| Element | Meaning |
|---------|---------|
| Progress bar | Raised vs goal (on-chain amounts) |
| Escrow Vault card | Funds locked until milestones approved |
| Milestone timeline | Pending / voting / released states |
| Donate button | Open donation modal |
| Voting panel | Active governance proposals for this campaign |
| Evidence panel | **View full evidence** button opens image + description modal with IPFS link |
| Claim refund | Appears when campaign failed and you are eligible |

### Donate with ETH

1. Click **Donate** on an active campaign.
2. Enter amount in ETH.
3. Confirm MetaMask transaction on Sepolia.
4. Wait for confirmation → toast + Impact NFT mint note.
5. View your NFT on **Dashboard**.

A 1% platform fee goes to the treasury at donation time; the rest locks in escrow.

### Donate with USDC

Only available on campaigns created with USDC payment token.

1. Click **Donate** → select USDC.
2. First transaction: **Approve** USDC spending for DonationVault.
3. Second transaction: **Donate USDC**.
4. Escrow holds USDC until milestone release.

### Impact NFT badges

- **One NFT per donor per campaign** (minted on first donation)
- **Tiers:** Bronze → Silver → Gold based on cumulative donation
- **Repeat donations** upgrade tier on-chain
- View gallery on `/dashboard`
- NFTs are transferable ERC-721 on testnet (souvenir/proof, not investment)

### Governance voting

1. You must have donated to the campaign to vote.
2. Go to **Governance** (`/governance`) or the campaign voting panel.
3. Open a proposal → cast **For**, **Against**, or **Abstain**.
4. Your vote weight = **√(amount donated)** — quadratic weighting reduces whale dominance.

Proposals only appear after admin approves milestone evidence off-chain.

### Claim refunds

When a campaign **fails** (goal/deadline not met) or you are past deadline:

1. Open the campaign page.
2. If eligible, **Claim refund** panel appears.
3. Confirm `claimRefund` transaction in MetaMask.
4. Receive proportional remaining escrow (adjusted if some milestones were already released).

---

## 4. For organizations

### Become a verified organization

1. Connect your org wallet on `/dashboard`.
2. Fill **Organization Profile** form (name, description, website, contact).
3. Wait for admin review (off-chain approval).
4. Admin calls `verifyOrg` on-chain → your wallet receives `ORG_ROLE`.
5. **Create Campaign** link becomes available.

You cannot create campaigns until verified.

### Create a campaign

1. Go to `/campaigns/create` (or **Create** in nav).
2. Upload cover image, fill title, description, category, goal, deadline.
3. Define milestones (count and descriptions).
4. Choose payment token: ETH or USDC.
5. Submit → signs `createCampaign` on-chain (requires creation deposit + gas).
6. Campaign appears after indexer processes the event (~seconds to minutes).

### Manage your campaign

On your campaign detail page, **Organization actions** panel:

| Action | When to use |
|--------|-------------|
| Submit milestone proof | Work completed — use **Upload to IPFS** to pin proof and auto-fill CID, or paste CID manually |
| Extend deadline | Need more time (max 30 days per extension on-chain) |
| Finalize | After deadline if goal not met → triggers Failed status |
| Cancel | Only if zero donations |

### Submit milestone evidence

1. In **Organization actions**, click **Upload to IPFS** on the milestone proof row (or paste a CID manually).
2. Upload proof file (photos, reports, receipts) — backend pins via Pinata and fills the CID field.
3. Submit proof on-chain → creates governance proposal.
4. Separately, submit evidence (image + description) for admin review.
5. Admin approves evidence → donors can view full evidence and vote.
6. If vote passes, funds release after timelock.

---

## 5. For admins and verifiers

The **Admin** tab appears in navigation only when your connected wallet has `ADMIN_ROLE`, `VERIFIER_ROLE`, or `DEFAULT_ADMIN_ROLE` on CharityCore.

### Verify organizations

1. `/admin` → review pending org profiles.
2. Approve or reject off-chain application.
3. Enter wallet address → **Verify on-chain** (`verifyOrg`).
4. To remove trust: **Revoke** (`revokeOrg`).

### Review evidence and proposals

1. **Pending Proposals** — milestone proofs awaiting approval.
2. Inspect IPFS evidence link.
3. **Approve** → proposal visible on `/governance`.
4. **Reject** or **Close** → donors protected from bad proofs.

### Governance execution

After donors vote and quorum is met:

1. **Queue** proposal (starts 24h timelock).
2. After timelock → **Execute & Release Funds**.
3. Escrow transfers milestone slice to org wallet.

### Reconcile indexer (operators)

If stats look wrong after contract redeploy, operators can trigger reconcile endpoints (requires deployment access). See [deploy.md](./deploy.md).

---

## 6. Dashboard

Connect wallet at `/dashboard` to see:

| Section | Description |
|---------|-------------|
| **Stats** | Total ETH/USDC donated, campaigns supported, milestones released |
| **Donation history** | List with Etherscan transaction links |
| **Impact NFT gallery** | Your tier badges per campaign |
| **Org profile form** | Submit/update organization application |
| **Notifications** | Proposals needing your vote |

Without a connected wallet, the page prompts you to connect MetaMask.

---

## 7. Governance

**Hub:** `/governance`  
**Detail:** `/governance/[proposalId]`

| Concept | Explanation |
|---------|-------------|
| **Quadratic voting** | Vote weight = √(donation amount) |
| **Quorum** | 51% of total voting power must participate |
| **Timelock** | 24 hours after queue before execute |
| **States** | Active → Queued → Executed, or Defeated |
| **Admin gate** | Evidence must be admin-approved before voting opens |

Only wallets that donated to the campaign can vote.

---

## 8. About and Legal

### About (`/about`)

- Mission statement and how TranspaChain works (6-step flow)
- Anti-abuse policies (verified orgs, escrow, quorum, refunds)
- **Founding Team** — Mercedes-style contributor carousel with profile cards
- Team members: CEO, CTO, COO, and core contributors (see page for current roster)

### Legal (`/legal`)

- Testnet-only disclaimer
- Not a registered charity or investment platform
- Deployed contract addresses with Etherscan links
- IPFS and third-party service notes

Always read `/legal` before demonstrating to external stakeholders.

---

## 9. Troubleshooting

### MetaMask issues

| Problem | Solution |
|---------|----------|
| Wrong network | Switch MetaMask to Sepolia (chain ID 11155111) |
| Transaction pending forever | Check [Sepolia Etherscan](https://sepolia.etherscan.io); try speed up or cancel in MetaMask |
| Insufficient funds | Get Sepolia ETH from a faucet |
| USDC donate fails | Ensure you approved USDC first; check USDC balance |

### RPC / connectivity

| Problem | Solution |
|---------|----------|
| Page loads but wallet reads fail | Alchemy RPC may be rate-limited; retry or wait |
| Stats show zero | Indexer may be backfilling — check `/api/health` |
| Campaign missing after create | Wait for indexer; verify tx succeeded on Etherscan |

### Indexer lag

- Backend indexes events asynchronously from Sepolia.
- Homepage uses WebSocket for live updates; refresh if stale.
- After contract redeploy, operator must update `DEPLOY_FROM_BLOCK` and reconcile.

### Empty campaigns list

- No campaigns created yet on current contract deployment.
- Create one as verified org, or wait for indexer backfill.

### Health check

Visit: `https://transpachain.site/api/health`

Look for `"status": "ok"` and `"inSync": true` in the indexer section.

---

## Related documentation

| Doc | Audience |
|-----|----------|
| [demo-guide.md](./demo-guide.md) | Presenters and demo operators |
| [workflow.md](./workflow.md) | Step-by-step technical flows |
| [smart-contracts-explained.md](./smart-contracts-explained.md) | Contract FAQ |
| [deploy.md](./deploy.md) | Operators deploying the stack |
