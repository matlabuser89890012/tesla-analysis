# Stage 1: Builder - install dependencies and Python packages
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04 AS builder

# Set working directory
WORKDIR /app

# Add DEBIAN_FRONTEND to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (added python3 to ensure it’s available)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# (Optional) Add build argument for CPU count; pass all available cores at build time.
# Example: docker build --build-arg CPU_COUNT=$(nproc) ...
ARG CPU_COUNT=24
# Use CPU_COUNT for parallel compiling (if needed)
ENV MAKEFLAGS="-j${CPU_COUNT}"
# Setup pip cache directory for faster pip installs on rebuilds
ENV PIP_CACHE_DIR=/tmp/pip-cache
RUN mkdir -p $PIP_CACHE_DIR

# Copy and install Python packages using python3 -m pip
COPY requirements.txt ./
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install -r requirements.txt

# Install dev requirements separately to avoid dependency conflicts
COPY requirements-dev.txt ./
RUN python3 -m pip install -r requirements-dev.txt || echo "Some dev dependencies could not be installed - continuing anyway"

# Stage 2: Runtime - use a lean final image copying built packages from builder
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Add DEBIAN_FRONTEND to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install curl for healthcheck
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /usr/local /usr/local

# Copy project files
COPY ./codes ./codes
COPY environment.yml ./
COPY .vscode ./.vscode

# Expose port if you later want to run a Dash app or web server
EXPOSE 8050
# Expose Jupyter Notebook port in addition to existing port(s)
EXPOSE 8888

# Install Jupyter Notebook (if not already in requirements)
RUN python3 -m pip install notebook

# Set environment variable for CUDA to maximize GPU use
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video

# Override CMD to launch Jupyter Notebook by default instead of main.py
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]

# Add a health check at the end of the runtime stage
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8888 || exit 1

# How to build the image:
#   export DOCKER_BUILDKIT=1
#   docker build --build-arg CPU_COUNT=$(nproc) --progress=plain --no-cache -t tesla-stock-analysis:latest .
# How to run the container using all available CPU cores, your RTX 5000 GPU, and large RAM:
#   docker run --gpus all --memory=48g -it --rm -p 8050:8050 tesla-stock-analysis:latest
