# Hosting — Atlas → Render → Vercel

Order matters: database first, then API (needs Mongo + RPC), then frontend (needs public API URL + contract addresses).

Replace placeholders after each service is live. Do **not** commit real connection strings, API keys, or private keys.

| Service | Placeholder |
|---|---|
| Frontend | `YOUR_VERCEL_URL` |
| Backend | `YOUR_RENDER_URL` |

---

## 1. MongoDB Atlas (M0)

1. Create a free **M0** cluster.
2. Database user + Network Access (allow Render egress IPs, or `0.0.0.0/0` for hackathon demo with strong password).
3. Create / use database name: **`transpachain-fuji-v2`** (separate from any v1 DB).
4. Connection string form:

```text
mongodb+srv://USER:PASS@CLUSTER.mongodb.net/transpachain-fuji-v2?retryWrites=true&w=majority
```

Store as `MONGODB_URI` on Render only.

---

## 2. Render — backend (Docker)

- **Root / repo:** backend submodule (`transpachain-backend`)
- **Dockerfile:** `backend/Dockerfile` (Node 20 multi-stage → `npm run start` on port `3001`)
- **Health check path:** `/health`

### Env list (Render)

```text
PORT=3001
MONGODB_URI=mongodb+srv://.../transpachain-fuji-v2?...
CHAIN_NAME=avalanche-fuji
CHAIN_ID=43113
RPC_URL=https://avalanche-fuji-c-chain-rpc.publicnode.com
RPC_FALLBACK_URL=https://api.avax-test.network/ext/bc/C/rpc
HEALTH_CHECK_TIMEOUT_MS=8000

CHARITY_CORE_ADDRESS=0xFc71b91e360DB771F81aD3594023Be35D85C613b
DONATION_VAULT_ADDRESS=0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b
GOVERNANCE_DAO_ADDRESS=0xC8f15c5eE83998897615b851a03f044712b0e016
IMPACT_NFT_ADDRESS=0x0fA0613bD0Ef0520851f1F515C894D7D80Df2210
DISBURSEMENT_CONTROLLER_ADDRESS=0xb61c688D64564960958181Dfc5cD4164730125E6
YIELD_MANAGER_ADDRESS=0x64b5B7e14000FFAF68f84f11Ec4685812eC9deF9
MOCK_ERC4626_VAULT_ADDRESS=0xDefbf3f47c1e15bb4A875daADbB469Fa115bC75A
SAFE_ADDRESS=0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A
DISBURSEMENT_SAFE=0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A
DEPLOY_FROM_BLOCK=61364951
CONTRACT_DEPLOY_BLOCK=61364951

INDEXER_LOG_CHUNK_SIZE=2000
INDEXER_CHUNK_DELAY_MS=100
INDEXER_POLL_INTERVAL_MS=15000
INDEXER_CONFIRMATIONS=3

PINATA_API_KEY=...
PINATA_SECRET_KEY=...
CORS_ORIGIN=https://YOUR_VERCEL_URL
```

Notes:

- Set `CORS_ORIGIN` to the exact Vercel origin (scheme + host, no trailing slash mismatch).
- After first Vercel URL is known, update `CORS_ORIGIN` and redeploy backend if needed.
- Confirm `/health` reports `chainId: 43113` and indexer is advancing past `61364951`.

---

## 3. Vercel — frontend

- **Root Directory:** `frontend` (or the frontend submodule root in a monorepo import)
- **Framework:** Next.js
- **Build:** default `next build`

### Env list (all `NEXT_PUBLIC_*`)

```text
NEXT_PUBLIC_CHAIN_ID=43113
NEXT_PUBLIC_RPC_URL=
NEXT_PUBLIC_CHARITY_CORE_ADDRESS=0xFc71b91e360DB771F81aD3594023Be35D85C613b
NEXT_PUBLIC_DONATION_VAULT_ADDRESS=0x671bE113Cd8C1981D19910Bea2718aa73DC83D5b
NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS=0xC8f15c5eE83998897615b851a03f044712b0e016
NEXT_PUBLIC_IMPACT_NFT_ADDRESS=0x0fA0613bD0Ef0520851f1F515C894D7D80Df2210
NEXT_PUBLIC_USDC_ADDRESS=0x5425890298aed601595a70AB815c96711a31Bc65
NEXT_PUBLIC_DISBURSEMENT_CONTROLLER_ADDRESS=0xb61c688D64564960958181Dfc5cD4164730125E6
NEXT_PUBLIC_YIELD_MANAGER_ADDRESS=0x64b5B7e14000FFAF68f84f11Ec4685812eC9deF9
NEXT_PUBLIC_DISBURSEMENT_SAFE=0xf2dD6eF266E9775a9fC9Cf934b3bC2680076737A
NEXT_PUBLIC_BACKEND_URL=https://YOUR_RENDER_URL
```

`NEXT_PUBLIC_*` values are baked at build time — change address/URL → **redeploy**.

Optional: leave `NEXT_PUBLIC_RPC_URL` empty to use the app’s Fuji defaults + PublicNode fallback.

---

## Checklist (strict order)

1. [ ] Atlas M0 up · DB name `transpachain-fuji-v2` · URI copied
2. [ ] Render Docker service · env set · `/health` OK · indexer syncing
3. [ ] Note `YOUR_RENDER_URL`
4. [ ] Vercel project · root `frontend` · all `NEXT_PUBLIC_*` set · `NEXT_PUBLIC_BACKEND_URL` = Render
5. [ ] Note `YOUR_VERCEL_URL`
6. [ ] Update Render `CORS_ORIGIN` → Vercel origin · redeploy if needed
7. [ ] Smoke: connect MetaMask Fuji · load campaigns · `/transparency` returns data
8. [ ] Paste both URLs into README / pitch (replace placeholders)

---

## Local vs hosted

| Concern | Local | Hosted |
|---|---|---|
| Mongo | Docker `localhost:27017/transpachain-fuji-v2` | Atlas M0 |
| Backend | `npm run dev` `:3001` | Render Docker |
| Frontend | `npm run dev` `:3000` | Vercel |
| CORS | `http://localhost:3000` | `https://YOUR_VERCEL_URL` |

---

## Related

- [fuji-deployment.md](./fuji-deployment.md)
- [demo-topic5.md](./demo-topic5.md)
- [security-limitations.md](./security-limitations.md)
