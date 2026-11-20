# Hosting quick checklist (Atlas → Render → Vercel)

See full guide: [hosting.md](./hosting.md).

1. **MongoDB Atlas M0** — create cluster, DB user, network access `0.0.0.0/0` (or Render IPs). DB name: `transpachain-fuji-v2`. Copy `MONGODB_URI`.
2. **Render** — Web Service from `backend` submodule, Docker `Dockerfile`, paste env from `backend/.env.example` (V2 addresses + PublicNode `RPC_URL`). Set `CORS_ORIGIN` after step 3.
3. **Vercel** — Import root repo or `transpachain-frontend`; **Root Directory = `frontend`**; set all `NEXT_PUBLIC_*` from Fuji V2 manifest; `NEXT_PUBLIC_BACKEND_URL` = Render URL.
4. Update Render `CORS_ORIGIN` to the Vercel URL; redeploy backend.
5. Hit `/health` and `/transparency` (no wallet).
