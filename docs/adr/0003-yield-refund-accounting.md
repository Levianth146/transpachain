# ADR 0003 — Yield and refund accounting

## Context

Idle USDC in escrow could earn yield, but real DeFi integrations are out of scope for the hackathon. Refunds after cancel/fail must remain fair when part of the NAV sits in a vault. Milestone `releaseAmount` must track NAV (liquid + invested), not a stale escrow snapshot alone.

## Decision

1. Ship **MockERC4626Vault** + **YieldManager** (allocate / redeem, policy caps) for opt-in USDC campaigns only; native AVAX campaigns cannot move to yield.
2. Enforce `LOSS_SINK = address(0x…dEaD)` so `simulateLoss` burns value instead of paying a team wallet.
3. Before refund claims on cancel/fail, require **`settleYieldForRefund`** (redeem all → credit escrow) so proportional `claimRefunds` see settled balances.
4. Index yield as `YIELD_ALLOCATE` / `YIELD_REDEEM` (internal, net-zero to NAV identity) distinct from `EXPENSE_PAID` / `REFUND_PAID`.

## Consequences

- Judges can see allocate → simulateYield → settle → refund in one demo path.
- UI must badge **Mock Yield**; never imply mainnet returns.
- Additional failure modes (insufficient liquidity, settle-before-claim) must be handled in UX and docs.
- Real ERC-4626 adapters remain a post-hackathon roadmap item.
