# TranspaChain 2.0 — Architecture (Avalanche Fuji V2)

> Sepolia / ETH-only diagrams are obsolete. Active stack = **Fuji V2** (deploy block `61364951`).  
> Full Topic 5 docs: [README](../README.md) · [fuji-deployment.md](./fuji-deployment.md) · [transparent-accounting.md](./transparent-accounting.md) · [adr/](./adr/).

## Runtime topology

```
Browser + MetaMask (Fuji)
        │
        ├─► Frontend (Vercel / localhost:3000)  — wagmi writes to C-Chain
        │         │
        │         └─► Backend REST (Render / :3001)  — reads Mongo cache
        │                    │
        │                    ├─► MongoDB Atlas `transpachain-fuji-v2`
        │                    └─► PublicNode RPC eth_getLogs (indexer)
        ▼
Avalanche Fuji C-Chain
  CharityCore · DonationVault · GovernanceDAO · ImpactNFT
  DisbursementController · YieldManager · MockERC4626Vault
  Safe 3/5 · Circle USDC
```

## Contract relationships (V2)

```
CharityCore ── lifecycle ──► DonationVault
                                 │
                    ┌────────────┼────────────────┐
                    ▼            ▼                ▼
              GovernanceDAO  YieldManager   DisbursementController
              (approve only)  └─ Mock4626         └─ Safe 3/5 execute
                    │                                  │
                    └── approveMilestone ──► request ──► payout + receiptHash
```

## On-chain vs off-chain

| Data | Where | Why |
|---|---|---|
| Campaign / escrow / votes / approvals | C-Chain contracts | Trustless money + permission |
| Disbursement requests + receipt hash/CID | DisbursementController | Public proof-of-commitment |
| Safe threshold execution | Gnosis Safe | Multisig custody |
| Titles, media, search, ledger cache | Mongo + IPFS | Gas / UX |
| Yield share balances (mock) | MockERC4626 | Demo NAV; not real DeFi |

## Data flow

```
Write: UI → MetaMask → Fuji tx → event
Read (fast): UI → Backend → Mongo (indexer lag bounded by confirmations)
Reconcile: Snowtrace + /transparency + CSV
```

## See also

- [demo-topic5.md](./demo-topic5.md) — G4 E2E path
- [hosting.md](./hosting.md) — Atlas → Render → Vercel
- [security-limitations.md](./security-limitations.md)
