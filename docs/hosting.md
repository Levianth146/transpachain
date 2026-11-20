# Hosting guide — Atlas → Render → Vercel → Domain

Order matters: **database → API → frontend → CORS/domain**.  
Never commit real connection strings, API keys, or private keys.

| Service | Production role | Typical URL |
|---|---|---|
| MongoDB Atlas | Ledger / campaign cache | (private URI) |
| Render | Backend + indexer | `https://YOUR_RENDER_URL` |
| Vercel | Frontend | `https://www.transpachain.site` |
| Namecheap | DNS for `transpachain.site` | apex + `www` |

---

## 1. MongoDB Atlas (M0)

1. Create a free **M0** cluster.  
2. Create a DB user; open Network Access (Render IPs, or `0.0.0.0/0` for a short demo with a strong password).  
3. Database name: **`transpachain-fuji-v2`** (keep separate from any older DB).  
4. Connection string:

```text
mongodb+srv://USER:PASS@CLUSTER.mongodb.net/transpachain-fuji-v2?retryWrites=true&w=majority
```

Store only as `MONGODB_URI` on Render (and local `.env`).

---

## 2. Render — backend (Docker)

- Source: `backend/` (Dockerfile multi-stage, Node 20, port `3001`)  
- Health check: `/health`

### Environment

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
CORS_ORIGIN=https://www.transpachain.site
```

After the frontend URL is final, set `CORS_ORIGIN` to that exact origin (scheme + host, no trailing slash) and redeploy. Confirm `/health` reports `chainId: 43113` and `asOfBlock` past `61364951`.

---

## 3. Vercel — frontend

- Root directory: `frontend`  
- Framework: Next.js · build: `next build`  
- All `NEXT_PUBLIC_*` values are **baked at build time** — change → redeploy.

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

Leave `NEXT_PUBLIC_RPC_URL` empty to use built-in Fuji public RPCs + fallback.

---

## 4. Custom domain — `transpachain.site`

Vercel project domains:

- `transpachain.site` → production  
- `www.transpachain.site` → production (serves the app; preferred if ISP caches apex slowly)

### Namecheap → Advanced DNS

| Type | Host | Value |
|---|---|---|
| **A** | `@` | `216.198.79.1` |
| **A** | `@` | `64.29.17.1` |
| **CNAME** | `www` | `335150b82d8f059e.vercel-dns-017.com.` |

Remove any old A record pointing at AWS / parking IPs (e.g. `54.253.x.x`).

**If apex times out but docs say DNS is “correct”:** public resolvers (`8.8.8.8` / `1.1.1.1`) may already show Vercel IPs while your ISP still caches the old A record. Use **https://www.transpachain.site**, flush DNS (`ipconfig /flushdns` as Admin), or switch the machine DNS to Cloudflare/Google. Verify:

```bash
nslookup transpachain.site 8.8.8.8
```

Expected addresses: `216.198.79.1` and `64.29.17.1`.

Also set Render `CORS_ORIGIN` to `https://www.transpachain.site` (and/or apex) and redeploy the backend.

---

## 5. Go-live checklist

1. [ ] Atlas M0 · DB `transpachain-fuji-v2` · URI ready  
2. [ ] Render Docker · env set · `/health` OK · indexer syncing  
3. [ ] Vercel · all `NEXT_PUBLIC_*` · `NEXT_PUBLIC_BACKEND_URL` = Render  
4. [ ] Render `CORS_ORIGIN` matches the live frontend origin  
5. [ ] Domain DNS as above · smoke https://www.transpachain.site  
6. [ ] MetaMask Fuji · campaigns load · `/transparency` returns data without a wallet  

---

## Local vs hosted

| Concern | Local | Hosted |
|---|---|---|
| Mongo | Docker `localhost:27017/transpachain-fuji-v2` | Atlas M0 |
| Backend | `npm run dev` `:3001` | Render |
| Frontend | `npm run dev` `:3000` | Vercel |
| CORS | `http://localhost:3000` | Live site origin |

---

## Related

- [fuji-deployment.md](./fuji-deployment.md)  
- [architecture.md](./architecture.md)  
- [../README.md](../README.md)
