#!/usr/bin/env python3
"""
ROCm Setup Diagnostic Tool for AMD Strix Halo
Tests if environment is properly configured for PyTorch GPU access
"""

import os
import sys
import subprocess

def check_environment():
    """Check if required environment variables are set"""
    print("="*60)
    print("ROCm ENVIRONMENT CHECK")
    print("="*60)
    
    required_vars = {
        'HSA_OVERRIDE_GFX_VERSION': '11.5.1',
        'PYTORCH_ROCM_ARCH': 'gfx1151',
        'HSA_XNACK': '1'
    }
    
    optional_vars = [
        'GPU_MAX_HEAP_SIZE',
        'GPU_MAX_ALLOC_PERCENT',
        'ROCR_VISIBLE_DEVICES',
        'HIP_VISIBLE_DEVICES'
    ]
    
    all_good = True
    
    print("\nRequired Environment Variables:")
    for var, expected in required_vars.items():
        actual = os.environ.get(var, 'NOT SET')
        if actual == expected:
            print(f"  ✓ {var}: {actual}")
        elif actual == 'NOT SET':
            print(f"  ✗ {var}: NOT SET (should be {expected})")
            all_good = False
        else:
            print(f"  ⚠ {var}: {actual} (expected {expected})")
    
    print("\nOptional Environment Variables:")
    for var in optional_vars:
        value = os.environ.get(var, 'NOT SET')
        status = "✓" if value != 'NOT SET' else "○"
        print(f"  {status} {var}: {value}")
    
    return all_good

def check_rocm():
    """Check ROCm installation"""
    print("\n" + "="*60)
    print("ROCm INSTALLATION CHECK")
    print("="*60)
    
    # Check rocm-smi
    try:
        result = subprocess.run(['rocm-smi', '--showid'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            print("✓ ROCm detected")
            # Get GPU info
            result = subprocess.run(['rocm-smi', '--showproductname'], 
                                  capture_output=True, text=True, timeout=5)
            for line in result.stdout.split('\n'):
                if 'GFX Version' in line or 'Card Series' in line:
                    print(f"  {line.strip()}")
        else:
            print("✗ rocm-smi failed")
    except FileNotFoundError:
        print("✗ rocm-smi not found - ROCm may not be installed")
    except Exception as e:
        print(f"✗ Error checking ROCm: {e}")

def check_pytorch():
    """Check PyTorch GPU detection"""
    print("\n" + "="*60)
    print("PYTORCH GPU DETECTION")
    print("="*60)
    
    try:
        import torch
        print(f"PyTorch version: {torch.__version__}")
        
        if hasattr(torch.version, 'hip'):
            print(f"ROCm version: {torch.version.hip}")
        else:
            print("ROCm support: Not detected in PyTorch build")
        
        cuda_available = torch.cuda.is_available()
        print(f"CUDA available: {cuda_available}")
        
        if cuda_available:
            print(f"Device count: {torch.cuda.device_count()}")
            print(f"Device name: {torch.cuda.get_device_name(0)}")
            props = torch.cuda.get_device_properties(0)
            print(f"Memory: {props.total_memory / 1e9:.1f} GB")
            
            # Test computation
            print("\nTesting GPU computation...")
            try:
                a = torch.randn(1000, 1000).cuda()
                b = torch.randn(1000, 1000).cuda()
                c = torch.matmul(a, b)
                torch.cuda.synchronize()
                print("✓ GPU computation successful")
            except Exception as e:
                print(f"✗ GPU computation failed: {e}")
        else:
            print("\n⚠ CUDA not available - PyTorch cannot detect GPU")
            
    except ImportError:
        print("✗ PyTorch not installed")
    except Exception as e:
        print(f"✗ Error: {e}")

def provide_solutions():
    """Provide solutions if GPU not detected"""
    print("\n" + "="*60)
    print("TROUBLESHOOTING")
    print("="*60)
    
    env_good = check_environment()
    
    if not env_good:
        print("\n⚠ Environment variables not properly set!")
        print("\nSOLUTION 1: Set up permanent environment (recommended)")
        print("  Run: ./setup_permanent.sh")
        print("  Then: Open a new terminal or restart your shell")
        
        print("\nSOLUTION 2: Set variables before starting Python")
        print("  Run this command BEFORE starting Python:")
        print("  export HSA_OVERRIDE_GFX_VERSION=11.5.1 && \\")
        print("  export PYTORCH_ROCM_ARCH=gfx1151 && \\")
        print("  export HSA_XNACK=1")
        
        print("\nSOLUTION 3: Use the wrapper script")
        print("  Create run_python.sh with:")
        print("  #!/bin/bash")
        print("  export HSA_OVERRIDE_GFX_VERSION=11.5.1")
        print("  export PYTORCH_ROCM_ARCH=gfx1151")
        print("  export HSA_XNACK=1")
        print("  python3 \"$@\"")
        
        print("\nIMPORTANT: Environment variables must be set BEFORE")
        print("Python/PyTorch is imported. They cannot be changed after.")
    else:
        print("\n✓ Environment variables are properly set")
        print("\nIf GPU still not detected, check:")
        print("1. ROCm installation: sudo apt install rocm-dkms")
        print("2. User groups: sudo usermod -a -G render,video $USER")
        print("3. Kernel module: lsmod | grep amdgpu")
        print("4. PyTorch build: Ensure it has ROCm support")

def main():
    print("AMD Strix Halo ROCm Setup Diagnostic")
    print("="*60)
    
    # Run all checks
    env_good = check_environment()
    check_rocm()
    check_pytorch()
    
    # Provide solutions if needed
    import torch
    if not torch.cuda.is_available():
        provide_solutions()
    else:
        print("\n" + "="*60)
        print("✓ SETUP SUCCESSFUL - GPU READY FOR USE")
        print("="*60)

if __name__ == "__main__":
    main()