# Transparent accounting (Module B)

TranspaChain 2.0 indexes on-chain events into an append-only **ledger** (Mongo) and exposes public read APIs so anyone can reconcile donations, expenses, refunds, and mock yield without trusting a private spreadsheet.

---

## Ledger classifications

| Classification | Money movement? | Meaning |
|---|---|---|
| `DONATION` | inflow (gross / fee / net fields) | Donor deposit into campaign escrow |
| `PLATFORM_FEE` | treasury (outside escrow) | Protocol fee skim |
| `EXPENSE_REQUESTED` | no | Disbursement requested (permission + receipt commitment) |
| `MILESTONE_APPROVED` | no | DAO approved milestone (approve-only) |
| `EXPENSE_PAID` | outflow | Funds released to recipient via Safe execution |
| `REFUND_PAID` | outflow | Donor claimed refund after fail/cancel |
| `YIELD_ALLOCATE` | internal | Liquid escrow → mock ERC-4626 (NAV composition changes, not spend) |
| `YIELD_REDEEM` | internal | Vault → liquid escrow |
| `YIELD_VALUATION` | non-cash | Valuation / P&L marker when emitted |

Idempotency key: `(chainId, txHash, logIndex)`.

Expense totals prefer `FundsReleased` when both `FundsReleased` and `DisbursementExecuted` exist for the same payout (avoid double-count).

---

## Identity equation (per campaign)

```
net donations − expenses paid − refunds  ± realized P&L  ± unrealized P&L
    = NAV (liquid escrow + vault share value)
```

Practical proxy used in API totals:

```
navProxy ≈ netDonations − expensesPaid − refundsPaid
```

Yield allocate/redeem are internal transfers between liquid and invested buckets; they must not be treated as expenses. Donor balances, voting power, NFT tier, and “raised” semantics stay tied to donation weights — yield does not mint fake donation credit.

---

## Public APIs (backend)

Mounted under `/api` (see frontend `lib/api.ts` Module B helpers):

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/transparency/summary` | Platform-level totals + recent paid expenses |
| `GET` | `/api/campaigns/:id/ledger` | Cursor-paginated ledger rows |
| `GET` | `/api/campaigns/:id/expenses` | Expense requests for a campaign |
| `GET` | `/api/campaigns/:id/finance` (CSV / summary) | Downloadable reconciliation |
| `GET` | `/api/expenses/:requestId` | Single public expense + receipt fields |

Every Module B response should carry sync metadata (`chainId`, `asOfBlock`, sync status) so consumers know indexer freshness.

Frontend surfaces:

- `/transparency` — platform public ledger
- `/expenses/[requestId]` — receipt CID, SHA-256, client-side “verify my file”
- Campaign tabs — ledger / expenses / yield badges

---

## Hash disclaimer

**On-chain `receiptHash` (SHA-256) + IPFS CID prove that a specific file was committed at request time.**  
They do **not** prove physical delivery, beneficiary receipt, or impact quality. Treat them as integrity commitments for transparency — not as delivery oracles.

---

## Related

- [demo-topic5.md](./demo-topic5.md) steps 13–14
- [adr/0003-yield-refund-accounting.md](./adr/0003-yield-refund-accounting.md)
- [security-limitations.md](./security-limitations.md)
