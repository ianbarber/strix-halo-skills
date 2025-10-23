# Strix Halo Project Setup

Set up a new PyTorch project optimized for AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151).

## What This Skill Does

1. Checks system configuration (ROCm, GTT, user groups)
2. Creates a new conda environment with working PyTorch for gfx1151
3. Sets up proper environment variables
4. Creates test scripts to verify GPU functionality
5. Provides a project template with best practices

## Prerequisites Check

Before running setup, verify:
- ROCm 6.4+ is installed (`rocm-smi --version`)
- User is in `render` and `video` groups (`groups | grep -E "render|video"`)
- GTT is configured (check `/proc/cmdline` for `amdttm.pages_limit`)

## Setup Process

### Step 1: System Verification

Check current system status:

```bash
# Verify ROCm installation
rocm-smi --version
rocm-smi | grep gfx1151

# Check GTT configuration
cat /proc/cmdline | grep amdttm

# Verify user groups
groups | grep -E "render|video"
```

If any checks fail, refer to STRIX_HALO_COMPLETE_GUIDE.md.

### Step 2: Create Project Environment

Ask user for project name, then create conda environment:

```bash
# Create new environment with Python 3.12
conda create -n {project_name} python=3.12 -y
conda activate {project_name}
```

### Step 3: Install PyTorch (Community Build)

**CRITICAL**: Official PyTorch wheels don't work with gfx1151. Use community builds:

```bash
# Option 1: AMD Nightlies (recommended, latest)
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch torchvision torchaudio

# Option 2: scottt's stable builds (if nightlies have issues)
# Visit: https://github.com/scottt/rocm-TheRock/releases
# Download and install specific wheel for Python 3.12
```

### Step 4: Install Common ML Libraries

```bash
pip install numpy transformers accelerate bitsandbytes datasets
pip install jupyter ipykernel  # if using notebooks
```

### Step 5: Configure Environment Variables

Create activation script for the environment:

```bash
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
cat > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh << 'EOF'
#!/bin/bash

# Core ROCm settings for Strix Halo (gfx1151)
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PYTORCH_ROCM_ARCH=gfx1151

# Unified Memory Configuration
export HSA_XNACK=1
export HSA_FORCE_FINE_GRAIN_PCIE=1

# Memory allocation settings
export GPU_MAX_HEAP_SIZE=100
export GPU_MAX_ALLOC_PERCENT=100

# Device visibility
export ROCR_VISIBLE_DEVICES=0
export HIP_VISIBLE_DEVICES=0

# Performance optimizations
export ROCBLAS_USE_HIPBLASLT=1
export AMD_LOG_LEVEL=0
export HSA_CU_MASK=0xffffffffffffffff

echo "Strix Halo environment variables set"
EOF

chmod +x $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
```

Create deactivation script:

```bash
mkdir -p $CONDA_PREFIX/etc/conda/deactivate.d
cat > $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh << 'EOF'
#!/bin/bash

unset HSA_OVERRIDE_GFX_VERSION
unset PYTORCH_ROCM_ARCH
unset HSA_XNACK
unset HSA_FORCE_FINE_GRAIN_PCIE
unset GPU_MAX_HEAP_SIZE
unset GPU_MAX_ALLOC_PERCENT
unset ROCR_VISIBLE_DEVICES
unset HIP_VISIBLE_DEVICES
unset ROCBLAS_USE_HIPBLASLT
unset AMD_LOG_LEVEL
unset HSA_CU_MASK

echo "Strix Halo environment variables unset"
EOF

chmod +x $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh
```

### Step 6: Create Project Structure

Create standard project directory structure:

```bash
mkdir -p {project_name}/{scripts,notebooks,data,models,tests}
cd {project_name}
```

### Step 7: Create Test Scripts

Create GPU verification script:

