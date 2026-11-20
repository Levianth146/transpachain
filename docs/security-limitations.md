# Security limitations — TranspaChain 2.0

Read this before treating the UniHack demo as production software.  
Product overview: [../README.md](../README.md)

---

## Hard limits

| Limitation | Detail |
|---|---|
| **Testnet only** | Avalanche Fuji (`43113`). No mainnet deploy for judging. |
| **Mock yield** | `MockERC4626Vault` + `simulateYield` / `simulateLoss`. Not Aave/Benqi. UI must show **Mock Yield**. |
| **Team-held Safe keys** | Demo Safe owners are team-controlled MetaMask EOAs so 3/5 signing is demoable. Real deployments need independent custodians. |
| **No professional audit** | Foundry tests + internal review only. |
| **No real money** | Faucet AVAX + Circle **test** USDC only. |
| **Legal** | Live charity/crowdfunding in any jurisdiction needs counsel (AML, fundraising, data). Out of UniHack scope. |

---

## Known product / technical caveats

- **USDC NFT tier mismatch (known):** mint path thresholds historically differ from `upgradeTier` constants — documented, not silently “fixed” mid-deadline.  
- **Receipt hash ≠ delivery proof** — integrity of a file, not proof of goods/services.  
- **Indexer confirmations, not deep reorg rollback** — `INDEXER_CONFIRMATIONS` (default 3).  
- **Donation-weighted governance** — larger donors still have more influence (quadratic softens, does not eliminate).  
- **IPFS / Pinata dependency** — CID availability depends on the pinning provider.  
- **Single indexer process** — operational SPOF for the *cache*; chain remains source of truth.  
- **`executeDisbursement` expiry edge** — expired requests may stay Pending until cancelled (acceptable for demo).

---

## Mitigations that *are* in place

- `ReentrancyGuard` on value-moving paths  
- Pull-pattern refunds (`claimRefund`)  
- DAO approve-only + Safe-gated third-party payouts  
- One-time `setDisbursementController` / `setYieldManager`  
- `LOSS_SINK` forced to `dEaD` in deploy script  
- Timestamp-based governance windows (Avalanche sparse blocks)  
- Idempotent ledger upserts by `(chainId, txHash, logIndex)`

---

## Related

- [adr/0002-safe-and-dao.md](./adr/0002-safe-and-dao.md)  
- [transparent-accounting.md](./transparent-accounting.md)  
- [architecture.md](./architecture.md)
