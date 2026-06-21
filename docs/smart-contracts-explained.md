# Smart Contracts Explained (Sepolia Testnet)

## Overview

| Contract | Purpose |
|----------|---------|
| **CharityCore** | Campaign registry, org verification, status lifecycle |
| **DonationVault** | Escrow, donations (ETH/USDC), milestones, refunds |
| **GovernanceDAO** | Donor voting on milestone proofs, timelock execution |
| **ImpactNFT** | ERC-721 donor badges (Bronze / Silver / Gold) |

## Escrow (DonationVault)

- Donations increase `_escrowBalances[campaignId]` and per-donor `_donorBalances`.
- Platform fee (default 1%, max 5%) goes to `treasury` at donate time.
- Funds leave escrow only via `releaseMilestoneFunds` (DAO) or `claimRefund` / `emergencyRefundBatch`.

## Refunds

**`claimRefund(campaignId)`** — pull pattern; donor calls when:

- Campaign status is **Failed**, OR
- `block.timestamp > deadline` (even before finalize in some cases per `canRefund`)

**Proportional refund:** If some milestones were already released, refund amount is scaled by remaining escrow vs total deposited.

**`canRefund(campaignId, donor)`** — view for UI: returns `(eligible, amount, refundDeadline)`.

## USDC campaigns

1. Org creates campaign with `paymentToken = USDC`.
2. Donor `approve(DonationVault, amount)` on Sepolia USDC ERC-20.
3. Donor calls `donateUSDC(campaignId, amount)` (6 decimals).
4. Milestone release and refunds use USDC transfers, not ETH.

Frontend env: `NEXT_PUBLIC_USDC_ADDRESS` (Sepolia USDC).

## Impact NFT

- **One NFT per donor per campaign** (first donation mints).
- **Repeat donations** update `donatedAmount` on NFT metadata and may **upgrade tier** (Bronze → Silver → Gold) via vault calling `upgradeTier`.
- **Transferable** — standard ERC-721; can appear on OpenSea testnet. Souvenir / proof of impact, **not** an investment product.
- Tiers (ETH): Bronze &lt; 0.01 ETH, Silver ≥ 0.01 ETH, Gold ≥ 0.1 ETH. USDC uses 25 / 250 USDC thresholds.

## GovernanceDAO

- Proposals created only by DonationVault when org submits milestone proof.
- **Quadratic voting power** = `sqrt(donation amount)` via `quadraticWeight()` — splitting across wallets does not increase total influence.
- **Quorum** = 51% of total quadratic voting power for the campaign.
- Off-chain **admin approval** required before proposals appear in the public governance hub (`approvalStatus`).
- States: Active → Queued (after vote passes) → Executed (after timelock) or Defeated.
- **Timelock** = 24 hours after queue before execute.

## FAQ (demo answers)

**Q: Where is my money before release?**  
A: In the DonationVault contract escrow for that `campaignId`.

**Q: Can the org take money without donor approval?**  
A: No — release requires passed governance proposal and execute after timelock.

**Q: What if the campaign fails?**  
A: Donors call `claimRefund` for their remaining balance.

**Q: Does the NFT have market value?**  
A: It is a transferable testnet badge; any “value” is speculative and outside project scope.

**Q: Why testnet only?**  
A: Demonstration and education — not production financial infrastructure.

## Key functions (quick reference)

### CharityCore
- `verifyOrg` / `revokeOrg` — verifier only
- `createCampaign` — verified org only, requires creation deposit
- `finalizeCampaign` — after deadline
- `getCampaign`, `isOrgVerified`, `hasRole`

### DonationVault
- `donate`, `donateUSDC`
- `submitMilestoneProof`
- `claimRefund`, `canRefund`
- `releaseMilestoneFunds` — DAO only

### GovernanceDAO
- `castVote(proposalId, choice)` — 0 against, 1 for, 2 abstain
- `queueProposal`, `executeProposal` — admin/trusted flow per deployment

### ImpactNFT
- `mintImpactNFT`, `addDonationAmount`, `upgradeTier`
- `getNFTMetadata`, `hasMintedForCampaign`
