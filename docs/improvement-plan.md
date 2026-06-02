# TranspaChain Improvement Plan

Official 4-week roadmap. Testnet (Sepolia) only — no mainnet scope.

## Week 1 — Demo kit (anti Q&A)

- [x] `charity-business-flow.md` — real-world vs on-chain mapping
- [x] `smart-contracts-explained.md` — contracts FAQ
- [x] `demo-script.md` — 5-minute live demo
- [x] `mongodb-guide.md` — DB flow + Compass/Atlas
- [x] `donate-flow.md` — ETH, USDC, refund branches
- [x] DonationVault: NFT tier upgrade on repeat donate
- [x] Frontend: USDC donate, claim refund, `/legal`
- [x] Root `Makefile` + `NEXT_PUBLIC_USDC_ADDRESS`

## Week 2 — Visual / UX

- [x] Expedition 33–lite palette (tailwind + globals)
- [x] Logo component + Racing Sans One wordmark
- [x] Phosphor icons in nav/cards/hero
- [x] Motion + expanded skeletons

## Week 3 — Features + backend

- [x] Search/filter, countdown, category badges
- [x] Dark mode (`next-themes`)
- [x] Responsive nav + donate modal
- [x] Socket.io live updates on homepage
- [x] Historical indexer backfill (`DEPLOY_FROM_BLOCK`)
- [x] Rate limiting + error middleware
- [x] Production CORS in docker-compose

## Week 4 — Contracts + infra

- [x] Custom errors (core contracts)
- [x] Edge-case Foundry tests (multi-donate NFT)
- [x] `security-audit.md` + Slither instructions
- [x] CI `NEXT_PUBLIC_*` build-args documented

## Out of scope

- Mainnet, paid audit, ERC-1155, solmate, foundry-devops migration
- NFT market value guarantees

## Deployed Sepolia (reference)

| Contract | Address |
|----------|---------|
| CharityCore | `0x6fEEF9276B2215F0d41a0c7515Ea6718099552d4` |
| DonationVault | `0x016377C129f1d7B0Abbda97B8676D273F419cBAb` |
| GovernanceDAO | `0x558e7811ae467f82A60E5c6FEa7aaeAae61f2c44` |
| ImpactNFT | `0x6B6e671EfB7fbEaBF41a7cCC4683F3683c88e5fd` |

Live: https://transpachain.site
