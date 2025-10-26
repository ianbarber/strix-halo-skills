# Strix Halo Setup Skill

Complete setup automation for AMD Strix Halo (Ryzen AI MAX+ 395) ML environments.

## What This Skill Provides

This is a **self-contained Claude Code skill** that handles the complete setup process for running PyTorch and large language models on Strix Halo hardware.

### Key Features

- ✅ **Solves the PyTorch Problem**: Official wheels don't work with gfx1151 - this skill installs working community builds
- ✅ **GTT Memory Configuration**: Unlocks 113GB GPU-accessible memory (vs 33GB default)
- ✅ **Complete Automation**: One skill invocation sets up everything
- ✅ **Verified Working**: Based on October 2025 testing with 30B models

## Files in This Skill

```
strix-halo-setup/
├── SKILL.md                    # Main skill (invoke with @strix-halo-setup)
├── README.md                   # This file
├── scripts/
│   ├── verify_system.sh        # System verification (checks everything)
│   ├── configure_gtt.sh        # GTT memory configuration
│   ├── test_gpu_simple.py      # Quick GPU test
│   ├── test_memory.py          # Memory capacity test
│   ├── test_llm_memory.py      # LLM capacity simulation
│   └── amd_benchmark_safe.py   # Performance benchmarks
└── docs/
    ├── COMPLETE_GUIDE.md       # Comprehensive 559-line setup guide
    ├── GTT_MEMORY_FIX.md       # GTT configuration deep-dive
    └── TROUBLESHOOTING.md      # Common issues and solutions
```

## Usage

### In Claude Code

```
@strix-halo-setup
```

Claude will guide you through:
1. System verification
2. Creating a conda environment
3. Installing working PyTorch
4. Setting up environment variables
5. Creating project structure
6. Verifying everything works

### Manual Verification

```bash
# Check your system before setup
./scripts/verify_system.sh

# After setup, test GPU
python scripts/test_gpu_simple.py
```

## Installation

### Copy to Your Project

```bash
# Copy this entire directory to your project
cp -r .claude/skills/strix-halo-setup /your-project/.claude/skills/
```

### Or Clone the Repository

```bash
git clone https://github.com/ianbarber/strix-halo-skills.git
cp -r strix-halo-skills/.claude/skills/strix-halo-setup ~/.claude/skills/
```

## What Gets Set Up

After running the skill:

**Conda Environment**:
- Python 3.12
- PyTorch 2.7+ with ROCm 6.5+ (community build)
- Transformers, accelerate, datasets
- Auto-configured environment variables

**Project Structure**:
```
your-project/
├── scripts/        # Test and verification scripts
├── notebooks/      # Jupyter notebooks
├── data/          # Dataset storage
├── models/        # Model weights
└── tests/         # Unit tests
```

**Verified Capabilities**:
- 7-12 TFLOPS compute (FP32/BF16)
- 113 GB GPU-accessible memory
- 30B parameter models in FP16

## Critical Information

### PyTorch Installation

**Official PyTorch wheels DON'T WORK** with gfx1151:
- They detect the GPU: `torch.cuda.is_available() == True`
- But fail on compute: `RuntimeError: HIP error: invalid device function`

**This skill installs working builds**:
- AMD nightlies: `rocm.nightlies.amd.com/v2/gfx1151/`
- Or scottt's builds: `github.com/scottt/rocm-TheRock/releases`

### GTT Configuration

Default: GPU can only access ~33GB
With GTT: GPU can access 113GB+ (your full system RAM)

Required for 30B+ models. The skill's `configure_gtt.sh` script automates this.

## Prerequisites

- AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151)
- Ubuntu 24.04 LTS (or similar)
- ROCm 6.4.4+ or 7.0.2
- User in `render` and `video` groups
- 64GB+ RAM for 30B models

Run `./scripts/verify_system.sh` to check everything.

## Documentation

- **SKILL.md**: Main skill with setup instructions
- **docs/COMPLETE_GUIDE.md**: Comprehensive 559-line guide
- **docs/GTT_MEMORY_FIX.md**: Memory configuration details
- **docs/TROUBLESHOOTING.md**: Common issues and solutions

## Community Resources

- **PyTorch Wheels**: https://github.com/scottt/rocm-TheRock/releases
- **ROCm Community**: https://github.com/ROCm/TheRock/discussions/655
- **Strix Halo Info**: https://llm-tracker.info/_TOORG/Strix-Halo

## License

MIT License - Copyright (c) 2025 Ian Barber

## Version

**1.0.0** - October 23, 2025

Tested on:
- Hardware: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
- ROCm: 6.4.2
- PyTorch: 2.7.0a0 + HIP 6.5.25190
- OS: Ubuntu 24.04 LTS
- Kernel: 6.14.0-33-generic
