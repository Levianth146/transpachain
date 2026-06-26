# Phase 3 Redeploy Log — df63fae (campaign lifecycle fixes)

**Date:** 2026-06-27  
**Commit:** `df63fae` — Fix campaign escrow, refund, and governance logic per technical brief  
**Network:** Sepolia (chain ID 11155111)  
**Deployer:** `0xA7aC8154fa3019f5e95Ba3720240C782C0e3ED70`

## Tests

- `forge test` — **311 passed**, 0 failed

## New contract addresses

| Contract | Address |
|----------|---------|
| CharityCore | `0xCE017838BfE2785CB2458bb205770663bEB9b0B8` |
| DonationVault | `0xEb421D07E885EeB2B8E9ea408FF284013F872Db1` |
| GovernanceDAO | `0xd655d85ddACc386901487CE8E1ec45BD4F872A19` |
| ImpactNFT | `0xF2556FcccaE36A6d8Da0C75a863CA7368FC6761a` |

## Indexer

- **DEPLOY_FROM_BLOCK:** `11146320`
- CharityCore deploy tx: `0x61822e8889bfc930debeb9f2c7702e22c621c735f844278830accfaa0bdff3e5`
- Set `DEPLOY_FROM_BLOCK=0` after backend indexer backfill completes.

## Deploy notes

- Alchemy Sepolia RPC hit monthly capacity limit; deploy completed via `https://ethereum-sepolia-rpc.publicnode.com`.
- Initial `deploy.ts` failed at `nft.setTrustedContracts` with `replacement transaction underpriced`; wiring completed manually (core was already wired).
- All four contracts **verified on Etherscan**.
- **setTierMetadata** run for new ImpactNFT (reused Pinata CIDs: Bronze/Silver/Gold).

## Post-deploy EC2 steps

```bash
# 1. Update EC2 ~/transpachain/.env with new addresses + DEPLOY_FROM_BLOCK=11146320

# 2. WSL — rebuild frontend with new NEXT_PUBLIC_* addresses
cd /root/projects/transpachain
make docker-build-frontend
docker push cuongnguyen146/transpachain-frontend:latest

# 3. EC2 — pull backend (if pushed) + frontend, restart
cd ~/transpachain
git pull && git submodule update --init --recursive
docker compose pull
docker compose up -d
# After indexer catches up: set DEPLOY_FROM_BLOCK=0 in .env and restart backend
```

## Deprecated addresses (v2)

- CharityCore `0x8a5e023b16ab13939260492dAe72a0be1E597e1a` (block 11102718)
- DonationVault `0x68Bb9f5E1414b1a62372EbF02fdEe4c09fFc7C32`
- GovernanceDAO `0xCcAEaF248E536850877B9f948cB237Fe7885b513`
- ImpactNFT `0xD651d3531a44ee7941bFE257c79F41d274E180A6`
