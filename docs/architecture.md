# Architecture — TranspaChain 2.0

Active environment: **Avalanche Fuji C-Chain** (`43113`), deploy block **`61364951`** (`deployments.v2`).  
Product overview: [../README.md](../README.md)

---

## 1. What each layer owns

| Layer | Responsibility | Not responsible for |
|---|---|---|
| **Smart contracts** | Custody, permissions, votes, payouts, NFT mint rules | Pretty titles, search, image CDN |
| **Backend indexer** | Watch logs → Mongo ledger/cache; REST + Socket.io | Moving money |
| **Frontend** | UX, wallet txs, public audit views, live `eth_call` reads | Being the source of truth for balances |
| **IPFS / Pinata** | Store evidence & receipt files; return CIDs | Proving real-world delivery |
| **Safe 3/5** | Threshold execution of disbursements | Creating campaign policy |

---

## 2. Runtime topology

```text
Browser + MetaMask (Fuji)
        │
        ├─► Frontend (Vercel / localhost:3000)
        │         │  wagmi writes → C-Chain
        │         └─► Backend REST (Render / :3001)
        │                    ├─► MongoDB `transpachain-fuji-v2`
        │                    └─► RPC eth_getLogs (indexer)
        ▼
Avalanche Fuji
  CharityCore · DonationVault · GovernanceDAO · ImpactNFT
  DisbursementController · YieldManager · MockERC4626Vault
  Safe 3/5 · Circle USDC
```

---

## 3. Contract graph (Module A / B / C)

```text
CharityCore ── lifecycle ──► DonationVault
                                 │
                 ┌───────────────┼────────────────┐
                 ▼               ▼                ▼
           GovernanceDAO   YieldManager    DisbursementController
           (approve only)  └─ Mock4626           └─ Safe 3/5 execute
                 │                                    │
                 └── approveMilestone ──► request ──► payout + receiptHash
```

| Module | Contracts | Behavior |
|---|---|---|
| **A — Safe disbursement** | GovernanceDAO, DonationVault, DisbursementController, Safe | Vote → approve → request → multi-sig execute |
| **B — Accounting** | (indexer + APIs over events from all of the above) | Public ledger, expenses, finance CSV |
| **C — Mock yield** | YieldManager, MockERC4626Vault | USDC opt-in idle capital only |

---

## 4. On-chain vs off-chain data

| Data | Where | Why |
|---|---|---|
| Escrow, votes, approvals, NFT ownership | C-Chain | Trustless money & rights |
| Disbursement requests + receipt hash/CID | DisbursementController | Public commitment |
| Titles, media, search, aggregated ledger | Mongo (+ IPFS for blobs) | Gas & UX |
| Mock vault share balances | MockERC4626 | Demo NAV — not real DeFi |

**Reconciliation rule:** if Mongo and chain disagree, **chain wins**. UI surfaces both (live reads + indexed cache) so reviewers can spot lag.

---

## 5. Write / read paths

```text
Write:  UI → wallet → Fuji tx → event log
Read:   UI → Backend → Mongo          (fast list/search)
        UI → wagmi eth_call           (money / progress / policy)
Audit:  Snowtrace + /transparency + campaign finance export
```

Indexer settings (typical): chunked `eth_getLogs`, confirmations depth (default **3**), poll interval ~15s. Sync status is exposed on health/transparency payloads (`chainId`, `asOfBlock`, `syncStatus`).

---

## 6. Frontend information architecture

| Route | Audience | Wallet? |
|---|---|---|
| `/` | Everyone | No |
| `/campaigns`, `/campaigns/[id]` | Donors / orgs | Optional / for actions |
| `/transparency` | Public auditors | No |
| `/yield` | Orgs / operators (USDC) | For writes |
| `/governance` | Donors | For voting |
| `/dashboard` | Connected user | Yes |
| `/admin` | Admin / verifier roles | Yes |
| `/expenses/[requestId]` | Public | No |

---

## 7. Security boundaries (summary)

- Value leaving escrow to a **non-donor** address requires DAO approval **and** Safe execution **and** a registered request.  
- Yield moves are **internal** (liquid ↔ vault) and cannot pay third parties.  
- Refunds are **pull** (`claimRefund`) for Failed/Cancelled campaigns.  
- Full caveats: [security-limitations.md](./security-limitations.md)

---

## Related

- [transparent-accounting.md](./transparent-accounting.md)  
- [fuji-deployment.md](./fuji-deployment.md)  
- [hosting.md](./hosting.md)  
- [adr/](./adr/)
