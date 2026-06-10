# Phase 3 — Redeploy & deploy checklist

## Cần redeploy contracts (Sepolia)

### ImpactNFT — tier badge metadata
- `setTierMetadataCID(Bronze|Silver|Gold, ipfsCid)` — 3 JSON metadata trên IPFS
- `mintImpactNFT` / `upgradeTier` dùng tier URI thay vì campaign `metadataCID`
- Sau deploy: pin metadata qua Pinata (xem `backend/scripts/` hoặc upload thủ công)

**Bước sau redeploy:**
```bash
# Owner gọi trên ImpactNFT
setTierMetadataCID(0, "QmBronzeMetadata...")
setTierMetadataCID(1, "QmSilverMetadata...")
setTierMetadataCID(2, "QmGoldMetadata...")
```

Metadata JSON mẫu:
```json
{
  "name": "TranspaChain Bronze Donor Badge",
  "description": "On-chain proof of impact for campaign donations",
  "image": "https://transpachain.site/nft/bronze.svg"
}
```

### Không bắt buộc redeploy (đã xử lý off-chain / FE)
- DAO admin duyệt proposal trước khi hiện Governance (`approvalStatus` trong Mongo)
- Minh chứng upload (`/evidence`)
- On-chain checking panel (read contract)
- Tx hash → SepoliaScan
- Web3 hero UI

## Backend deploy
- Rebuild image sau khi pull: Evidence model, admin proposal/evidence routes, proposal `approvalStatus`
- **Một lần trên EC2** — approve proposal demo cũ:
```javascript
db.proposals.updateMany({}, { $set: { approvalStatus: "approved" } })
```

## Frontend deploy
- Build trên WSL → `docker push` → EC2 `docker pull` (không build trên EC2 1GB RAM)

## Demo Q&A

| Câu hỏi | Trả lời |
|----------|---------|
| NFT ví xấu? | Redeploy + set tier CIDs; MetaMask cần metadata chuẩn ERC721 |
| 4 campaign 4 NFT? | Đúng — 1 badge/campaign; dashboard đọc `getDonorNFTs()` |
| Proposal không vote được? | Admin phải Approve trong Admin panel trước |
| Minh chứng ở đâu? | Org upload → admin duyệt → hiện trên campaign detail |
