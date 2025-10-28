# Strix Halo Skills for Claude Code

A **self-contained Claude Code skill** for setting up AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151) for ML workloads.

> **⚠️ Disclaimer**: This skill was developed with Claude Code and tested only on Ubuntu 24.04 LTS. While the scripts follow best practices, they may need adjustments for other distributions or configurations. Community testing and feedback welcome!

## 🚀 Quick Start

### Use the Skill

```bash
# Clone this repository
git clone https://github.com/ianbarber/strix-halo-skills.git

# Copy the skill to your project
cp -r strix-halo-skills/.claude/skills/strix-halo-setup your-project/.claude/skills/

# In Claude Code:
@strix-halo-setup
```

Claude will guide you through the complete setup process.

### Or Use the Scripts Directly

```bash
cd strix-halo-skills/.claude/skills/strix-halo-setup

# Verify your system
./scripts/verify_system.sh

# Configure GTT memory (for 30B+ models)
./scripts/configure_gtt.sh
```

## ⭐ What This Solves

### The #1 Strix Halo Problem: PyTorch Installation

**Problem**: Official PyTorch wheels from pytorch.org **DON'T WORK** with gfx1151:
- GPU is detected: `torch.cuda.is_available() == True` ✓
- But compute fails: `RuntimeError: HIP error: invalid device function` ✗

**Solution**: This skill installs community builds that actually work:
```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

### GTT Memory Configuration

**Problem**: GPU can only access ~33GB by default (limits you to 7B models)

**Solution**: Configure GTT to access 113GB+ for running 30B parameter models

## 📦 What's Included

### Complete Self-Contained Skill

```
.claude/skills/strix-halo-setup/
├── SKILL.md                    # Main skill (invoke with @strix-halo-setup)
├── README.md                   # Skill documentation
├── scripts/
│   ├── verify_system.sh        # Complete system verification
│   ├── configure_gtt.sh        # GTT memory configuration
│   ├── test_gpu_simple.py      # Quick GPU test
│   ├── test_memory.py          # Memory capacity test
│   ├── test_llm_memory.py      # LLM capacity simulation
│   └── amd_benchmark_safe.py   # Performance benchmarks
└── docs/
    ├── COMPLETE_GUIDE.md       # Comprehensive 559-line setup guide
    ├── GTT_MEMORY_FIX.md       # Memory configuration deep-dive
    └── TROUBLESHOOTING.md      # Common issues and solutions
```

### Additional Documentation

- **GETTING_STARTED.md** - First-time user guide
- **USAGE_IN_OTHER_PROJECTS.md** - Integration guide
- **CHANGELOG.md** - Version history
- **PUBLISHING_GUIDE.md** - How to share/contribute

## ✅ Verified Performance (October 2025)

**Tested on real hardware:**
- ✅ **30B parameter models** in FP16 (62.8 GB tested)
- ✅ **12 TFLOPS BF16** compute (7 TFLOPS FP32)
- ✅ **229 GB/s** memory bandwidth
- ✅ **113 GB** GPU-accessible memory with GTT

**Test configuration:**
- Hardware: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
- ROCm: 6.4.2 with PyTorch 2.7.0a0 + HIP 6.5.25190
- OS: Ubuntu 24.04 LTS, Kernel 6.14.0-33-generic
- RAM: 64GB

## 🎯 Usage

### Method 1: Copy Skill to Your Project (Recommended)

```bash
# Copy the complete skill
cp -r .claude/skills/strix-halo-setup /your-project/.claude/skills/

# In Claude Code:
@strix-halo-setup
```

### Method 2: Git Submodule

```bash
cd your-project
git submodule add https://github.com/ianbarber/strix-halo-skills.git .strix
ln -s .strix/.claude/skills/strix-halo-setup .claude/skills/
```

### Method 3: Direct Script Usage

```bash
# Just run the verification script
./claude/skills/strix-halo-setup/scripts/verify_system.sh
```

## 🔍 System Verification

Check if your system is ready:

```bash
./claude/skills/strix-halo-setup/scripts/verify_system.sh
```

This checks:
- AMD GPU detection
- ROCm installation (6.4.4+ or 7.0.2)
- User groups (render/video)
- GTT configuration
- Python/Conda
- PyTorch installation
- GPU compute functionality

**Color-coded output:**
- ✓ **Green**: Working correctly
- ✗ **Red**: Critical issue (needs fixing)
- ⚠ **Yellow**: Warning (works but not optimal)

## 📊 What You Can Run

| Model Size | Memory Needed | Status on Strix Halo | Status on RTX 4090 |
|------------|---------------|---------------------|-------------------|
| **7B FP16** | ~14 GB | ✅ Works | ✅ Works |
| **13B FP16** | ~26 GB | ✅ Works | ✅ Works |
| **30B FP16** | ~60 GB | ✅ Works (with GTT) | ❌ Won't fit (24GB) |
| **65B FP16** | ~130 GB | ❌ Needs 128GB+ RAM | ❌ Won't fit |

**Key Advantage**: Memory capacity! With GTT configured, you have 113GB GPU-accessible memory. This lets you run 30B parameter models that won't fit on most consumer GPUs.

**Note**: Compute performance is lower than discrete GPUs, but sufficient for inference and experimentation.

## ❓ FAQ

### Will official PyTorch wheels work?
**No.** They detect GPU but fail on compute. You must use community builds (this skill handles it).

### How much RAM do I need?
- **7B models**: Works with default ~33GB
- **13B models**: Works with default ~33GB
- **30B models**: Requires 64GB+ RAM and GTT configuration
- **65B models**: Requires 128GB+ RAM

### Should I use ROCm or Vulkan?
- **ROCm/HIP**: For PyTorch, training, custom code
- **Vulkan**: For inference (llama.cpp, Ollama) - often 10-20% faster

### What if I get "HIP error: invalid device function"?
You're using official PyTorch wheels. Reinstall with:
```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

## 🛠️ Prerequisites

- **Hardware**: AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151)
- **OS**: Ubuntu 24.04 LTS recommended (Linux kernel 6.14+)
- **ROCm**: 6.4.4+ or 7.0.2
- **RAM**: 64GB+ for 30B models
- **User groups**: Must be in `render` and `video` groups

## 📚 Documentation

- **`.claude/skills/strix-halo-setup/SKILL.md`** - Main skill with setup steps
- **`.claude/skills/strix-halo-setup/docs/COMPLETE_GUIDE.md`** - 559-line comprehensive guide
- **`GETTING_STARTED.md`** - First-time user walkthrough
- **`CHANGELOG.md`** - Version history and updates

## 🌐 Community Resources

- **PyTorch Wheels**: https://github.com/scottt/rocm-TheRock/releases
- **ROCm Community**: https://github.com/ROCm/TheRock/discussions/655
- **Strix Halo Info**: https://llm-tracker.info/_TOORG/Strix-Halo
- **GTT Guide**: https://www.jeffgeerling.com/blog/2025/increasing-vram-allocation-on-amd-ai-apus-under-linux

## 📝 Contributing

Issues and improvements welcome! This is actively maintained based on real-world testing.

See **PUBLISHING_GUIDE.md** for contribution guidelines.

## 📜 License

MIT License - Copyright (c) 2025 Ian Barber

## 🙏 Credits

- **Created by**: Ian Barber
- **Community PyTorch builds**: [@scottt](https://github.com/scottt/rocm-TheRock)
- **ROCm team** and community contributors
- Testing based on community research from llm-tracker.info, Jeff Geerling, and ROCm/TheRock

---

**Hardware Tested**: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
**Last Updated**: October 25, 2025
**Version**: 1.0.0
