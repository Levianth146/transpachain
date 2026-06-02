# 5-Minute Live Demo Script

**Site:** https://transpachain.site  
**Network:** Ethereum Sepolia  
**Admin wallet:** connect wallet with `ADMIN_ROLE` on CharityCore

## Contracts (Sepolia)

| Contract | Address |
|----------|---------|
| CharityCore | `0x6fEEF9276B2215F0d41a0c7515Ea6718099552d4` |
| DonationVault | `0x016377C129f1d7B0Abbda97B8676D273F419cBAb` |
| GovernanceDAO | `0x558e7811ae467f82A60E5c6FEa7aaeAae61f2c44` |
| ImpactNFT | `0x6B6e671EfB7fbEaBF41a7cCC4683F3683c88e5fd` |

## Minute 0–1: Homepage

- Show hero stats (campaigns, ETH donated, donors) — indexed from chain events.
- Explain: milestone escrow + donor voting, not instant withdrawal by org.

## Minute 1–2: Admin (optional)

- Open **Admin** tab → verify org wallet address.
- Mention `VERIFIER_ROLE` can verify without full admin.

## Minute 2–3: Campaign

- Open a campaign → progress bar, milestones, payment token (ETH or USDC).
- **Donate** — show MetaMask on Sepolia; mention Impact NFT on first donation.
- If campaign failed/expired → show **Claim refund** panel.

## Minute 3–4: Governance

- Org submits milestone proof (or show existing proposal).
- Donor **Vote** on governance panel.
- Explain timelock before funds move to org.

## Minute 4–5: Transparency

- Link Etherscan tx for last donation.
- Mention MongoDB indexer + IPFS metadata (Pinata).
- Close with testnet disclaimer (`/legal`).

## Backup talking points

- Repeat donation can upgrade NFT tier.
- USDC path: approve then `donateUSDC`.
- Backend API: `/api/campaigns`, WebSocket live updates on homepage.
