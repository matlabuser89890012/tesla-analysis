#!/bin/bash

set -e  # Exit on error

# Function to handle errors
handle_error() {
    echo "❌ Error occurred: $1"
    echo "Attempting recovery..."
}

trap 'handle_error "$BASH_COMMAND"' ERR

# Ensure script is executable on Unix systems
if [[ "$OSTYPE" != "win"* ]]; then
    chmod +x "${BASH_SOURCE[0]}"
    if [ -f run_all.sh ]; then
        chmod +x run_all.sh
    fi
fi

# Function to check service health
check_service() {
    local url=$1
    local name=$2
    local max_retries=5
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if curl -s "$url" > /dev/null; then
            echo "✅ $name is running at $url"
            return 0
        fi
        retry=$((retry + 1))
        echo "Retry $retry/$max_retries for $name..."
        sleep 5
    done
    
    echo "❌ $name failed to start"
    return 1
}

# Detect Docker Compose command (support both 'docker-compose' and 'docker compose')
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Neither docker-compose nor docker compose found. Please install Docker Compose."
    exit 1
fi

# Check for GPU support
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA GPU detected"
    nvidia-smi
else
    echo "⚠️ NVIDIA GPU not detected - services will run in CPU mode"
    echo "   This will significantly slow down any ML computations."
fi

# Fix dependency issues in requirements files
echo "Checking for dependency conflicts..."
if grep -q "python-lsp-server\[all\]" requirements.txt; then
    echo "Fixing dependency conflicts in requirements.txt..."
    sed -i 's/python-lsp-server\[all\]/python-lsp-server/g' requirements.txt
fi

if grep -q "pycodestyle<2.11.0" requirements-dev.txt; then
    echo "Adding pycodestyle constraint to requirements-dev.txt..."
    echo "pycodestyle>=2.9.0,<2.11.0" >> requirements-dev.txt
fi

# Start services individually with proper checks
start_service() {
    local service=$1
    echo "Starting $service service..."
    $DOCKER_COMPOSE up --build -d $service
    
    # Service-specific health checks
    case $service in
        notebook)
            check_service "http://localhost:8888" "Jupyter Notebook"
            ;;
        app)
            check_service "http://localhost:8050" "Dashboard App"
            ;;
        torchserve)
            check_service "http://localhost:8080/ping" "TorchServe"
            ;;
    esac
}

# Stop any existing containers
echo "Stopping existing containers..."
$DOCKER_COMPOSE down

# Build and start each service
echo "Starting services individually..."
start_service notebook
start_service app
start_service torchserve

# Check if GPU is available for each service
for service in notebook app torchserve; do
    if [ "$service" != "torchserve" ]; then  # TorchServe has its own GPU check
        echo "Checking GPU for $service..."
        $DOCKER_COMPOSE exec $service python3 -c "import torch; print(f'GPU available for $service:', torch.cuda.is_available())"
    fi
done

# Final status
echo -e "\nServices status:"
$DOCKER_COMPOSE ps

echo -e "\n========================================"
echo "✅ All services are running!"
echo "- Jupyter Notebook: http://localhost:8888"
echo "- Dashboard App: http://localhost:8050"
echo "- TorchServe Inference API: http://localhost:8080"
echo "- TorchServe Management API: http://localhost:8081"
echo ""
echo "To view logs: $DOCKER_COMPOSE logs"
echo "To stop all services: $DOCKER_COMPOSE down"
echo "========================================"
