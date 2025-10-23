#!/bin/bash
# Strix Halo New Project Setup Script
# Automates creation of PyTorch project optimized for gfx1151

set -e

echo "================================================"
echo "  Strix Halo Project Setup"
echo "================================================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check ROCm
if ! command -v rocm-smi &> /dev/null; then
    echo "❌ ROCm not found. Please install ROCm 6.4.2+ first."
    exit 1
fi
echo "✓ ROCm installed: $(rocm-smi --version | head -1)"

# Check user groups
if ! groups | grep -qE "render|video"; then
    echo "❌ User not in render/video groups"
    echo "   Run: sudo usermod -aG render,video $USER"
    echo "   Then log out and back in"
    exit 1
fi
echo "✓ User in render/video groups"

# Check GTT configuration
if ! cat /proc/cmdline | grep -q "amdttm.pages_limit"; then
    echo "⚠ GTT not configured - you may have limited memory"
    echo "  See STRIX_HALO_COMPLETE_GUIDE.md for setup"
else
    echo "✓ GTT configured"
fi

# Check conda
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install miniforge/miniconda first."
    exit 1
fi
echo "✓ Conda available"

echo ""

# Get project name
read -p "Enter project name: " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name cannot be empty"
    exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
    echo "❌ Directory $PROJECT_NAME already exists"
    exit 1
fi

echo ""
echo "Creating project: $PROJECT_NAME"
echo ""

# Create conda environment
echo "Creating conda environment..."
conda create -n "$PROJECT_NAME" python=3.12 -y

# Activate environment
eval "$(conda shell.bash hook)"
conda activate "$PROJECT_NAME"

# Install PyTorch from AMD nightlies
echo ""
echo "Installing PyTorch (community build for gfx1151)..."
echo "This may take a few minutes..."
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch torchvision torchaudio

# Install common ML libraries
echo ""
echo "Installing ML libraries..."
pip install numpy transformers accelerate datasets

# Create environment variable scripts
echo ""
echo "Configuring environment variables..."
mkdir -p "$CONDA_PREFIX/etc/conda/activate.d"
cat > "$CONDA_PREFIX/etc/conda/activate.d/env_vars.sh" << 'EOF'
#!/bin/bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PYTORCH_ROCM_ARCH=gfx1151
export HSA_XNACK=1
export HSA_FORCE_FINE_GRAIN_PCIE=1
export GPU_MAX_HEAP_SIZE=100
export GPU_MAX_ALLOC_PERCENT=100
export ROCR_VISIBLE_DEVICES=0
export HIP_VISIBLE_DEVICES=0
export ROCBLAS_USE_HIPBLASLT=1
export AMD_LOG_LEVEL=0
export HSA_CU_MASK=0xffffffffffffffff
echo "✓ Strix Halo environment variables set"
EOF

chmod +x "$CONDA_PREFIX/etc/conda/activate.d/env_vars.sh"

mkdir -p "$CONDA_PREFIX/etc/conda/deactivate.d"
cat > "$CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh" << 'EOF'
#!/bin/bash
unset HSA_OVERRIDE_GFX_VERSION PYTORCH_ROCM_ARCH HSA_XNACK HSA_FORCE_FINE_GRAIN_PCIE
unset GPU_MAX_HEAP_SIZE GPU_MAX_ALLOC_PERCENT ROCR_VISIBLE_DEVICES HIP_VISIBLE_DEVICES
unset ROCBLAS_USE_HIPBLASLT AMD_LOG_LEVEL HSA_CU_MASK
EOF

chmod +x "$CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh"

# Create project structure
echo ""
echo "Creating project structure..."
mkdir -p "$PROJECT_NAME"/{scripts,notebooks,data,models,tests}
cd "$PROJECT_NAME"

# Create test_gpu.py
cat > scripts/test_gpu.py << 'EOFPY'
#!/usr/bin/env python3
"""Test GPU availability and basic compute on Strix Halo"""
import torch
import sys

def test_gpu():
    print("="*60)
    print("STRIX HALO GPU TEST")
    print("="*60)

    if not torch.cuda.is_available():
        print("❌ GPU not detected")
        sys.exit(1)

    print(f"✓ GPU detected: {torch.cuda.get_device_name(0)}")
    props = torch.cuda.get_device_properties(0)
    print(f"  Memory: {props.total_memory / 1e9:.1f} GB")

    print("\nTesting compute...")
    try:
        a = torch.randn(1000, 1000, device='cuda')
        b = torch.randn(1000, 1000, device='cuda')
        c = torch.matmul(a, b)
        torch.cuda.synchronize()
        print("  ✓ Compute successful")
    except Exception as e:
        print(f"  ❌ Compute failed: {e}")
        sys.exit(1)

    print("\n" + "="*60)
    print("✓ ALL TESTS PASSED")
    print("="*60)

if __name__ == "__main__":
    test_gpu()
EOFPY

chmod +x scripts/test_gpu.py

# Create README
cat > README.md << EOFMD
# $PROJECT_NAME

PyTorch project optimized for AMD Strix Halo (gfx1151).

## Setup

\`\`\`bash
conda activate $PROJECT_NAME
python scripts/test_gpu.py
\`\`\`

## Hardware Capabilities

- **Compute**: ~7 TFLOPS FP32, ~12 TFLOPS BF16
- **Memory**: Up to 113GB GPU-accessible
- **Model Capacity**: 30B parameter models in FP16

## Best Practices

1. Use BF16 for 1.6x speedup
2. Keep batch size small (1-4) for inference
3. Monitor memory: \`rocm-smi --showmeminfo gtt\`

Created: $(date +%Y-%m-%d)
EOFMD

# Create .gitignore
cat > .gitignore << 'EOFGIT'
# Data and models
data/
models/
*.pth
*.pt
*.bin
*.safetensors

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/

# Jupyter
.ipynb_checkpoints
*.ipynb

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
EOFGIT

cd ..

echo ""
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo ""
echo "To get started:"
echo ""
echo "  cd $PROJECT_NAME"
echo "  conda activate $PROJECT_NAME"
echo "  python scripts/test_gpu.py"
echo ""
echo "Project structure:"
echo "  $PROJECT_NAME/"
echo "    ├── scripts/      - Python scripts"
echo "    ├── notebooks/    - Jupyter notebooks"
echo "    ├── data/         - Dataset storage"
echo "    ├── models/       - Model weights"
echo "    └── tests/        - Unit tests"
echo ""
echo "See STRIX_HALO_COMPLETE_GUIDE.md for more information"
echo ""
