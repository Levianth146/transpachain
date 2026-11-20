# Fuji V2 deployment — create Safe + deploy contracts

**Audience:** developers redeploying or verifying the protocol on Avalanche Fuji.  
**Product overview:** [../README.md](../README.md) · **addresses live today:** see root README contract table.

Active stack: Avalanche Fuji C-Chain (`43113`), deploy block **61364951**.  
Manifest: `contracts/deployments/43113.json` → `deployments.v2`.

---

## What gets deployed

1. **Gnosis Safe 1.4.1 proxy** (3-of-5) via canonical Fuji singletons (`safeCanonical` in the manifest).
2. **V2 contracts:** CharityCore, DonationVault, GovernanceDAO, ImpactNFT, DisbursementController, YieldManager, MockERC4626Vault.
3. **Wiring:** vault ↔ DAO ↔ controller ↔ Safe; vault ↔ YieldManager ↔ MockERC4626; optional demo org verify; governance periods (this deploy: **300s** voting / **120s** timelock).

USDC is **not** deployed — use Circle Fuji USDC: `0x5425890298aed601595a70AB815c96711a31Bc65`.

---

## Prerequisites

- `contracts/.env` filled (never commit secrets)
- Hardhat Fuji network configured
- Five Safe owner EOAs ready (addresses only in `SAFE_OWNERS`)
- Deployer funded with Fuji AVAX

---

## Env vars (`contracts/.env`)

| Variable | Required | Purpose |
|---|---|---|
| `DEPLOYER_PRIVATE_KEY` | yes | Pays gas for Safe create + V2 deploy (**do not paste into docs/git**) |
| `FUJI_RPC_URL` | optional | Defaults to Avalanche public Fuji RPC |
| `SAFE_OWNERS` | yes for create-safe | Exactly **5** comma-separated addresses |
| `SAFE_THRESHOLD` | optional | Default `3` |
| `SAFE_SALT_NONCE` | optional | Deterministic Safe address |
| `PREDICT_ONLY=1` | optional | Print predicted Safe address without broadcast |
| `DISBURSEMENT_SAFE` | yes for deploy-v2 | Address from create-safe output |
| `LOSS_SINK` | yes | Must be `0x000000000000000000000000000000000000dEaD` (script refuses other sinks) |
| `YIELD_CONTROLLER` | optional | MockERC4626 owner (default: deployer) |
| `VOTING_PERIOD_SECONDS` | optional | Demo default often `300` |
| `TIMELOCK_SECONDS` | optional | Demo default often `120` |
| `DEMO_ORG_ADDRESS` | optional | Auto-verify org at deploy |
| `SNOWTRACE_API_KEY` / Routescan key | optional | Contract verification |

---

## Step 1 — Create Safe

```bash
cd contracts
npx hardhat run hardhat/scripts/create-safe.ts --network fuji
```

Script:

- Loads Safe v1.4.1 addresses from `@safe-global/safe-deployments`
- Asserts canonical singletons have code on Fuji
- Creates proxy with 5 owners / threshold 3
- Prints `DISBURSEMENT_SAFE=<address>`

Copy that address into `contracts/.env` as `DISBURSEMENT_SAFE`.

Fallback: create the Safe in Ash Wallet / Safe tooling against `safeCanonical` addresses in the manifest, then set `DISBURSEMENT_SAFE` manually.

---

## Step 2 — Deploy V2

```bash
npx hardhat run hardhat/scripts/deploy-v2.ts --network fuji
```

Order of operations (script):

1. Validate `DISBURSEMENT_SAFE` has code; `LOSS_SINK == dEaD`
2. Deploy core suite + DisbursementController(safe)
3. Deploy MockERC4626Vault(USDC, LOSS_SINK, controller) + YieldManager
4. One-time `setDisbursementController` / `setYieldManager` on vault
5. Set governance periods; optional verify demo org
6. Append / update `deployments/43113.json` under `deployments.v2`
7. Print backend + frontend env blocks

Foundry alternative (advanced): `script/DeployV2.s.sol` — prefer Hardhat path for manifest + verify helpers.

---

## Step 3 — Sanity check

```bash
npx hardhat run hardhat/scripts/check-v2.ts --network fuji
```

Expect: Safe 5 owners / threshold 3, controller.safe, vault↔controller/YM/DAO, LOSS_SINK=dEaD, voting/timelock match manifest.

---

## Manifest path

```
contracts/deployments/43113.json
```

Fields of interest under `deployments.v2`:

- `deployBlock` — indexer `DEPLOY_FROM_BLOCK` / `CONTRACT_DEPLOY_BLOCK`
- `contracts.*` — all V2 addresses
- `safe.address` / `owners` / `threshold`
- `lossSink`, `yieldVault`, `governance`

V1 remains in the file as history only (`deployments.v1`).

---

## Verify on Snowtrace

```bash
# Example pattern — repeat per contract with constructor args from deploy logs
npx hardhat verify --network fuji <ADDRESS> <CTOR_ARGS...>
```

Explorer base: https://testnet.snowtrace.io  
Routescan timeouts happen on Fuji — retry later; unverified source is not a functional blocker for demo.

---

## Indexer / Mongo after deploy

| Setting | Value |
|---|---|
| Primary RPC | `https://avalanche-fuji-c-chain-rpc.publicnode.com` |
| Fallback RPC | `https://api.avax-test.network/ext/bc/C/rpc` |
| Mongo DB name | `transpachain-fuji-v2` (do **not** reuse v1 DB) |
| Start block | `61364951` (or your new `deployBlock`) |
| Log chunk | `INDEXER_LOG_CHUNK_SIZE=2000` (Avalanche public RPC caps ~2048) |

Wire addresses into `backend/.env` and `frontend/.env.local` (see `.env.example` files). Restart both processes after changes.

---

## Live V2 addresses (block 61364951)

| Contract | Address |
|---|---|
| CharityCore | `0xFc71b91e360DB771F81aD3594023Be35D85C613b` |
| DonationVault | `0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b` |
| GovernanceDAO | `0xC8f15c5eE83998897615b851a03f044712b0e016` |
| ImpactNFT | `0x0fA0613bD0Ef0520851f1F515C894D7D80Df2210` |
| DisbursementController | `0xb61c688D64564960958181Dfc5cD4164730125E6` |
| YieldManager | `0x64b5B7e14000FFAF68f84f11Ec4685812eC9deF9` |
| MockERC4626Vault | `0xDefbf3f47c1e15bb4A875daADbB469Fa115bC75A` |
| Safe 3/5 | `0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A` |
| USDC Circle | `0x5425890298aed601595a70AB815c96711a31Bc65` |

---

## Related

- [demo-topic5.md](./demo-topic5.md) — E2E checklist after wiring
- [hosting.md](./hosting.md) — production hosts
- [adr/0001-fuji-v2-redeploy.md](./adr/0001-fuji-v2-redeploy.md)
