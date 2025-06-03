# Project Makefile for Tesla Stock Analysis Platform

# Default ports
JUPYTER_PORT=8888
APP_PORT=8050

# Variables
HELM_CHART_DIR=k8s/helm
NAMESPACE=tesla-platform

.PHONY: all notebook app run-all startup clean convert-line-endings install-dos2unix healthcheck detached helm-deploy helm-uninstall test lint format prefect-run status

# Default target
all: run-all

# Build and run Jupyter Notebook container
notebook:
	docker-compose up --build notebook

# Build and run the Dash/Flask app container
app:
	docker-compose up --build app

# Give execute permission and run startup script
startup:
	chmod +x startup.sh
	./startup.sh

# Convert line endings from CRLF to LF
convert-line-endings:
	dos2unix *.sh

# Install dos2unix if not installed
install-dos2unix:
	sudo apt-get update && sudo apt-get install -y dos2unix

# Run all startup steps
run-all: install-dos2unix convert-line-endings
	chmod +x run_all.sh
	chmod +x startup.sh
	./run_all.sh
	./startup.sh
	notebook app

# Run basic health checks on containers
healthcheck:
	@echo "Checking if Jupyter is running on port $(JUPYTER_PORT)..."
	curl --fail http://localhost:$(JUPYTER_PORT) || echo "❌ Jupyter not running"
	@echo "Checking if App is running on port $(APP_PORT)..."
	curl --fail http://localhost:$(APP_PORT) || echo "❌ App not running"

# Clean up Docker containers and images
clean:
	docker-compose down --volumes --remove-orphans
	docker system prune -f

# 🐳 Detached mode
detached:
	docker-compose up -d --build

# 🚀 Helm deployment
helm-deploy:
	helm upgrade --install tesla-platform $(HELM_CHART_DIR) --namespace $(NAMESPACE) --create-namespace

# Helm deploy for specific environments
helm-deploy-dev:
	helm upgrade --install tesla-dev $(HELM_CHART_DIR) -f $(HELM_CHART_DIR)/values-dev.yaml \
		--namespace dev --create-namespace

helm-deploy-prod:
	helm upgrade --install tesla-prod $(HELM_CHART_DIR) -f $(HELM_CHART_DIR)/values-prod.yaml \
		--namespace prod --create-namespace

helm-uninstall:
	helm uninstall tesla-platform --namespace $(NAMESPACE)

# Helm uninstall for specific environments
helm-uninstall-dev:
	helm uninstall tesla-dev --namespace dev

helm-uninstall-prod:
	helm uninstall tesla-prod --namespace prod

# Helmfile for multi-environment management
helmfile-dev:
	cd k8s/helmfile && helmfile -e dev apply

helmfile-prod:
	cd k8s/helmfile && helmfile -e prod apply

# 🧪 Run pytest tests
test:
	pytest codes/ --maxfail=1 --disable-warnings -q

# 🧼 Lint Python code with flake8
lint:
	flake8 codes/ --exclude=__init__.py

# 🖊 Format Python code with black
format:
	black codes/

# ⚙️ Launch Prefect flows
prefect-run:
	prefect deployment run 'main-flow/deployment'

# Prefect deployment with parameterization
prefect-deploy:
	prefect deployment build codes/flows/main_flow.py:main_flow \
		-n tesla-deploy \
		-q default \
		-p run_mode=prod -p model_version=v3 \
		--apply

# Helm chart packaging with auto-versioning
VERSION := $(shell git describe --tags --always)

helm-package:
	helm package $(HELM_CHART_DIR) --version $(VERSION) --app-version $(VERSION) --destination ./k8s/helm/packages

# 🐋 Docker status check
status:
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
