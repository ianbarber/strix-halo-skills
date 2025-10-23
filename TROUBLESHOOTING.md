# Troubleshooting PyTorch GPU Detection on AMD Strix Halo

## Problem: PyTorch shows "CUDA available: False" intermittently

### Quick Test
```bash
python test_gpu_simple.py
```

### Common Causes and Solutions

#### 1. Environment Variables Not Set (Most Common)
**Symptom**: GPU not detected in new terminals

**Solution**: Add to your shell configuration permanently
```bash
# Add these to ~/.bashrc or ~/.zshrc
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PYTORCH_ROCM_ARCH=gfx1151
export HSA_XNACK=1

# Then reload
source ~/.bashrc
```

#### 2. Conda Environment Issue
**Symptom**: Works outside conda, fails inside

**Solution**: Reset the conda environment
```bash
# Deactivate and reactivate
conda deactivate
conda activate rock311

# Or create activation scripts
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
echo 'export HSA_OVERRIDE_GFX_VERSION=11.5.1' > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
echo 'export PYTORCH_ROCM_ARCH=gfx1151' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
echo 'export HSA_XNACK=1' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
```

#### 3. Python Session Already Started
**Symptom**: Setting environment variables doesn't help

**Solution**: Environment variables must be set BEFORE Python starts
```bash
# Wrong way:
python
>>> import os
>>> os.environ['HSA_OVERRIDE_GFX_VERSION'] = '11.5.1'  # Too late!
>>> import torch  # Won't work

# Right way:
export HSA_OVERRIDE_GFX_VERSION=11.5.1
python
>>> import torch  # Works!
```

#### 4. ROCm Runtime Issue
**Symptom**: Intermittent detection

**Solution**: Check ROCm is properly loaded
```bash
# Check GPU is visible to ROCm
rocm-smi

# Check HIP runtime
hipconfig --version

# Reset GPU (if needed)
sudo rocm-smi --gpureset
```

#### 5. Library Path Issue
**Symptom**: ROCm libraries not found

**Solution**: Add ROCm to library path
```bash
export LD_LIBRARY_PATH=/opt/rocm/lib:$LD_LIBRARY_PATH
```

### Diagnostic Commands

```bash
# 1. Check if environment is set
env | grep -E "HSA_|PYTORCH_|HIP_"

# 2. Check if GPU is visible to system
lspci | grep -i amd

# 3. Check if amdgpu driver is loaded
lsmod | grep amdgpu

# 4. Check ROCm detection
rocminfo | grep gfx1151

# 5. Test in fresh Python
python -c "import torch; print(torch.cuda.is_available())"
```

### Nuclear Option - Full Reset

If nothing works, try a complete reset:

```bash
# 1. Close all Python/Jupyter sessions
pkill -f python

# 2. Unload and reload amdgpu module (requires sudo)
sudo modprobe -r amdgpu
sudo modprobe amdgpu

# 3. Set all environment variables
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PYTORCH_ROCM_ARCH=gfx1151
export HSA_XNACK=1
export ROCR_VISIBLE_DEVICES=0
export HIP_VISIBLE_DEVICES=0
export GPU_MAX_HEAP_SIZE=100
export GPU_MAX_ALLOC_PERCENT=100

# 4. Test
python -c "import torch; print(f'GPU: {torch.cuda.is_available()}')"
```

### Working Configuration Reference

When everything is working, you should see:
```
Environment Variables:
  HSA_OVERRIDE_GFX_VERSION: 11.5.1
  PYTORCH_ROCM_ARCH: gfx1151
  HSA_XNACK: 1

PyTorch Information:
  PyTorch version: 2.7.0a0+gitbfd8155
  HIP/ROCm version: 6.5.25190-39c57805b
  CUDA available: True
  Device name: AMD Radeon Graphics
```

### If Still Not Working

1. **Verify PyTorch has ROCm support**:
```bash
python -c "import torch; print(hasattr(torch.version, 'hip'))"
# Should print: True
```

2. **Check PyTorch can see ROCm libraries**:
```bash
ldd $(python -c "import torch; print(torch.__file__.replace('__init__.py', 'lib/libtorch_hip.so'))") | grep -i hip
# Should show HIP libraries
```

3. **Try the wrapper script**:
```bash
./run_with_rocm.sh test_gpu_simple.py
```

### Notes

- The GPU detection can be flaky on Strix Halo due to early driver support
- Sometimes it works without environment variables, sometimes it requires them
- The environment variables don't hurt even when not needed
- Always set them BEFORE importing PyTorch