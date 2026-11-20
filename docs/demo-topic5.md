# Demo checklist — Topic 5 G4 (E2E on Fuji V2)

Fill every **Tx hash** and **Snowtrace URL** during the live run.  
Network: Avalanche Fuji (`43113`). Manifest: `contracts/deployments/43113.json` → `deployments.v2` (block `61364951`).  
Timelock on this deploy: **120 seconds**. Voting window: **300 seconds**.

---

## Roles & wallets

| Role | Responsibility | Notes |
|---|---|---|
| **Org** | Verify org, create campaigns, submit proof, `requestDisbursement` | Needs Fuji AVAX for gas; verified at deploy if `DEMO_ORG_ADDRESS` was set |
| **Donor 1** | Donate to both campaigns; vote For | Needs AVAX + Circle USDC (`0x5425…Bc65`) |
| **Donor 2** | Second donation; helps quorum | Same as Donor 1 |
| **Safe owners (5)** | Sign disbursement EIP-712 in UI (threshold **3/5**) | Off-chain signatures — owners need **no gas**; executor pays gas |
| **Executor** | `executeDisbursement` / `simulateYield` / allocate | Usually deployer or org wallet with AVAX |

### Wallet tips

- Use separate MetaMask profiles (or accounts) for Org / Donor1 / Donor2 / Safe owners to avoid wrong-signer mistakes.
- Always confirm network badge: **Avalanche Fuji**. Wrong-network → use in-app “Switch to Avalanche Fuji”.
- Disable Dark Reader (and similar) extensions for the recording — they break hydration visuals.
- After any `NEXT_PUBLIC_*` change, restart `npm run dev` / redeploy Vercel.
- USDC campaigns need ERC-20 `approve` before donate; AVAX campaigns send native value.

### Demo honesty (say this once in the video)

1. **Hash ≠ delivery proof** — SHA-256/CID proves a file was committed, not that goods were delivered.
2. **Mock Yield badge** — `MockERC4626Vault.simulateYield` is testnet-only; not real yield.
3. **Team-held 5 MetaMask keys** — Safe owners for this hackathon demo are controlled by the team so judges can complete 3/5 signing live. Production would use independent custodians.

---

## Preflight

- [ ] Frontend: `YOUR_VERCEL_URL` or `http://localhost:3000`
- [ ] Backend health: `YOUR_RENDER_URL/health` or `http://localhost:3001/health` → `chainId: 43113`, DB `transpachain-fuji-v2`
- [ ] Vault on Snowtrace: https://testnet.snowtrace.io/address/0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b
- [ ] Safe: https://testnet.snowtrace.io/address/0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A

---

## 1. Verify org

- Wallet: **Org**
- Action: complete org verification / confirm org is verified on CharityCore
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

---

## 2. Create campaigns

### 2a. USDC campaign (yield **on**)

- Wallet: **Org**
- Asset: Circle USDC · yield opt-in enabled
- Campaign id: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### 2b. AVAX campaign (native)

- Wallet: **Org**
- Asset: AVAX · no yield path
- Campaign id: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

---

## 3. Donate from 2 donors

### Donor 1 → USDC campaign

- Amount: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### Donor 2 → USDC campaign

- Amount: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### Donor 1 → AVAX campaign (optional for dual-asset story)

- Amount: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### Donor 2 → AVAX campaign (optional)

- Amount: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

---

## 4. Allocate idle USDC (YieldManager)

- Wallet: permissioned allocator (org/admin per UI)
- Action: allocate idle USDC from vault → Mock ERC-4626 via YieldManager
- Tx hash: `________________________________`
- Snowtrace: `________________________________`
- UI: confirm **Mock Yield** badge visible

---

## 5. `simulateYield` on MockERC4626

- Wallet: yield controller / deployer
- Action: call `simulateYield` (or UI helper) so share value increases
- Tx hash: `________________________________`
- Snowtrace: `________________________________`
- Note aloud: mock only — not production DeFi

---

## 6. Submit milestone proof

- Wallet: **Org**
- Campaign: USDC (preferred for full Module A+C path)
- Milestone index: `________`
- IPFS CID: `________________________________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

---

## 7. Vote For (quorum)

- Wallet: **Donor 1** — Vote For  
  - Tx hash: `________________________________`  
  - Snowtrace: `________________________________`
- Wallet: **Donor 2** — Vote For (if needed for quorum)  
  - Tx hash: `________________________________`  
  - Snowtrace: `________________________________`
- Proposal id: `________`
- Wait until voting window ends (≤ **300s** on this deploy) or advance if already past `endTime`

---

## 8. Queue + wait timelock

- Action: queue proposal (if separate step in UI) then **wait 120s**
- Queue tx (if any): `________________________________`
- Snowtrace: `________________________________`
- Timelock ends at (local time): `________`

---

## 9. Execute proposal (approve only)

- Action: DAO `execute` → `approveMilestone` (**no token transfer**)
- Tx hash: `________________________________`
- Snowtrace: `________________________________`
- Confirm: milestone approved; funds still in vault / controller pending path

---

## 10. Org `requestDisbursement` + receipt SHA-256 / CID

- Wallet: **Org**
- Upload receipt file → UI computes SHA-256 → pin CID
- `receiptHash` (bytes32): `________________________________`
- `receiptCid`: `________________________________`
- `requestId`: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

---

## 11. Three Safe owners sign in UI

- Owners 1–3 (of 5) connect and sign EIP-712 Safe tx (no gas for signers)
- Owner A address: `________________________________` · signed: [ ]
- Owner B address: `________________________________` · signed: [ ]
- Owner C address: `________________________________` · signed: [ ]
- Backend sig count ≥ 3: [ ]

---

## 12. `executeDisbursement`

- Wallet: **Executor** (pays gas)
- Tx hash: `________________________________`
- Snowtrace: `________________________________`
- Confirm `FundsReleased` / `DisbursementExecuted` indexed

---

## 13. Public ledger views + CSV

- [ ] `/expenses/[requestId]` shows amount, recipient, receipt CID, SHA-256, verify-my-file
  - URL: `YOUR_VERCEL_URL/expenses/________`
- [ ] `/transparency` shows platform totals / recent expenses
  - URL: `YOUR_VERCEL_URL/transparency`
- [ ] Campaign finance CSV download works
  - File saved as: `________________________________`
- Say aloud: **hash ≠ delivery proof**

---

## 14. Cancel second campaign → settle yield → claim refunds

Use the **second** campaign (prefer USDC-with-yield if both donated; else the unused one).

### Cancel

- Wallet: **Org** (or permitted canceller)
- Campaign id: `________`
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### `settleYieldForRefund`

- Permissionless / org — redeems mock vault into escrow before claims
- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### `claimRefunds` (Donor 1)

- Tx hash: `________________________________`
- Snowtrace: `________________________________`

### `claimRefunds` (Donor 2)

- Tx hash: `________________________________`
- Snowtrace: `________________________________`

---

## Post-demo capture

| Artifact | Link / path |
|---|---|
| Demo video (2–3 min) | `________________________________` |
| Pitch slides | `________________________________` |
| This checklist (filled) | commit or attach to submission |
| Vault Snowtrace | https://testnet.snowtrace.io/address/0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b |

---

## Related docs

- [fuji-deployment.md](./fuji-deployment.md)
- [hosting.md](./hosting.md)
- [transparent-accounting.md](./transparent-accounting.md)
- [security-limitations.md](./security-limitations.md)
