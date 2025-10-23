#!/bin/bash

# AMD Strix Halo ROCm Environment Setup
# Enables full unified memory access and performance optimizations

echo "Setting up ROCm environment for AMD Strix Halo..."

# Core ROCm settings for Strix Halo (gfx1151)
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PYTORCH_ROCM_ARCH=gfx1151

# Unified Memory Configuration - CRITICAL for accessing full 128GB
export HSA_XNACK=1  # Enable unified memory page fault handling
export HSA_FORCE_FINE_GRAIN_PCIE=1  # Force fine-grained memory access

# Memory allocation settings
export GPU_MAX_HEAP_SIZE=100  # Allow GPU to use up to 100% of available memory
export GPU_MAX_ALLOC_PERCENT=100  # Allow single allocation up to 100% of VRAM

# Device visibility
export ROCR_VISIBLE_DEVICES=0
export HIP_VISIBLE_DEVICES=0
export CUDA_VISIBLE_DEVICES=0

# Performance optimizations
export ROCBLAS_TENSILE_LIBPATH=/opt/rocm/lib/rocblas/library
export HIPBLASLT_TENSILE_LIBPATH=/opt/rocm/lib/hipblaslt/library
export MIOPEN_ENABLE_LOGGING=0  # Disable MIOpen logging for performance
export MIOPEN_ENABLE_LOGGING_CMD=0
export MIOPEN_LOG_LEVEL=0

# Wave optimization for RDNA3
export HSA_CU_MASK=0xffffffffffffffff  # Enable all CUs
export AMD_LOG_LEVEL=0  # Reduce logging overhead

# Optional: Force specific memory pool size (in MB)
# export HSA_OVERRIDE_GFX_MEM_POOL_SIZE=98304  # 96GB in MB

echo "Environment variables set:"
echo "  HSA_XNACK=$HSA_XNACK (Unified memory enabled)"
echo "  HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION"
echo "  PYTORCH_ROCM_ARCH=$PYTORCH_ROCM_ARCH"
echo "  GPU_MAX_HEAP_SIZE=$GPU_MAX_HEAP_SIZE%"
echo "  GPU_MAX_ALLOC_PERCENT=$GPU_MAX_ALLOC_PERCENT%"

# Check available memory
if command -v rocm-smi &> /dev/null; then
    echo ""
    echo "GPU Memory Information:"
    rocm-smi --showmeminfo vram
    rocm-smi --showmeminfo gtt
fi

echo ""
echo "Setup complete! You can now run benchmarks with full memory access."