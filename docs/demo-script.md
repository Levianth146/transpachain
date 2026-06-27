# 5-Minute Live Demo Script (Quick Reference)

> **Full guide:** [demo-guide.md](./demo-guide.md) — pre-demo checklist, Q&A prep, fallbacks, role-play paths.

**Site:** https://transpachain.site  
**Network:** Ethereum Sepolia  
**Admin wallet:** connect wallet with `ADMIN_ROLE` on CharityCore

## Contracts (Sepolia — current deploy)

| Contract | Address |
|----------|---------|
| CharityCore | `0xCE017838BfE2785CB2458bb205770663bEB9b0B8` |
| DonationVault | `0xEb421D07E885EeB2B8E9ea408FF284013F872Db1` |
| GovernanceDAO | `0xd655d85ddACc386901487CE8E1ec45BD4F872A19` |
| ImpactNFT | `0xF2556FcccaE36A6d8Da0C75a863CA7368FC6761a` |

---

## Pre-flight (30 seconds)

- [ ] MetaMask on Sepolia, donor wallet funded
- [ ] `/api/health` OK, at least one Active campaign
- [ ] `/legal` tab open for disclaimer

---

## Minute-by-minute (5 min)

| Time | Action | Talking point |
|------|--------|---------------|
| 0–1 | `/` homepage stats | Escrow model; funds locked until milestones pass |
| 1–2 | `/about` anti-abuse strip | Verified orgs, quadratic vote, timelock |
| 2–3 | `/campaigns/[id]` → donate ETH | Escrow card; Impact NFT mint; Etherscan link |
| 3–4 | `/governance` or voting panel | Donor vote; admin-approved evidence |
| 4–5 | `/dashboard` NFT + `/legal` | Donor proof badge; testnet disclaimer |

---

## Six flows (pick 2–3)

1. **ETH donate + NFT** — donate → dashboard gallery
2. **USDC donate** — approve + `donateUSDC` on USDC campaign
3. **Milestone pass** — org proof → admin approve → vote → queue → execute
4. **Milestone fail** — vote Against / miss quorum → escrow unchanged
5. **Refund** — Failed campaign → claim refund
6. **Cancel** — zero-donor campaign → org cancel

See [demo-guide.md](./demo-guide.md) for step detail and Q&A answers.

---

## Admin / verifier

- **Admin** tab: verify org (`verifyOrg`), review org profiles
- Approve milestone evidence before public governance vote
- Queue → timelock → execute after donor quorum

---

## Backup talking points

- Escrow ÷ remaining milestones = release per approved proof
- 1% platform fee to treasury on donate
- WebSocket live updates on homepage
- Quadratic voting: weight = √donation
- MongoDB indexer for fast UI; Sepolia is source of truth
