# ADR 0001 — Fuji V2 redeploy

## Context

Fuji V1 (block `61361175`) shipped CharityCore / DonationVault / GovernanceDAO / ImpactNFT only. Topic 5 Modules A–C require DisbursementController + Safe 3/5, YieldManager + MockERC4626, DAO approve-only semantics, and ledger classifications that V1 addresses cannot support without unsafe in-place upgrades.

## Decision

Redeploy a full **V2** suite on Avalanche Fuji (block `61364951`), record it under `deployments.v2` in `contracts/deployments/43113.json`, and point backend/frontend env at V2. Keep V1 in the manifest as history. Use a fresh Mongo database name `transpachain-fuji-v2`.

## Consequences

- Clean separation of indexer state; no mixed V1/V2 event streams in one DB.
- Demo and docs reference only V2 addresses; V1 is obsolete for judging.
- Requires create-safe → deploy-v2 → env rewire → indexer resync before E2E.
- Contract verification may lag on Routescan; functionality does not depend on verified source.
