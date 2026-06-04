# TranspaChain — Roadmap Phase 2 (P0–P2)

Extension after the original 4-week plan. **Contract redeploy** is deferred until after UI/backend/demo work; see [deploy.md](./deploy.md#redeploy-contract-sepolia-tùy-chọn).

## P0 — Demo trust (implemented in repo)

- [x] Indexer: `$inc raisedAmount` on donations; `DeadlineExtended`, `CampaignStatusChanged`
- [x] UI: `EscrowTransparencyCard`, `CampaignStatusTimeline`, `OrgCampaignActions` (extend, cancel, finalize, submit proof)
- [x] DAO link from `VotingPanel`; quorum % from on-chain `totalVotingPower`
- [x] Socket: `campaignUpdated`, `deadlineExtended`, etc.
- [ ] **Redeploy Sepolia** — NFT tier on repeat donate (`63300f6` bytecode)

## P1 — Product & trust

- [x] `/governance` hub + `GET /proposals`
- [x] `OrgProfile` Mongo + forms (dashboard submit, admin review)
- [ ] Granular admin on Vault (`Pausable`, role-based treasury) — **needs redeploy**
- [ ] `resubmitProposal` UI after defeated vote

## P2 — Polish

- [x] Dicebear identicon avatars
- [x] Framer motion on new panels
- [ ] Soulbound NFT / on-chain SVG — **needs redeploy**
- [ ] Slither in CI (see [security-audit.md](./security-audit.md))

## Demo scenarios (6 flows)

Documented in [demo-script.md](./demo-script.md):

1. ETH donate + NFT  
2. USDC approve + donate  
3. Milestone pass (proof → vote → queue → execute)  
4. Milestone fail / resubmit  
5. Refund (failed campaign)  
6. Cancel (zero donors)

## Backend surface

| Route | Purpose |
|-------|---------|
| `GET /proposals` | DAO hub |
| `POST /orgs` | Org profile submit |
| `GET /admin/org-profiles` | Verifier queue |
| `PATCH /admin/org-profiles/:address` | Approve/reject off-chain |

## EC2 after pull

```bash
cd ~/transpachain && git pull && git submodule update --init --recursive
set -a && source .env && set +a
docker compose build --no-cache frontend
cd backend && docker build -t cuongnguyen146/transpachain-backend:latest .
cd .. && docker compose up -d --force-recreate frontend backend
```
