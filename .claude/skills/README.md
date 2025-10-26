# Strix Halo Skills for Claude Code

This directory contains a **self-contained skill** for setting up AMD Strix Halo (Ryzen AI MAX+ 395) for ML workloads.

## Skills Available

### `strix-halo-setup`

Complete automated setup for PyTorch and ML on Strix Halo hardware.

**Usage in Claude Code:**
```
@strix-halo-setup
```

**What it does:**
- Verifies system configuration (ROCm, GTT, user groups)
- Creates conda environment with working PyTorch (official wheels don't work!)
- Configures environment variables automatically
- Sets up project structure with test scripts
- Verifies everything is working correctly

**Key problem solved:** Official PyTorch wheels detect GPU but fail on compute with gfx1151. This skill installs community builds that actually work.

## Installation

### Copy to Your Project

```bash
# Copy the entire strix-halo-setup directory
cp -r .claude/skills/strix-halo-setup /your-project/.claude/skills/
```

### Or Use as Git Submodule

```bash
cd your-project
git submodule add https://github.com/ianbarber/strix-halo-skills.git .strix-skills
ln -s .strix-skills/.claude/skills/strix-halo-setup .claude/skills/
```

## What's Included

Each skill is a complete, self-contained directory:

```
strix-halo-setup/
├── SKILL.md                    # Main skill (Claude reads this)
├── README.md                   # Skill documentation
├── scripts/
│   ├── verify_system.sh        # System verification
│   ├── configure_gtt.sh        # GTT memory configuration
│   ├── test_gpu_simple.py      # Quick GPU test
│   ├── test_memory.py          # Memory capacity test
│   ├── test_llm_memory.py      # LLM capacity simulation
│   └── amd_benchmark_safe.py   # Performance benchmarks
└── docs/
    ├── COMPLETE_GUIDE.md       # Comprehensive setup guide (559 lines)
    ├── GTT_MEMORY_FIX.md       # Memory configuration details
    └── TROUBLESHOOTING.md      # Common issues and solutions
```

## Using the Skill

Once copied to your project's `.claude/skills/` directory, invoke it in Claude Code:

```
@strix-halo-setup
```

Claude will guide you through the complete setup process.

## Verified Capabilities

Based on October 2025 testing:

- ✅ **30B parameter models** in FP16 (62.8 GB tested)
- ✅ **12 TFLOPS BF16** compute (7 TFLOPS FP32)
- ✅ **229 GB/s** memory bandwidth
- ✅ **113 GB** GPU-accessible memory with GTT configuration

## Prerequisites

- AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151)
- ROCm 6.4.4+ or 7.0.2
- Ubuntu 24.04 LTS (or similar)
- User in `render` and `video` groups

Run the verification script to check:
```bash
.claude/skills/strix-halo-setup/scripts/verify_system.sh
```

## Quick Start

1. **Copy skill to your project**
2. **In Claude Code, type**: `@strix-halo-setup`
3. **Follow the guided setup**
4. **Verify with**: `python scripts/test_gpu_simple.py`

## Documentation

- **SKILL.md**: Main skill with step-by-step setup
- **docs/COMPLETE_GUIDE.md**: Comprehensive reference (559 lines)
- **docs/TROUBLESHOOTING.md**: Common issues and solutions
- **docs/GTT_MEMORY_FIX.md**: Memory configuration deep-dive

## License

MIT License - Copyright (c) 2025 Ian Barber

## More Information

Repository: https://github.com/ianbarber/strix-halo-skills
