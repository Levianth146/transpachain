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
| CharityCore | `0x8a5e023b16ab13939260492dAe72a0be1E597e1a` |
| DonationVault | `0x68Bb9f5E1414b1a62372EbF02fdEe4c09fFc7C32` |
| GovernanceDAO | `0xCcAEaF248E536850877B9f948cB237Fe7885b513` |
| ImpactNFT | `0xD651d3531a44ee7941bFE257c79F41d274E180A6` |

Live: https://transpachain.site
