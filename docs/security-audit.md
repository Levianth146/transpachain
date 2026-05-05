# TranspaChain — Security Analysis

## Risks Mitigated

| Risk | Solution |
|---|---|
| Reentrancy attack | `ReentrancyGuard` on all ETH-moving functions |
| Push vs Pull payment | Pull pattern — donors call `claimRefund()` |
| Flash loan governance | Voting power = donation at time of donate, not vote |
| Integer overflow | Solidity ^0.8 built-in overflow protection |
| Spam campaigns | Minimum ETH deposit to create campaign |
| Org bypassing governance | `releaseMilestoneFunds` callable only by GovernanceDAO |
| Admin rug-pull | Admin can only pause — cannot withdraw funds |
| IPFS link rot | Store CID on-chain, not HTTP URL |
| Timelock bypass | 24h delay before proposal execution |

## Known Limitations (v1 Scope)

**On-chain:**
- Voting power proportional to ETH — whale risk
- No KYC for charity orgs
- High gas when many donors vote simultaneously
- 3-day voting period slow for emergencies

**Off-chain:**
- Backend indexer is single point of failure (add replica in v2)
- IPFS availability depends on Pinata pin service
- Only MetaMask supported (no WalletConnect in v1)

**Out of scope for v1:**
- ERC-20 token donations (ETH only)
- Cross-chain support
- Mobile app
- Fiat on-ramp
