# Strix Halo Quick Reference

Quick reference for common Strix Halo operations and troubleshooting.

## System Info

```bash
# Check GPU
rocm-smi
rocminfo | grep gfx1151

# Check memory configuration
cat /proc/cmdline | grep amdttm
rocm-smi --showmeminfo gtt

# Check kernel version
uname -r

# Check user groups
groups | grep -E "render|video"
```

## PyTorch Quick Test

```bash
# Test GPU detection
python -c "import torch; print('GPU:', torch.cuda.is_available())"

# Test compute (will fail with official wheels)
python -c "import torch; a=torch.tensor([1.0]).cuda(); print('OK:', (a+1).item())"

# Check PyTorch version
python -c "import torch; print('PyTorch:', torch.__version__); print('HIP:', torch.version.hip)"
```

## Working PyTorch Installation

```bash
# AMD nightlies (latest)
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch

# scottt's builds (stable)
# Visit: https://github.com/scottt/rocm-TheRock/releases
```

## Environment Variables

Essential for gfx1151:

```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PYTORCH_ROCM_ARCH=gfx1151
export HSA_XNACK=1
export ROCBLAS_USE_HIPBLASLT=1
```

## New Project

```bash
# Use automated setup
./setup_new_project.sh

# Or manually
conda create -n myproject python=3.12
conda activate myproject
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

## Monitoring

```bash
# Watch GPU usage
watch -n 1 rocm-smi

# Check memory details
rocm-smi --showmeminfo vram
rocm-smi --showmeminfo gtt

# System memory
free -h
```

## Common Issues

### HIP error: invalid device function
**Cause**: Official PyTorch wheels don't work
**Fix**: Install community wheels for gfx1151

### GPU not detected
**Cause**: User not in render/video groups
**Fix**: `sudo usermod -aG render,video $USER` and reboot

### Out of memory below 30GB
**Cause**: GTT not configured
**Fix**: Add `amdttm.pages_limit=27648000` to GRUB

## Performance Tips

1. **Use BF16**: 1.6x faster than FP32
   ```python
   with torch.amp.autocast(device_type='cuda', dtype=torch.bfloat16):
       output = model(input)
   ```

2. **Small batch sizes**: Keep 1-4 for inference

3. **Monitor GTT usage**: Data in VRAM is faster than GTT

4. **Enable hipBLASLt**: `export ROCBLAS_USE_HIPBLASLT=1`

## Hardware Specs

- **Compute**: 7 TFLOPS FP32, 12 TFLOPS BF16
- **Memory**: 113GB GPU-accessible (with GTT)
- **Bandwidth**: 229 GB/s write, 201 GB/s copy
- **Models**: Up to 30B parameters in FP16

## Alternative: Vulkan

For inference, Vulkan often performs better:

```bash
sudo apt install mesa-vulkan-drivers vulkan-tools
vulkaninfo | grep deviceName

# Use with llama.cpp, Ollama, etc.
./llama-cli -m model.gguf -ngl 99 --gpu-backend vulkan
```

## Useful Links

- **Complete Guide**: STRIX_HALO_COMPLETE_GUIDE.md
- **Community Wheels**: https://github.com/scottt/rocm-TheRock/releases
- **Strix Halo Info**: https://llm-tracker.info/_TOORG/Strix-Halo
- **ROCm Docs**: https://rocm.docs.amd.com/
