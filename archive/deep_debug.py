#!/usr/bin/env python3
"""
Deep debugging for PyTorch GPU detection issue
"""

import os
import sys
import subprocess
import ctypes

print("="*70)
print("DEEP DEBUG - PYTORCH GPU DETECTION")
print("="*70)

# 1. Check file descriptors and permissions
print("\n[1] FILE DESCRIPTORS AND PERMISSIONS:")
print("-"*40)

# Check if we can open the device files
devices_to_check = ['/dev/kfd', '/dev/dri/renderD128', '/dev/dri/card1']
for device in devices_to_check:
    if os.path.exists(device):
        try:
            # Try to open for reading
            with open(device, 'rb') as f:
                print(f"  {device}: Can open for reading ✓")
        except PermissionError:
            print(f"  {device}: Permission denied ✗")
        except Exception as e:
            print(f"  {device}: Error - {e}")
    else:
        print(f"  {device}: Does not exist")

# Check user groups
groups = subprocess.run(['groups'], capture_output=True, text=True).stdout.strip()
print(f"\n  User groups: {groups}")
print(f"  Has 'render' group: {'render' in groups}")
print(f"  Has 'video' group: {'video' in groups}")

# 2. Check ROCm runtime libraries
print("\n[2] ROCM RUNTIME LIBRARIES:")
print("-"*40)

# Check if ROCm libraries are accessible
rocm_libs = [
    '/opt/rocm/lib/libhsa-runtime64.so',
    '/opt/rocm/lib/libamdhip64.so',
    '/opt/rocm/lib/librocm_smi64.so'
]

for lib in rocm_libs:
    if os.path.exists(lib):
        try:
            # Try to load the library
            ctypes.CDLL(lib)
            print(f"  {os.path.basename(lib)}: Loaded successfully ✓")
        except Exception as e:
            print(f"  {os.path.basename(lib)}: Failed to load - {e}")
    else:
        print(f"  {os.path.basename(lib)}: Not found")

# 3. Check PyTorch internals
print("\n[3] PYTORCH INTERNALS:")
print("-"*40)

import torch

# Check compilation flags
if hasattr(torch, '_C'):
    print(f"  torch._C exists: Yes")
    
    # Check for specific functions
    attrs_to_check = [
        '_cuda_getDeviceCount',
        '_cuda_isDriverSufficient',
        '_cuda_getDriverVersion',
        '_cuda_getRuntimeVersion',
        '_cuda_init',
        '_hip_init'
    ]
    
    for attr in attrs_to_check:
        if hasattr(torch._C, attr):
            try:
                if 'get' in attr:
                    result = getattr(torch._C, attr)()
                    print(f"  {attr}: {result}")
                else:
                    print(f"  {attr}: exists")
            except Exception as e:
                print(f"  {attr}: exists but error - {str(e)[:50]}")
        else:
            print(f"  {attr}: not found")

# 4. Environment at import time
print("\n[4] IMPORT-TIME ENVIRONMENT:")
print("-"*40)

# Create a test script that shows environment at import
test_script = """
import os
import sys

# Show environment before torch import
env_before = {
    'HSA_OVERRIDE_GFX_VERSION': os.environ.get('HSA_OVERRIDE_GFX_VERSION', 'NOT_SET'),
    'PYTORCH_ROCM_ARCH': os.environ.get('PYTORCH_ROCM_ARCH', 'NOT_SET'),
    'LD_LIBRARY_PATH': os.environ.get('LD_LIBRARY_PATH', 'NOT_SET')
}

import torch

print(f"Environment at import: {env_before}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"Device: {torch.cuda.get_device_name(0)}")
"""

with open('/tmp/test_import.py', 'w') as f:
    f.write(test_script)

result = subprocess.run([sys.executable, '/tmp/test_import.py'], 
                       capture_output=True, text=True)
print(result.stdout)
if result.stderr:
    print(f"Stderr: {result.stderr}")

# 5. Check for multiple Python/PyTorch installations
print("\n[5] PYTHON/PYTORCH INSTALLATIONS:")
print("-"*40)

# Check which python
which_python = subprocess.run(['which', 'python'], capture_output=True, text=True).stdout.strip()
which_python3 = subprocess.run(['which', 'python3'], capture_output=True, text=True).stdout.strip()
print(f"  which python: {which_python}")
print(f"  which python3: {which_python3}")
print(f"  sys.executable: {sys.executable}")

# Check for other torch installations
try:
    result = subprocess.run(['find', os.path.expanduser('~'), '-name', 'torch', '-type', 'd', 
                           '-path', '*/site-packages/*', '-maxdepth', 8], 
                          capture_output=True, text=True, timeout=5)
    torch_installs = [line for line in result.stdout.split('\n') if line and 'site-packages/torch' in line]
    print(f"\n  PyTorch installations found: {len(torch_installs)}")
    for install in torch_installs[:3]:  # Show first 3
        print(f"    - {install}")
except:
    pass

# 6. Strace check (if available) - what happens when we try to detect GPU
print("\n[6] SYSTEM CALL TRACE (attempting GPU detection):")
print("-"*40)

strace_script = """
import torch
torch.cuda.is_available()
"""

try:
    with open('/tmp/test_strace.py', 'w') as f:
        f.write(strace_script)
    
    # Run with strace, filter for relevant calls
    result = subprocess.run(['strace', '-e', 'open,openat,ioctl', '-f',
                           sys.executable, '/tmp/test_strace.py'],
                          capture_output=True, text=True, timeout=5)
    
    # Look for relevant device opens
    relevant_lines = []
    for line in result.stderr.split('\n'):
        if any(x in line for x in ['/dev/kfd', '/dev/dri', 'ENOENT', 'EACCES', 'rocm']):
            relevant_lines.append(line[:100])
    
    if relevant_lines:
        print("  Device access attempts:")
        for line in relevant_lines[:10]:  # Show first 10
            print(f"    {line}")
    else:
        print("  No relevant device access attempts found")
except FileNotFoundError:
    print("  strace not available")
except Exception as e:
    print(f"  strace error: {e}")

# 7. Final test with explicit initialization
print("\n[7] EXPLICIT INITIALIZATION TEST:")
print("-"*40)

try:
    # Try to explicitly initialize
    if hasattr(torch._C, '_cuda_init'):
        torch._C._cuda_init()
        print("  Explicit CUDA init: Called")
    
    # Check again
    print(f"  After init - CUDA available: {torch.cuda.is_available()}")
    
    # Try HIP init if available
    if hasattr(torch._C, '_hip_init'):
        torch._C._hip_init()
        print("  Explicit HIP init: Called")
        print(f"  After HIP init - CUDA available: {torch.cuda.is_available()}")
    
except Exception as e:
    print(f"  Initialization error: {e}")

print("\n" + "="*70)
print("END OF DEEP DEBUG")
print("="*70)