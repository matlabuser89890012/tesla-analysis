#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running or not accessible. Please start Docker first."
  exit 1
fi

# Check if nvidia-smi is available (for GPU support)
if command -v nvidia-smi &> /dev/null; then
  echo "✅ NVIDIA GPU detected"
  nvidia-smi
else
  echo "⚠️ NVIDIA GPU not detected - falling back to CPU mode"
fi

echo "========================================"
echo "Building and testing Tesla Stock Analysis"
echo "========================================"

# Test the notebook container
echo "Building and starting notebook container..."
docker compose up --build -d notebook

# Wait for the container to be ready
echo "Waiting for notebook to be ready..."
sleep 10

# Check if the notebook service is accessible
if curl -s http://localhost:8888 > /dev/null; then
  echo "✅ Notebook is running at http://localhost:8888"
else
  echo "❌ Notebook service failed to start. Check logs with 'docker compose logs notebook'"
  exit 1
fi

# Test the app container
echo "Building and starting app container..."
docker compose up --build -d app

# Wait for the container to be ready
echo "Waiting for app to be ready..."
sleep 10

# Check if the app service is accessible
if curl -s http://localhost:8050 > /dev/null; then
  echo "✅ Dashboard app is running at http://localhost:8050"
else
  echo "❌ Dashboard app failed to start. Check logs with 'docker compose logs app'"
  exit 1
fi

echo "========================================"
echo "✅ All services are running!"
echo "- Notebook: http://localhost:8888"
echo "- Dashboard: http://localhost:8050"
echo ""
echo "To stop all services: docker compose down"
echo "========================================"

echo "Running tests..."
pytest --cov=codes --cov-report=term-missing

echo "Running lint checks..."
flake8 codes
black --check codes
mypy codes
