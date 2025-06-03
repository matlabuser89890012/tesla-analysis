# Tesla Stock Analysis

An interactive platform for analyzing Tesla stock performance using Python, PyTorch, and interactive visualizations.

## Features

- Real-time stock data analysis using Yahoo Finance API
- Interactive visualizations with Plotly and Dash
- Technical indicators and predictive modeling
- GPU-accelerated model training with PyTorch
- Containerized deployment with Docker and NVIDIA GPU support

## Quick Start

### Prerequisites

- Docker and Docker Compose
- NVIDIA GPU with appropriate drivers (optional but recommended)
- NVIDIA Container Toolkit (for GPU support)

### Running the Platform

#### 1. Start All Services (Recommended)

The easiest way to start everything:

```bash
# On Linux/macOS
chmod +x startup.sh
./startup.sh

# On Windows
.\startup.sh
```

#### 2. Start Individual Services

To start only specific components:

```bash
# Start Jupyter Notebook
docker compose up --build notebook

# Start Dashboard App
docker compose up --build app

# Start TorchServe
docker compose up --build torchserve
```

#### 3. Access the Services

- Jupyter Notebook: [http://localhost:8888](http://localhost:8888) (no token required)
- Dashboard App: [http://localhost:8050](http://localhost:8050)
- TorchServe APIs:
  - Inference API: [http://localhost:8080](http://localhost:8080)
  - Management API: [http://localhost:8081](http://localhost:8081)

## Development Setup

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/tesla-stock-analysis.git
   cd tesla-stock-analysis
   ```

2. Create a conda environment:
   ```bash
   conda env create -f environment.yml
   conda activate tesla-analysis
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt -r requirements-dev.txt
   ```

### Testing GPU Support

To verify GPU support in your containers:

```bash
# Connect to the running notebook container
docker exec -it tesla-stock-analysis-notebook bash

# Run the GPU check script
python /app/codes/check_gpu.py
```

## Deploying to Kubernetes

1. Push the Docker image to a registry:
   ```bash
   docker tag tesla-stock-analysis:latest registry.example.com/tesla-stock-analysis:latest
   docker push registry.example.com/tesla-stock-analysis:latest
   ```

2. Apply the Kubernetes configuration:
   ```bash
   kubectl apply -f tesla-deployment.yaml
   ```

3. Access the app via the LoadBalancer IP.

## License

[MIT License](LICENSE)