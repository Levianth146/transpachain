# Security limitations — TranspaChain 2.0 (UniHack)

Read this before treating the demo as production-ready software.

---

## Hard limits

| Limitation | Detail |
|---|---|
| **Testnet only** | Avalanche Fuji (`43113`). No mainnet deployment for judging. |
| **Mock yield** | `MockERC4626Vault` + `simulateYield` / `simulateLoss`. Not Aave/Benqi/etc. UI must show **Mock Yield**. |
| **Team-held Safe keys** | Demo Safe `0xf2dD…737A` uses **5 MetaMask EOAs controlled by the team** so 3/5 signing is demoable. Independent custodians are required for any real deployment. |
| **No professional audit** | Foundry tests + internal review only. Not audited by a firm. |
| **No real money** | Use faucet AVAX and Circle **test** USDC only. |
| **Vietnam legal review** | Operating a live charity / crowdfunding product in Vietnam needs counsel (AML, fundraising, data, e-money). Out of scope for UniHack. |

---

## Known product / technical caveats

- **USDC tier mismatch (known):** Impact NFT / donation tier thresholds historically mismatched between mint path (e.g. 10/100) and upgrade path (e.g. 25/250). Documented; not fixed for this deadline.
- **Receipt hash ≠ delivery proof** — integrity of a file, not proof of goods/services delivered.
- **Indexer confirmations, not reorg rollback** — `INDEXER_CONFIRMATIONS` (default 3); deep reorg handling deferred.
- **Whale governance** — voting power proportional to donations.
- **Pinata / IPFS dependency** — CID availability depends on pinning provider.
- **Single indexer process** — backend is an operational SPOF for the off-chain ledger cache (on-chain remains source of truth).
- **`executeDisbursement` expiry edge** — expired requests may remain Pending until cancelled (known; acceptable for demo).

---

## Mitigations that *are* in place

- `ReentrancyGuard` on value-moving paths
- Pull-pattern refunds (`claimRefunds`)
- DAO approve-only + Safe-gated payouts
- One-time `setDisbursementController` / `setYieldManager`
- `LOSS_SINK` forced to `dEaD` in deploy script
- Timestamp-based governance windows (Avalanche sparse blocks)
- Idempotent ledger upserts by `(chainId, txHash, logIndex)`

---

## Related

- Legacy notes: [security-audit.md](./security-audit.md) (pre-V2 ETH/Sepolia analysis — historical)
- [adr/0002-safe-and-dao.md](./adr/0002-safe-and-dao.md)
- [transparent-accounting.md](./transparent-accounting.md)
