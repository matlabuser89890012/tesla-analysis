# Tesla Stock Analysis

An interactive platform for analyzing Tesla stock performance using Python, PyTorch, and interactive visualizations.

## Features

- Real-time stock data analysis using Yahoo Finance API
- Interactive visualizations with Plotly and Dash
- Technical indicators and predictive modeling
- GPU-accelerated model training with PyTorch
- Containerized deployment with Docker and NVIDIA GPU support

## Quick Start & Workflow

### 1. Clone the repository

Choose the command for your shell/environment:

```bash
git clone https://github.com/matlabuser89890012/tesla-stock-analysis.git
cd tesla-stock-analysis
# OR (Windows WSL)
cd /mnt/c/Users/Hasib/Projects/tesla-stock-analysis
# OR (Windows CMD or PowerShell)
cd "C:\Users\Hasib\Projects\tesla-stock-analysis"
```

### 2. Conda/Mamba Environment Setup

**Recommended:** Use a consistent environment name (e.g. `tesla-analysis-f`).

```bash
# Using mamba (faster)
mamba env create -f environment.yml
mamba env update -n tesla-analysis-f -f environment.yml --prune
mamba env update -n tesla-analysis-f -f environment.dev.yml --prune

# OR using conda
conda env create -f environment.yml
conda env update -n tesla-analysis-f -f environment.yml --prune
conda env update -n tesla-analysis-f -f environment.dev.yml --prune

# Activate the environment
conda activate tesla-analysis-f
```

### 3. Python Dependencies

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### 4. Docker Compose Startup

```bash
# On Windows PowerShell
.\startup.bat

# Or manually (any shell)
docker compose up --build notebook
docker compose up --build app
docker compose up --build torchserve
```

### 5. GPU Check (inside container)

```bash
docker exec -it tesla-stock-analysis-notebook bash
python /app/codes/check_gpu.py
```

### 6. Docker Image Tag & Push

Replace `registry.example.com` with your registry:

```bash
docker tag tesla-stock-analysis:latest registry.example.com/tesla-stock-analysis:latest
docker push registry.example.com/tesla-stock-analysis:latest
```

### 7. Kubernetes Deployment

```bash
kubectl apply -f tesla-deployment.yaml
```

### 8. Git Workflow

```bash
git add .
git commit -m "Your commit message"
git remote add origin https://github.com/matlabuser89890012/tesla-analysis.git # if not set
git remote -v
git pull --rebase origin main
git push -u origin main
```

### 9. Scripts & Permissions

```bash
# For Windows PowerShell script
.\setup.ps1

# For Linux/macOS shell script
chmod +x setup.sh
./setup.sh
```

## License

[MIT License](LICENSE)

## Install Common Libraries

Use `mamba` to install frequently used libraries for data analysis, machine learning, and visualization.

```bash
# Activate environment
conda activate tesla-analysis-f

# Use mamba to install common libraries
mamba install -c conda-forge \
  numpy \
  pandas \
  matplotlib \
  seaborn \
  scikit-learn \
  scipy \
  statsmodels \
  jupyterlab \
  ipywidgets \
  plotly \
  bokeh \
  fastapi \
  uvicorn \
  sqlalchemy \
  psycopg2 \
  pymongo \
  requests \
  beautifulsoup4 \
  lxml \
  pyyaml \
  rich \
  tqdm \
  numba \
  cudatoolkit=11.8 \
  pytorch \
  torchvision \
  torchaudio \
  pytorch-cuda=11.8 \
  transformers \
  datasets \
  xgboost \
  lightgbm
```