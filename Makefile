.PHONY: help ps images build start stop restart fresh destroy prod logs \
migrate migrate-fresh seed migrate-seed migrate-fresh-seed optimize-clear tinker artisan composer \
install-xdebug npm-install npm-build npm-dev npm-prod env

SERVICE_PHP=app
SERVICE_NODE=node

help: ## Print help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

ps: ## Show containers.
	@docker compose ps

images: ## Show images.
	@docker compose images

build: env ## Build all containers.
	@docker compose build --no-cache

start: env ## Start all containers.
	@docker compose up --force-recreate -d

stop: env ## Stop all containers.
	@docker compose down

restart: stop start ## Restart all containers.

destroy: env stop ## Remove all containers with images and volumes.
	@docker compose down --rmi all --volumes --remove-orphans

fresh: stop destroy build start ## Destroy & recreate all containers.

prod: ## Start all containers for production.
	@docker compose -f docker-compose.prod.yml up --force-recreate -d

logs: ## View logs of a running container
	@docker compose logs $(filter-out $@,$(MAKECMDGOALS))

migrate: ## Run migration files.
	docker compose exec ${SERVICE_PHP} php artisan migrate

seed: ## Seed database.
	docker compose exec ${SERVICE_PHP} php artisan db:seed

migrate-fresh: ## Clear database and run all migrations.
	docker compose exec ${SERVICE_PHP} php artisan migrate:fresh

migrate-seed: ## Run migration files and seed database.
	docker compose exec ${SERVICE_PHP} php artisan migrate --seed

migrate-fresh-seed: ## Clear database, run all migrations and seed database.
	docker compose exec ${SERVICE_PHP} php artisan migrate:fresh --seed

optimize-clear: ## Clear all caches.
	docker compose exec ${SERVICE_PHP} php artisan optimize:clear

tinker: ## Launch tinker cli
	docker compose exec ${SERVICE_PHP} php artisan tinker

artisan: ## Run an artisan command
	@docker compose exec ${SERVICE_PHP} php artisan $(filter-out $@,$(MAKECMDGOALS))

dump-autoload: ## Dump composer autoload files.
	docker compose exec ${SERVICE_PHP} composer dump -o

composer: ## Run a composer command
	@docker compose exec ${SERVICE_PHP} composer $(filter-out $@,$(MAKECMDGOALS))

npm-install: ## Install node dependencies.
	docker compose exec ${SERVICE_NODE} npm install

npm-dev: ## Compile and watch changes for development.
	docker compose exec ${SERVICE_NODE} npm run dev

npm-build: ## Build node assets.
	docker compose exec ${SERVICE_NODE} npm run build

npm-prod: npm-install npm-build ## Install and build node assets for production.

install-xdebug: ## Install xdebug locally.
	@docker compose exec ${SERVICE_PHP} pecl install xdebug \
	@docker compose exec ${SERVICE_PHP} /usr/local/bin/docker-php-ext-enable xdebug.so

env: ## Create .env from .env.example
	@if [ ! -f ".env" ]; then \
		echo "Creating .env file."; \
		cp .env.example .env; \
	fi

%:
	@:
