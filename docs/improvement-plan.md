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
| CharityCore | `0xA13344e56a2421322bb2985ffE37b07DB80B760d` |
| DonationVault | `0x72116A0BCe20473FE1BfcC2da9D2337A6D39Ed5c` |
| GovernanceDAO | `0x290770c85B42c3a32365f6f6350587878dCbe2D5` |
| ImpactNFT | `0x17CcdcF683626B5c914640154464bF64Ca66DB18` |

Live: https://transpachain.site
