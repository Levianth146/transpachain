# Donate Flow

## ETH donation

```mermaid
sequenceDiagram
    actor Donor
    participant Frontend
    participant DonationVault
    participant ImpactNFT
    participant Indexer
    participant MongoDB

    Donor->>Frontend: enter amount (ETH)
    Frontend->>DonationVault: donate(campaignId) + value
    Frontend->>Donor: sign tx (MetaMask)
    DonationVault->>DonationVault: lock net ETH in escrow
    alt first donation to campaign
        DonationVault->>ImpactNFT: mintImpactNFT
    else repeat donation
        DonationVault->>ImpactNFT: addDonationAmount + upgradeTier
    end
    DonationVault->>Indexer: emit DonationReceived
    Indexer->>MongoDB: save donation
    DonationVault-->>Frontend: tx confirmed
    Frontend-->>Donor: toast Confirmed + NFT note
```

## USDC donation

```mermaid
sequenceDiagram
    actor Donor
    participant Frontend
    participant USDC as USDC ERC20
    participant DonationVault
    participant ImpactNFT

    Donor->>Frontend: enter amount (USDC)
    Frontend->>USDC: approve(Vault, amount)
    Donor->>Frontend: sign approve
    Frontend->>DonationVault: donateUSDC(campaignId, amount)
    Donor->>Frontend: sign donate
    DonationVault->>USDC: transferFrom donor
    DonationVault->>DonationVault: escrow += net USDC
    DonationVault->>ImpactNFT: mint or addDonationAmount
    DonationVault-->>Frontend: confirmed
```

Requires campaign `paymentToken = USDC` and `NEXT_PUBLIC_USDC_ADDRESS` on frontend.

## Refund flow

```mermaid
sequenceDiagram
    actor Donor
    participant Frontend
    participant DonationVault

    Frontend->>DonationVault: canRefund(campaignId, donor)
    DonationVault-->>Frontend: eligible, amount
    Donor->>Frontend: Claim refund
    Frontend->>DonationVault: claimRefund(campaignId)
    DonationVault->>Donor: ETH or USDC transfer
```

Eligible when campaign **Failed** or past **deadline** (see `canRefund`), with proportional adjustment if milestones partially released.
