# Deploy Frontend qua GHCR (WSL → Registry → EC2)

Luồng deploy ổn định: **build trên WSL**, **push lên GHCR**, **EC2 chỉ pull + chạy** (không build trên server).

| Bước | Máy | Việc làm |
|------|-----|----------|
| Build | WSL | `docker build` + `docker push` |
| Run | EC2 | `docker pull` + `docker compose -f docker-compose.prod.yml up -d` |

Image: `ghcr.io/levianth146/transpachain-frontend:<tag>`

---

## 1. Thiết lập một lần — GitHub PAT (GHCR)

1. GitHub → **Settings → Developer settings → Personal access tokens**
2. Tạo token (classic hoặc fine-grained):
   - **Classic:** scopes `write:packages`, `read:packages`
   - **Fine-grained:** quyền **Packages: Read and write** trên repo `transpachain-frontend`
3. Lưu token an toàn (không commit vào git).

Sau khi push lần đầu, vào package trên GitHub → **Package settings** → đặt visibility **Public** (hoặc cấp quyền cho EC2 user nếu private).

---

## 2. Thiết lập một lần — WSL

```bash
# Đăng nhập GHCR (dùng GitHub username + PAT)
echo YOUR_GITHUB_PAT | docker login ghcr.io -u levianth146 --password-stdin

# Monorepo + .env
cd ~/projects/transpachain   # hoặc đường dẫn clone của bạn
cp .env.example .env
# Điền NEXT_PUBLIC_* (bắt buộc lúc build — xem .env.example)
git submodule update --init --recursive frontend
```

---

## 3. Mỗi lần deploy — Build & push từ WSL

```bash
cd ~/transpachain
git pull && git submodule update --init --recursive frontend

# Tag mặc định = git short SHA
./scripts/deploy-frontend-wsl.sh

# Hoặc tag tùy chọn
./scripts/deploy-frontend-wsl.sh v1.2.0
```

Script sẽ:
- Sync submodule `frontend`
- Build với `NEXT_PUBLIC_*` từ `.env`
- Push `ghcr.io/levianth146/transpachain-frontend:<tag>` và `:latest`
- In lệnh EC2 cần chạy

**Lưu ý:** `NEXT_PUBLIC_*` được bake vào JS lúc build — đổi contract/key phải build lại.

---

## 4. Thiết lập một lần — EC2

```bash
ssh ubuntu@YOUR_EC2

cd ~/transpachain
git pull
git submodule update --init --recursive

# Đăng nhập GHCR (PAT cần read:packages)
echo YOUR_GITHUB_PAT | docker login ghcr.io -u levianth146 --password-stdin

# Hoặc lưu token trong ~/.bashrc (không commit):
# export GHCR_TOKEN=ghp_...
```

File `.env` ở root monorepo (backend, CORS, v.v.) — xem `.env.example`.

---

## 5. Mỗi lần deploy — Pull trên EC2

Sau khi WSL push xong:

```bash
cd ~/transpachain
git pull   # lấy docker-compose.prod.yml + scripts mới nhất

# Thay abc1234 bằng tag vừa push (script WSL in ra)
FRONTEND_TAG=abc1234 ./scripts/deploy-frontend-ec2.sh
```

Hoặc thủ công:

```bash
export FRONTEND_TAG=abc1234
docker pull ghcr.io/levianth146/transpachain-frontend:${FRONTEND_TAG}
docker compose -f docker-compose.prod.yml up -d --force-recreate frontend nginx
```

EC2 **không** chạy `docker compose build frontend`.

---

## 6. Rollback theo tag

```bash
# Xem tag đã push (trên WSL hoặc GitHub Packages)
docker pull ghcr.io/levianth146/transpachain-frontend:OLD_TAG

# EC2
FRONTEND_TAG=OLD_TAG ./scripts/deploy-frontend-ec2.sh
```

---

## 7. CI/CD thay thế (GitHub Actions)

Repo `transpachain-frontend` có workflow `.github/workflows/build-push-frontend.yml`:
- Push lên `main` → build + push GHCR tự động
- Cần secrets repo: `NEXT_PUBLIC_ALCHEMY_KEY`, `NEXT_PUBLIC_CHARITY_CORE_ADDRESS`, … (giống monorepo CI)

Sau CI, EC2 vẫn chỉ cần:

```bash
FRONTEND_TAG=<full-git-sha> ./scripts/deploy-frontend-ec2.sh
# hoặc FRONTEND_TAG=latest
```

---

## 8. Dev local (không đổi)

`docker-compose.yml` vẫn dùng `build:` cho frontend khi dev:

```bash
make docker-build-frontend
docker compose up -d
```

Production EC2 dùng `docker-compose.prod.yml` (image GHCR, không build).

---

## 9. Kiểm tra sau deploy

```bash
curl -I https://transpachain.site/logo.svg
curl -s https://transpachain.site/api/health
docker compose -f docker-compose.prod.yml logs frontend --tail 30
```

See also: [deploy.md](./deploy.md) (backend, nginx, indexer).