**File: `scripts/test_gpu.py`**
```python
#!/usr/bin/env python3
"""
Test GPU availability and basic compute on Strix Halo
"""
import torch
import sys

def test_gpu():
    print("="*60)
    print("STRIX HALO GPU TEST")
    print("="*60)

    # Check availability
    if not torch.cuda.is_available():
        print("❌ GPU not detected")
        print("\nTroubleshooting:")
        print("1. Check user groups: groups | grep -E 'render|video'")
        print("2. Verify ROCm: rocm-smi")
        print("3. Check PyTorch: python -c 'import torch; print(torch.version.hip)'")
        sys.exit(1)

    print(f"✓ GPU detected: {torch.cuda.get_device_name(0)}")

    # Check properties
    props = torch.cuda.get_device_properties(0)
    print(f"  Architecture: gfx{props.gcnArchName if hasattr(props, 'gcnArchName') else 'unknown'}")
    print(f"  Memory: {props.total_memory / 1e9:.1f} GB")
    print(f"  Compute Units: {props.multi_processor_count}")

    # Test allocation
    print("\nTesting memory allocation...")
    try:
        tensor = torch.zeros(int(1e9), device='cuda')  # 4GB
        print(f"  ✓ Allocated 4GB")
        del tensor
    except Exception as e:
        print(f"  ❌ Allocation failed: {e}")
        sys.exit(1)

    # Test compute
    print("\nTesting compute operations...")
    try:
        a = torch.randn(1000, 1000, device='cuda')
        b = torch.randn(1000, 1000, device='cuda')
        c = torch.matmul(a, b)
        torch.cuda.synchronize()
        print(f"  ✓ Matrix multiplication successful")
        del a, b, c
    except Exception as e:
        print(f"  ❌ Compute failed: {e}")
        print("\nThis usually means you're using official PyTorch wheels.")
        print("Install community wheels: pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch")
        sys.exit(1)

    # Test BF16
    print("\nTesting BF16 support...")
    try:
        a = torch.randn(1000, 1000, device='cuda', dtype=torch.bfloat16)
        b = torch.randn(1000, 1000, device='cuda', dtype=torch.bfloat16)
        c = torch.matmul(a, b)
        torch.cuda.synchronize()
        print(f"  ✓ BF16 compute successful")
    except Exception as e:
        print(f"  ⚠ BF16 failed: {e}")

    print("\n" + "="*60)
    print("✓ ALL TESTS PASSED")
    print("="*60)
    print("\nYour Strix Halo is ready for ML workloads!")
    print(f"Available memory: {props.total_memory / 1e9:.1f} GB")
    print("Recommended: Use BF16 for 1.6x speedup over FP32")

if __name__ == "__main__":
    test_gpu()
```

Create memory benchmark script:

**File: `scripts/benchmark_memory.py`**
```python
#!/usr/bin/env python3
"""
Test memory capacity on Strix Halo
"""
import torch
import gc

def test_memory_capacity():
    print("Testing maximum memory allocation...")
    print("(This will progressively allocate larger tensors)")

    device = torch.device('cuda')
    test_sizes = [8, 16, 24, 32, 40, 48, 56, 64]
    max_allocated = 0

    for size_gb in test_sizes:
        try:
            print(f"\nTesting {size_gb} GB... ", end="", flush=True)
            elements = int((size_gb * 1e9) / 4)
            tensor = torch.zeros(elements, device=device)
            tensor[0] = 1.0  # Touch memory
            _ = tensor[0].item()  # Force sync

            max_allocated = size_gb
            print(f"✓")

            del tensor
            torch.cuda.empty_cache()
            gc.collect()

        except RuntimeError as e:
            if "out of memory" in str(e).lower():
                print(f"✗ (OOM)")
                break
            else:
                print(f"✗ Error: {e}")
                break

    print(f"\n{'='*60}")
    print(f"Maximum allocation: {max_allocated} GB")
    print(f"{'='*60}")

    if max_allocated >= 30:
        print("✓ Can run 30B+ parameter models!")
    elif max_allocated >= 13:
        print("✓ Can run 13B parameter models")
    else:
        print("⚠ Limited memory - check GTT configuration")

if __name__ == "__main__":
    test_memory_capacity()
```

Create simple benchmark script:

