# ADR 0002 — Safe 3/5 and DAO approve-only

## Context

Milestone release that lets the DAO both approve and transfer escrow concentrates power and complicates multisig custody. Charities need donor governance for *permission* and a separate controlled *payout* path with receipt attestation.

## Decision

1. **GovernanceDAO `execute` → `approveMilestone` only** — no escrow transfer on execute; legacy `releaseMilestoneFunds` reverts on V2 vaults.
2. **DisbursementController** holds the payout workflow: org `requestDisbursement` (receipt hash + CID) after approval; **Gnosis Safe 3/5** is the only executor of `executeDisbursement`.
3. Safe is created from canonical Fuji Safe 1.4.1 deployments via `create-safe.ts`; address wired as `DISBURSEMENT_SAFE`.
4. Controller and yield manager setters on the vault are **one-time** to prevent owner swap/drain.

## Consequences

- Clear separation: donors grant permission; multisig releases funds with an on-chain receipt commitment.
- Demo uses five team MetaMask EOAs so 3/5 signing is reproducible for judges (documented limitation).
- Signatures are off-chain EIP-712; only the executing account pays gas.
- Extra UX steps (request → collect sigs → execute) versus single-tx release.
