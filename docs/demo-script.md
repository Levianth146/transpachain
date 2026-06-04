# 5-Minute Live Demo Script

**Site:** https://transpachain.site  
**Network:** Ethereum Sepolia  
**Admin wallet:** connect wallet with `ADMIN_ROLE` on CharityCore

## Contracts (Sepolia — current deploy)

| Contract | Address |
|----------|---------|
| CharityCore | `0x6fEEF9276B2215F0d41a0c7515Ea6718099552d4` |
| DonationVault | `0x016377C129f1d7B0Abbda97B8676D273F419cBAb` |
| GovernanceDAO | `0x558e7811ae467f82A60E5c6FEa7aaeAae61f2c44` |
| ImpactNFT | `0x6B6e671EfB7fbEaBF41a7cCC4683F3683c88e5fd` |

> After redeploy, update addresses in `.env` and this table.

---

## Six demo flows (pick 2–3 per session)

### Flow 1 — ETH donate + Impact NFT

1. Homepage stats (indexed donations).
2. Open **Active** campaign → **Escrow Vault** card (funds locked).
3. **Donate** ETH → MetaMask Sepolia → Impact NFT mint.
4. Etherscan tx link from wallet history.

### Flow 2 — USDC donate

1. Campaign with `paymentToken = USDC`.
2. Approve USDC → `donateUSDC` in modal.
3. Escrow holds USDC until milestone release.

### Flow 3 — Milestone pass (DAO)

1. Org wallet: **Organization actions** → submit milestone proof (IPFS CID).
2. **Governance** nav → see proposal; or campaign **Voting** panel.
3. Donor votes **For** → **Queue** → wait timelock → **Execute & Release Funds**.
4. Milestone timeline shows **Released**.

### Flow 4 — Milestone fail

1. Vote **Against** or miss 51% quorum → proposal **Defeated**.
2. Org can resubmit on-chain (`resubmitProposal` — UI optional).
3. Explain escrow unchanged until a proposal passes.

### Flow 5 — Refund

1. Campaign misses goal → org/anyone **Finalize** → status **Failed**.
2. Donor **Claim refund** — proportional if partial milestones released.
3. **Escrow** card shows eligibility.

### Flow 6 — Cancel (zero donors)

1. New campaign, no donations.
2. Org **Cancel** — status Cancelled.
3. Contrast with failed + refund path.

---

## Minute-by-minute (5 min)

| Time | Action |
|------|--------|
| 0–1 | Homepage + **Governance** hub overview |
| 1–2 | **Dashboard** org profile (off-chain) → **Admin** verify on-chain |
| 2–3 | Campaign: escrow card + donate (Flow 1 or 2) |
| 3–4 | Org submit proof + donor vote (Flow 3) |
| 4–5 | Etherscan + `/legal` testnet disclaimer |

---

## Admin / verifier

- **Admin** tab: verify org address (`verifyOrg`).
- **Organization applications**: review off-chain profile first.
- **VERIFIER_ROLE**: same verify UI; tab Admin visible after frontend deploy.

---

## Backup talking points

- Escrow ÷ remaining milestones = release amount per proof.
- 1% platform fee to treasury on donate.
- WebSocket live updates on homepage.
- **Repeat donate NFT tier upgrade** — requires contract redeploy (`63300f6`).
- MongoDB seed for portfolio: `npm run seed` in backend (dev only).
