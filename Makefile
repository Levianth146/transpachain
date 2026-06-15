.PHONY: help contracts-test contracts-deploy backend-dev frontend-dev docker-up docker-build-frontend lint

help:
	@echo "TranspaChain monorepo targets"
	@echo "  make contracts-test          - forge test (contracts submodule)"
	@echo "  make contracts-deploy        - hardhat deploy sepolia"
	@echo "  make backend-dev             - npm run dev in backend"
	@echo "  make frontend-dev            - npm run dev in frontend"
	@echo "  make docker-up               - docker compose up -d"
	@echo "  make docker-build-frontend   - build frontend image with .env build-args"
	@echo "  make lint                    - frontend lint"

contracts-test:
	cd contracts && forge test

contracts-deploy:
	cd contracts && npx hardhat run hardhat/scripts/deploy.ts --network sepolia

backend-dev:
	cd backend && npm run dev

frontend-dev:
	cd frontend && npm run dev

docker-up:
	docker compose up -d

docker-build-frontend:
	@test -f .env || (echo "Create .env from .env.example" && exit 1)
	set -a && . ./.env && set +a && \
	cd frontend && docker build \
	  --build-arg NEXT_PUBLIC_ALCHEMY_KEY="$$NEXT_PUBLIC_ALCHEMY_KEY" \
	  --build-arg NEXT_PUBLIC_CHARITY_CORE_ADDRESS="$$NEXT_PUBLIC_CHARITY_CORE_ADDRESS" \
	  --build-arg NEXT_PUBLIC_DONATION_VAULT_ADDRESS="$$NEXT_PUBLIC_DONATION_VAULT_ADDRESS" \
	  --build-arg NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS="$$NEXT_PUBLIC_GOVERNANCE_DAO_ADDRESS" \
	  --build-arg NEXT_PUBLIC_IMPACT_NFT_ADDRESS="$$NEXT_PUBLIC_IMPACT_NFT_ADDRESS" \
	  --build-arg NEXT_PUBLIC_USDC_ADDRESS="$$NEXT_PUBLIC_USDC_ADDRESS" \
	  -t cuongnguyen146/transpachain-frontend:latest .

lint:
	cd frontend && npm run lint
