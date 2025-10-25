# Getting Started with Strix Halo

Welcome! This guide will help you set up your AMD Strix Halo for running PyTorch and large language models.

## ⏱️ Time Required

- **Quick test**: 5 minutes
- **Full setup**: 20-30 minutes
- **GTT configuration** (optional): +30 minutes

## ✅ Prerequisites Check

**Quick Check (Recommended)**:
```bash
# Run the verification script (checks everything)
./scripts/verify_system.sh
```

This will check ROCm, user groups, GTT, PyTorch, and GPU compute in one go.

**Manual Check**:
```bash
# 1. Check you have Strix Halo
lspci | grep -i amd | grep -i vga
# Should show: AMD Radeon Graphics or similar

# 2. Check ROCm is installed
rocm-smi --version
# If not installed: See "Installing ROCm" below

# 3. Check you're in the right groups
groups | grep -E "render|video"
# If not shown: See "User Groups" below

# 4. Check system RAM
free -h
# Minimum 64GB recommended for 30B models
```

### Installing ROCm (If Needed)

```bash
# Download installer
wget https://repo.radeon.com/amdgpu-install/6.4.4/ubuntu/noble/amdgpu-install_6.4.60402-1_all.deb

# Install
sudo apt install ./amdgpu-install_6.4.60402-1_all.deb

# Install ROCm (use --no-dkms for APUs)
sudo amdgpu-install --usecase=rocm --no-dkms

# Reboot
sudo reboot

# Verify
rocm-smi
```

### User Groups (If Needed)

```bash
# Add yourself to groups
sudo usermod -aG render,video $USER

# Log out and log back in (or reboot)
# Then verify
groups | grep -E "render|video"
```

## 🚀 Quick Start (Choose One Method)

### Method 1: Automated Script (Easiest)

```bash
# Clone this repository
git clone https://github.com/ianbarber/strix-halo-skills.git
cd strix-halo-skills

# Run the setup script
./setup_new_project.sh

# Follow the prompts - it will:
# - Check your system
# - Create a conda environment
# - Install working PyTorch
# - Set up test scripts
# - Verify everything works
```

### Method 2: Claude Code Skill (Recommended)

```bash
# Clone this repository to get the skills
git clone https://github.com/ianbarber/strix-halo-skills.git
cd strix-halo-skills

# In Claude Code, just type:
@strix-halo-setup

# Claude will guide you through the entire setup process
```

### Method 3: Manual Setup

See [STRIX_HALO_COMPLETE_GUIDE.md](STRIX_HALO_COMPLETE_GUIDE.md) for step-by-step manual instructions.

## ✨ What Happens During Setup

The automated setup will:

1. **Check System** (1 min)
   - Verify ROCm installation
   - Check user permissions
   - Confirm hardware

2. **Create Environment** (2 min)
   - Create Python 3.12 conda environment
   - Name it based on your project

3. **Install PyTorch** (10-15 min)
   - **Critical**: Installs community builds (official wheels don't work!)
   - From AMD nightlies for gfx1151
   - Includes torchvision and torchaudio

4. **Configure Environment** (1 min)
   - Sets up automatic environment variables
   - Optimizes for Strix Halo performance

5. **Create Test Scripts** (1 min)
   - GPU detection test
   - Memory capacity test
   - Benchmark scripts

6. **Verify Setup** (2 min)
   - Tests GPU detection
   - Tests compute operations
   - Confirms everything works

## ✅ Success Looks Like

After setup completes, you should see:

```bash
# GPU is detected
$ python -c "import torch; print(torch.cuda.is_available())"
True

# Compute works (no "HIP error: invalid device function")
$ python -c "import torch; a=torch.tensor([1.0]).cuda(); print((a+1).item())"
2.0

# Memory is available
$ python scripts/test_gpu.py
============================================================
STRIX HALO GPU TEST
============================================================
✓ GPU detected: AMD Radeon Graphics
  Memory: 113.2 GB

✓ ALL TESTS PASSED
============================================================
```

## 🎯 What You Can Do Next

### Try a Small Model (7B)

```bash
conda activate your-project-name

python << EOF
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    torch_dtype=torch.bfloat16,
    device_map="cuda"
)

tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-2-7b-hf")

prompt = "Hello, I am"
inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
outputs = model.generate(**inputs, max_length=50)
print(tokenizer.decode(outputs[0]))
EOF
```

### Run Benchmarks

```bash
# Test compute performance
python scripts/benchmark_compute.py

# Test memory capacity
python scripts/benchmark_memory.py
```

### Try a Larger Model (13B or 30B)

With GTT configured, you can run models up to 30B parameters:

```python
# 13B model (~26GB memory)
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-13b-hf",
    torch_dtype=torch.bfloat16,
    device_map="cuda"
)

# 30B model (~60GB memory) - requires GTT configuration
model = AutoModelForCausalLM.from_pretrained(
    "model-30b",
    torch_dtype=torch.bfloat16,
    device_map="cuda"
)
```

## ❓ Common First-Time Issues

### "GPU not detected" (`torch.cuda.is_available()` returns `False`)

**Cause**: Not in render/video groups

**Fix**:
```bash
sudo usermod -aG render,video $USER
# Log out and back in, then try again
```

### "HIP error: invalid device function"

**Cause**: Using official PyTorch wheels (they don't work with gfx1151)

**Fix**: Re-run setup script, or manually install:
```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

### "Out of memory" with small models (< 30GB)

**Cause**: GTT not configured (you're limited to ~30GB)

**Fix**: See [GTT_MEMORY_FIX.md](GTT_MEMORY_FIX.md) or run:
```bash
./configure_gtt.sh
```

## 📊 Expected Performance

After setup, you should achieve:

| Metric | Your Hardware | Reference (Desktop GPU) |
|--------|---------------|------------------------|
| FP32 Compute | ~7 TFLOPS | RTX 4090: 82 TFLOPS |
| BF16 Compute | ~12 TFLOPS | RTX 4090: 165 TFLOPS |
| Memory | 113 GB (with GTT) | RTX 4090: 24 GB |
| Bandwidth | 229 GB/s | RTX 4090: 1000 GB/s |

**Key Advantage**: Memory capacity! You can run 30B models that won't fit on most desktop GPUs.

**Trade-off**: Lower compute, but enough for inference and fine-tuning smaller models.

## 📚 Learn More

- **Complete Setup Guide**: [STRIX_HALO_COMPLETE_GUIDE.md](STRIX_HALO_COMPLETE_GUIDE.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **GTT Memory Configuration**: [GTT_MEMORY_FIX.md](GTT_MEMORY_FIX.md)
- **Performance Details**: [UPDATE_SUMMARY_OCT2025.md](UPDATE_SUMMARY_OCT2025.md)

## 🆘 Need Help?

1. **Check troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. **Review the complete guide**: [STRIX_HALO_COMPLETE_GUIDE.md](STRIX_HALO_COMPLETE_GUIDE.md)
3. **Run diagnostics**: `python deep_debug.py`
4. **Check GitHub issues**: https://github.com/ianbarber/strix-halo-skills/issues

## 🎉 Success!

Once you see "ALL TESTS PASSED", you're ready to run large language models on your Strix Halo!

**Next Steps**:
1. Try loading a 7B model
2. Run benchmarks to see your performance
3. Consider configuring GTT for 30B+ models
4. Join the community and share your results

---

**Ready to publish this repo?** See [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md)
