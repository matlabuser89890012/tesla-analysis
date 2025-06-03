"""
GPU Environment Checker for Tesla Stock Analysis project.
Run this script inside the container to verify your CUDA/GPU setup.
"""
import sys
import platform
import numpy as np
import os
import subprocess

def check_environment():
    """Perform basic checks on the Python environment."""
    print("=" * 50)
    print("ENVIRONMENT CHECK")
    print("=" * 50)
    print(f"Python version: {platform.python_version()}")
    print(f"NumPy version: {np.__version__}")
    
    # Check for critical packages
    packages_to_check = [
        "pandas", "torch", "matplotlib", "plotly", 
        "yfinance", "dash", "scikit-learn"
    ]
    
    for package in packages_to_check:
        try:
            module = __import__(package)
            version = getattr(module, "__version__", "unknown")
            print(f"{package} version: {version}")
        except ImportError:
            print(f"⚠️ {package} is not installed!")

def check_gpu():
    """Check if GPU/CUDA is available and working."""
    print("\n" + "=" * 50)
    print("GPU/CUDA CHECK")
    print("=" * 50)
    
    try:
        import torch
        cuda_available = torch.cuda.is_available()
        print(f"CUDA available: {cuda_available}")
        
        if cuda_available:
            print(f"CUDA version: {torch.version.cuda}")
            print(f"GPU count: {torch.cuda.device_count()}")
            for i in range(torch.cuda.device_count()):
                print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
                
            # Test a small GPU operation
            print("\nPerforming a test GPU operation...")
            x = torch.rand(1000, 1000).cuda()
            y = torch.matmul(x, x)
            print(f"GPU tensor shape: {y.shape} ✓")
            
        else:
            print("⚠️ CUDA is not available. Check your installation.")
            
            # Try to get more info
            try:
                # Try to run nvidia-smi
                result = subprocess.run(['nvidia-smi'], 
                                        stdout=subprocess.PIPE, 
                                        stderr=subprocess.PIPE,
                                        text=True)
                if result.returncode == 0:
                    print("\nnvidia-smi output:")
                    print(result.stdout)
                else:
                    print("\nnvidia-smi not available or failed:")
                    print(result.stderr)
            except:
                print("Could not run nvidia-smi")
    
    except ImportError:
        print("⚠️ PyTorch is not installed!")
    except Exception as e:
        print(f"⚠️ Error testing GPU: {str(e)}")

def check_docker():
    """Check Docker environment variables and settings."""
    print("\n" + "=" * 50)
    print("DOCKER ENVIRONMENT CHECK")
    print("=" * 50)
    
    docker_vars = [
        "NVIDIA_VISIBLE_DEVICES",
        "NVIDIA_DRIVER_CAPABILITIES",
        "CUDA_VERSION",
        "PATH",
        "LD_LIBRARY_PATH"
    ]
    
    for var in docker_vars:
        print(f"{var}: {os.environ.get(var, 'Not set')}")

if __name__ == "__main__":
    check_environment()
    check_gpu()
    check_docker()
    
    print("\n" + "=" * 50)
    print("CONCLUSION")
    print("=" * 50)
    
    try:
        import torch
        if torch.cuda.is_available():
            print("✅ Your environment is correctly set up with GPU support!")
        else:
            print("⚠️ Your environment is missing GPU support.")
            print("   Verify your Docker setup and NVIDIA drivers.")
    except:
        print("⚠️ Cannot verify PyTorch GPU status.")
