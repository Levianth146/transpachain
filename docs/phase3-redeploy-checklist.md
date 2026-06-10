# Phase 3 — Redeploy & deploy checklist

## Contracts to redeploy (Sepolia)

### ImpactNFT — tier badge metadata
- `setTierMetadataCID(Bronze|Silver|Gold, ipfsCid)` — 3 JSON metadata files on IPFS
- `mintImpactNFT` / `upgradeTier` use tier URI instead of campaign `metadataCID`
- After deploy: pin metadata via Pinata (see `backend/scripts/` or upload manually)

**Steps after redeploy:**
```bash
# Owner calls on ImpactNFT
setTierMetadataCID(0, "QmBronzeMetadata...")
setTierMetadataCID(1, "QmSilverMetadata...")
setTierMetadataCID(2, "QmGoldMetadata...")
```

Sample metadata JSON:
```json
{
  "name": "TranspaChain Bronze Donor Badge",
  "description": "On-chain proof of impact for campaign donations",
  "image": "https://transpachain.site/nft/bronze.svg"
}
```

### No redeploy required (handled off-chain / FE)
- DAO admin approves proposals before they appear in Governance (`approvalStatus` in Mongo)
- Evidence upload (`/evidence`)
- On-chain checking panel (read contract)
- Tx hash → SepoliaScan
- Web3 hero UI

## Backend deploy
- Rebuild image after pull: Evidence model, admin proposal/evidence routes, proposal `approvalStatus`
- **One-time on EC2** — approve old demo proposals:
```javascript
db.proposals.updateMany({}, { $set: { approvalStatus: "approved" } })
```

## Frontend deploy
- Build on WSL → `docker push` → EC2 `docker pull` (do not build on EC2 with 1GB RAM)

## Demo Q&A

| Question | Answer |
|----------|--------|
| NFT looks bad in wallet? | Redeploy + set tier CIDs; MetaMask needs standard ERC721 metadata |
| 4 campaigns = 4 NFTs? | Yes — 1 badge per campaign; dashboard reads `getDonorNFTs()` |
| Cannot vote on proposal? | Admin must Approve in Admin panel first |
| Where is evidence? | Org upload → admin approval → shown on campaign detail |
