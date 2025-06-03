#!/usr/bin/env python3
"""
Quick GPU checker script for Tesla Stock Analysis project.
Run this inside your Docker container to verify GPU availability.
"""

import sys
import os
import platform
import subprocess
from datetime import datetime
import torch

def print_section(title):
    """Print a section header."""
    print("\n" + "=" * 60)
    print(f" {title}")
    print("=" * 60)

def check_system_info():
    """Print basic system information."""
    print_section("SYSTEM INFORMATION")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Python version: {sys.version}")
    print(f"Platform: {platform.platform()}")
    
    # Check if running in Docker
    in_docker = os.path.exists('/.dockerenv') or os.environ.get('DOCKER_CONTAINER', False)
    print(f"Running in Docker: {'Yes' if in_docker else 'No'}")
    
    # Check for NVIDIA environment variables
    nvidia_vars = {k: v for k, v in os.environ.items() if 'NVIDIA' in k or 'CUDA' in k}
    if nvidia_vars:
        print("\nNVIDIA Environment Variables:")
        for k, v in nvidia_vars.items():
            print(f"  {k}: {v}")

def run_nvidia_smi():
    """Run nvidia-smi if available."""
    print_section("NVIDIA-SMI OUTPUT")
    try:
        result = subprocess.run(['nvidia-smi'], 
                                stdout=subprocess.PIPE, 
                                stderr=subprocess.PIPE,
                                text=True, 
                                check=False)
        if result.returncode == 0:
            print(result.stdout)
        else:
            print("nvidia-smi failed with error:")
            print(result.stderr)
            print("\nThis likely means NVIDIA drivers aren't properly installed or accessible.")
    except FileNotFoundError:
        print("nvidia-smi command not found. NVIDIA drivers may not be installed.")

def check_pytorch():
    """Check PyTorch GPU capabilities."""
    print_section("PYTORCH GPU CHECK")
    try:
        import torch
        print(f"PyTorch version: {torch.__version__}")
        cuda_available = torch.cuda.is_available()
        print(f"CUDA available: {cuda_available}")
        
        if cuda_available:
            print(f"CUDA version: {torch.version.cuda}")
            device_count = torch.cuda.device_count()
            print(f"GPU count: {device_count}")
            
            for i in range(device_count):
                print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
                
            # Test GPU performance
            print("\nRunning quick GPU performance test...")
            size = 4000
            
            # Create random matrices
            a = torch.randn(size, size, device='cuda')
            b = torch.randn(size, size, device='cuda')
            
            # Measure matrix multiplication time
            import time
            start = time.time()
            c = torch.matmul(a, b)
            torch.cuda.synchronize()  # Wait for GPU to finish
            end = time.time()
            
            print(f"Matrix multiplication of {size}x{size} took {end-start:.4f} seconds")
            print("✅ GPU is working correctly!")
        else:
            print("❌ CUDA is not available in PyTorch.")
            print("This could be due to:")
            print("  - Missing NVIDIA drivers")
            print("  - PyTorch not compiled with CUDA support")
            print("  - Docker not configured with GPU passthrough")
    except ImportError:
        print("PyTorch is not installed.")

def check_gpu():
    """Check GPU availability."""
    print("Checking GPU availability...")
    if torch.cuda.is_available():
        print(f"✅ CUDA is available!")
        print(f"GPU count: {torch.cuda.device_count()}")
        print(f"GPU name: {torch.cuda.get_device_name(0)}")
    else:
        print("❌ CUDA is not available. Check your NVIDIA drivers and Docker runtime.")

def main():
    """Run all checks."""
    print("\nGPU CHECK UTILITY FOR TESLA STOCK ANALYSIS PROJECT")
    print("This script checks if your GPU is correctly configured.")
    
    check_system_info()
    run_nvidia_smi()
    check_pytorch()
    check_gpu()
    
    print_section("CONCLUSION")
    try:
        import torch
        if torch.cuda.is_available():
            print("✅ Your environment has GPU support!")
            print("You can run the Tesla Stock Analysis with GPU acceleration.")
        else:
            print("❌ Your environment doesn't have GPU support.")
            print("Check your Docker configuration and NVIDIA drivers.")
    except ImportError:
        print("❌ PyTorch is not installed, can't verify GPU support.")

if __name__ == "__main__":
    main()
