# TranspaChain — Security Analysis

Testnet (Sepolia) self-assessment. Not a substitute for a professional third-party audit.

## Automated analysis (Slither)

From `transpachain-contracts`:

```bash
pip install slither-analyzer
cd contracts
slither src/ --exclude-dependencies
```

Document findings below after each run. Re-run before major demos.

### Latest checklist

| Check | Status |
|-------|--------|
| ReentrancyGuard on value transfers | Implemented |
| Custom errors library (`Errors.sol`) | Added for gas / clarity |
| 282+ Foundry tests | Run `make contracts-test` |
| Slither on src/ | Run locally before release |

## Risks mitigated

| Risk | Solution |
|------|----------|
| Reentrancy | `ReentrancyGuard` on DonationVault |
| Push refunds | Pull pattern — `claimRefund()` |
| Flash-loan voting | Voting power from donation at snapshot |
| Overflow | Solidity ^0.8 |
| Spam campaigns | Creation deposit on `createCampaign` |
| Org bypassing DAO | `releaseMilestoneFunds` only callable by GovernanceDAO |
| Admin fund theft | Admin cannot drain escrow (only pause / fee config) |
| Timelock bypass | 24h `executeAfter` on queued proposals |

## Known limitations

**On-chain:**

- Voting power proportional to donation size (whale influence)
- No KYC for organizations
- Voting period ~3 days (block-based) — slow for emergencies
- Impact NFTs are transferable ERC-721 on testnet

**Off-chain:**

- Indexer is a single process — use `DEPLOY_FROM_BLOCK` backfill + MongoDB backups
- IPFS via Pinata — pin permanence depends on pinning service
- MetaMask-first UX (WalletConnect optional future work)

**Scope:**

- ETH and USDC on Sepolia only
- No mainnet deployment in this repository phase

## Custom errors (Phase 4)

Library: [`transpachain-contracts/src/Errors.sol`](../transpachain-contracts/src/Errors.sol)

Migrate `require(..., "string")` to `revert TranspaChainErrors.*()` on contract redeploy to save gas and improve tooling.

## Disclaimer

Use `/legal` on the frontend. Do not present testnet badges or contracts as regulated financial products.
