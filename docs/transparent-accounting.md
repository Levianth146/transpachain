# Transparent accounting (Module B)

TranspaChain indexes on-chain events into an append-only **ledger** (Mongo) and exposes public read APIs so anyone can reconcile donations, expenses, refunds, and mock yield — without trusting a private spreadsheet.

Product entry points: [`/transparency`](https://www.transpachain.site/transparency) · campaign finance / expenses tabs · [`/expenses/[requestId]`](https://www.transpachain.site).

---

## Ledger classifications

| Classification | Money movement? | Meaning |
|---|---|---|
| `DONATION` | Inflow (gross / fee / net) | Donor deposit into campaign escrow |
| `PLATFORM_FEE` | Treasury (outside escrow) | Protocol fee skim (default 1%) |
| `EXPENSE_REQUESTED` | No | Disbursement requested (permission + receipt commitment) |
| `MILESTONE_APPROVED` | No | DAO approved milestone (approve-only) |
| `EXPENSE_PAID` | Outflow | Funds released via Safe execution |
| `REFUND_PAID` | Outflow | Donor claimed refund after fail/cancel |
| `YIELD_ALLOCATE` | Internal | Liquid escrow → mock ERC-4626 |
| `YIELD_REDEEM` | Internal | Vault → liquid escrow |
| `YIELD_VALUATION` | Non-cash | Valuation / P&L marker when emitted |

**Idempotency key:** `(chainId, txHash, logIndex)`.

Expense totals prefer `FundsReleased` when both `FundsReleased` and `DisbursementExecuted` exist for the same payout (avoid double-count).

---

## Identity equation (per campaign)

```text
net donations − expenses paid − refunds  ± realized P&L  ± unrealized P&L
    = NAV (liquid escrow + vault share value)
```

API proxy commonly used for dashboards:

```text
navProxy ≈ netDonations − expensesPaid − refundsPaid
```

Yield allocate/redeem are **internal** bucket moves — never treat them as expenses. Donor balances, voting power, NFT tier, and “raised” semantics stay tied to **donations**, not yield.

---

## Public APIs

Mounted under `/api` (frontend helpers in `frontend/lib/api.ts`):

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/transparency/summary` | Platform totals + recent paid expenses |
| `GET` | `/api/campaigns/:id/ledger` | Cursor-paginated ledger rows |
| `GET` | `/api/campaigns/:id/expenses` | Expense requests for a campaign |
| `GET` | `/api/campaigns/:id/finance` | Summary / CSV reconciliation |
| `GET` | `/api/expenses/:requestId` | Single public expense + receipt fields |

Responses should include sync metadata (`chainId`, `asOfBlock`, sync status) so clients know indexer freshness.

---

## Hash disclaimer

**On-chain `receiptHash` (SHA-256) + IPFS CID prove a specific file was committed at request time.**  
They do **not** prove physical delivery, beneficiary receipt, or impact quality. Treat them as integrity commitments — not delivery oracles. The UI must say this clearly.

---

## Related

- [architecture.md](./architecture.md)  
- [security-limitations.md](./security-limitations.md)  
- [adr/0003-yield-refund-accounting.md](./adr/0003-yield-refund-accounting.md)  
- [demo-topic5.md](./demo-topic5.md)