**File: `scripts/benchmark_compute.py`**
```python
#!/usr/bin/env python3
"""
Benchmark compute performance on Strix Halo
"""
import torch
import time

def benchmark_matmul(size=2048, iterations=20):
    device = torch.device('cuda')

    print(f"Benchmarking {size}x{size} matrix multiplication...")
    print(f"Iterations: {iterations}\n")

    for dtype_name, dtype in [('FP32', torch.float32), ('BF16', torch.bfloat16)]:
        print(f"Testing {dtype_name}...")

        # Create tensors
        a = torch.randn(size, size, device=device, dtype=dtype)
        b = torch.randn(size, size, device=device, dtype=dtype)

        # Warmup
        for _ in range(3):
            c = torch.matmul(a, b)
        torch.cuda.synchronize()

        # Benchmark
        start = time.time()
        for _ in range(iterations):
            c = torch.matmul(a, b)
        torch.cuda.synchronize()
        elapsed = time.time() - start

        # Calculate TFLOPS
        ops = 2 * size**3 * iterations
        tflops = ops / (elapsed * 1e12)
        ms_per_iter = (elapsed / iterations) * 1000

        print(f"  {tflops:.2f} TFLOPS ({ms_per_iter:.2f} ms/iter)")

        del a, b, c
        torch.cuda.empty_cache()

    print(f"\nNote: Strix Halo typically achieves:")
    print(f"  FP32: ~7 TFLOPS")
    print(f"  BF16: ~12 TFLOPS")

if __name__ == "__main__":
    benchmark_matmul()
```

### Step 8: Create README

**File: `README.md`**
```markdown
# {Project Name}

PyTorch project optimized for AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151).

## Environment

- **Hardware**: AMD Strix Halo (gfx1151)
- **ROCm**: 6.4.2+
- **PyTorch**: Community build for gfx1151
- **Python**: 3.12

## Setup

```bash
# Activate environment
conda activate {project_name}

# Verify GPU
python scripts/test_gpu.py

# Test memory capacity
python scripts/benchmark_memory.py

# Benchmark compute
python scripts/benchmark_compute.py
```

## Hardware Capabilities

- **Compute**: ~7 TFLOPS FP32, ~12 TFLOPS BF16
- **Memory**: Up to 113GB GPU-accessible (with GTT configuration)
- **Bandwidth**: ~229 GB/s write, ~201 GB/s copy
- **Model Capacity**: 30B parameter models in FP16

## Best Practices

1. **Use BF16** for 1.6x speedup over FP32
2. **Keep batch size small** (1-4) for inference
3. **Data in VRAM is faster** than GTT memory
4. **Monitor memory** with `rocm-smi --showmeminfo gtt`

## Troubleshooting

If compute fails with "HIP error: invalid device function":
- You're using official PyTorch wheels (don't work with gfx1151)
- Reinstall: `pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch`

For more help, see `../STRIX_HALO_COMPLETE_GUIDE.md`
```

### Step 9: Verify Installation

Reactivate the environment and run tests:

```bash
conda deactivate
conda activate {project_name}

# Should see environment variables message
# Run verification
python scripts/test_gpu.py
```

## Success Criteria

All of these should pass:
- ✓ PyTorch detects GPU
- ✓ Compute operations succeed (no HIP errors)
- ✓ Can allocate 30GB+ memory
- ✓ BF16 operations work
- ✓ Achieves ~7 TFLOPS FP32, ~12 TFLOPS BF16

## Common Issues

### Issue: "HIP error: invalid device function"
**Solution**: Using wrong PyTorch build. Install community wheels.

### Issue: Out of memory below 30GB
**Solution**: Check GTT configuration in `/proc/cmdline`

### Issue: GPU not detected
**Solution**: Check user groups: `sudo usermod -aG render,video $USER` and reboot

## Next Steps

After setup:
1. Load your model with `device_map="cuda"`
2. Use `torch.bfloat16` for better performance
3. Monitor memory with `rocm-smi --showmeminfo gtt`
4. Consider Vulkan backend for inference (llama.cpp, Ollama)

## References

- Complete setup guide: `../STRIX_HALO_COMPLETE_GUIDE.md`
- Community PyTorch builds: https://github.com/scottt/rocm-TheRock/releases
- Strix Halo info: https://llm-tracker.info/_TOORG/Strix-Halo
