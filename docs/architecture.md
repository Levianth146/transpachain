# TranspaChain — Architecture Analysis

## On-chain vs Off-chain

| Data | Location | Reason |
|---|---|---|
| Campaign ID, org, goal, deadline | CharityCore (on-chain) | Core state — must be trustless |
| Donation amounts per donor | DonationVault (on-chain) | Financial — must be immutable |
| Escrow balances | DonationVault (on-chain) | Fund management |
| Milestone proof CID | DonationVault (on-chain) | IPFS hash for verification |
| Vote results & quorum | GovernanceDAO (on-chain) | Governance must be transparent |
| NFT ownership | ImpactNFT (on-chain) | ERC-721 standard |
| Campaign title, description | MongoDB (off-chain) | Large text, gas expensive |
| Media files | IPFS via Pinata (off-chain) | Too large for on-chain |
| Event cache / tx history | MongoDB (off-chain) | Fast queries, UX |
| Full-text search index | MongoDB (off-chain) | Chain doesn't support this |

## Contract Relationships

```
CharityCore ──── campaign lifecycle ──►  DonationVault
                                              │
                                         proposalId ──► GovernanceDAO
                                                              │
                                                        execute ──► DonationVault.releaseFunds()
                                                                         │
DonationVault ──── mint trigger ──►  ImpactNFT
```

## Data Flow

```
User Action (Frontend)
     │
     ├── Read  → Backend REST API (MongoDB) → fast, free
     └── Write → wagmi → MetaMask sign → Sepolia broadcast
                                               │
                                        Event emitted on-chain
                                               │
                                   Backend indexer (ethers.js) catches
                                               │
                                     Update MongoDB cache
                                               │
                                   Socket.io push to frontend
```
