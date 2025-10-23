# AMD Strix Halo Skills & Setup for Claude Code

Complete setup guides, Claude Code skills, and utilities for running PyTorch and ML workloads on AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151).

## 🚀 Quick Start

### Option 1: Use as Claude Code Skills

Copy the `.claude/skills/` directory to any project:

```bash
# In your new project directory
git clone https://github.com/YOUR_USERNAME/strix-halo-skills.git /tmp/strix-halo
cp -r /tmp/strix-halo/.claude/skills .claude/
```

Then in Claude Code:
```
@strix-halo-setup
```

### Option 2: Automated Script

```bash
git clone https://github.com/YOUR_USERNAME/strix-halo-skills.git
cd strix-halo-skills
./setup_new_project.sh
```

## 📚 What's Included

### Claude Code Skills

- **`strix-halo-setup`** - Complete project setup wizard
- **`QUICK_REFERENCE`** - Quick reference guide
- **`STRIX_HALO_COMPLETE_GUIDE`** - Comprehensive documentation

### Scripts

- **`setup_new_project.sh`** - Automated project setup
- **`configure_gtt.sh`** - GTT memory configuration
- **`test_memory.py`** - Memory capacity testing
- **`test_gpu_simple.py`** - Quick GPU verification
- **`amd_benchmark_safe.py`** - Performance benchmarking
- **`test_llm_memory.py`** - LLM capacity testing

### Documentation

- **`STRIX_HALO_COMPLETE_GUIDE.md`** - Complete setup and usage guide
- **`UPDATE_SUMMARY_OCT2025.md`** - October 2025 testing results
- **`GTT_MEMORY_FIX.md`** - GTT memory configuration details
- **`TROUBLESHOOTING.md`** - Common issues and solutions

## ⚡ Key Features

### Verified Performance (October 2025)
- ✅ **30B parameter models** in FP16 (62.8 GB tested)
- ✅ **12 TFLOPS BF16** compute (7 TFLOPS FP32)
- ✅ **229 GB/s** memory bandwidth
- ✅ **113 GB** GPU-accessible memory with GTT

### Critical Information

**PyTorch Installation**: Official PyTorch wheels **DON'T WORK** with gfx1151. You must use community builds:

```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

## 🛠️ System Requirements

- **Hardware**: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
- **OS**: Ubuntu 24.04 LTS recommended
- **ROCm**: 6.4.4+ or 7.0.2
- **Kernel**: 6.14+ (6.15+ recommended)
- **RAM**: 64GB+ for 30B models

## 📖 Using in Your Project

### Method 1: Copy Skills Only

```bash
# In your project directory
mkdir -p .claude
cp -r /path/to/strix-halo-skills/.claude/skills .claude/
```

### Method 2: Git Submodule

```bash
cd your-project
git submodule add https://github.com/YOUR_USERNAME/strix-halo-skills.git .strix-halo
ln -s .strix-halo/.claude/skills .claude/skills
```

### Method 3: Direct Clone and Copy

```bash
git clone https://github.com/YOUR_USERNAME/strix-halo-skills.git
cd strix-halo-skills
./setup_new_project.sh  # Creates new project with everything set up
```

## 🎯 Quick Setup for New Project

Once you have the skills available:

1. **In Claude Code**, just say:
   ```
   @strix-halo-setup
   ```

2. **Or use the script**:
   ```bash
   ./setup_new_project.sh
   ```

3. **Or manually**:
   ```bash
   conda create -n myproject python=3.12
   conda activate myproject
   pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
   # Set up env vars from .claude/skills/strix-halo-setup.md
   ```

## 🔍 Testing Your Setup

```bash
# Quick GPU test
python -c "import torch; a=torch.tensor([1.0]).cuda(); print('✓ OK:', (a+1).item())"

# Full test suite
python test_gpu_simple.py
python test_memory.py
python amd_benchmark_safe.py --device cuda
```

## 📊 Expected Performance

| Metric | Value |
|--------|-------|
| FP32 Compute | ~7 TFLOPS |
| BF16 Compute | ~12 TFLOPS |
| Memory Bandwidth | 229 GB/s write, 201 GB/s copy |
| Max Memory | 113 GB GPU-accessible |
| 7B Models | ✅ ~14 GB |
| 13B Models | ✅ ~26 GB |
| 30B Models | ✅ ~60 GB |
| 65B Models | ❌ Needs 128GB+ RAM |

## 🐛 Common Issues

### "HIP error: invalid device function"
**Fix**: Install community PyTorch wheels for gfx1151

### GPU not detected
**Fix**: Add user to render/video groups and reboot

### Out of memory below 30GB
**Fix**: Configure GTT in GRUB (`amdttm.pages_limit=27648000`)

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more.

## 🌐 Community Resources

- **PyTorch Wheels**: https://github.com/scottt/rocm-TheRock/releases
- **ROCm Community**: https://github.com/ROCm/TheRock/discussions/655
- **Strix Halo Info**: https://llm-tracker.info/_TOORG/Strix-Halo
- **GTT Configuration**: https://www.jeffgeerling.com/blog/2025/increasing-vram-allocation-on-amd-ai-apus-under-linux

## 📝 Contributing

Issues, suggestions, and improvements welcome! This is community-maintained documentation based on real-world testing.

## 📜 License

MIT License - feel free to use, modify, and share.

## 🙏 Credits

- **Created by**: Ian Barber
- **Testing and documentation**: October 2025
- **Community PyTorch builds**: [@scottt](https://github.com/scottt/rocm-TheRock)
- **ROCm team** and community contributors
- Various community guides and research (see documentation for specific attributions)

---

**Hardware Tested**: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
**Software Stack**: ROCm 6.4.2, PyTorch 2.7.0a0, Linux 6.14, Ubuntu 24.04
**Last Updated**: October 23, 2025
