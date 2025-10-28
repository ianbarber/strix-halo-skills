# Strix Halo Skills for Claude Code

Claude Code skill for setting up AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151) for ML workloads.

> **Disclaimer**: Developed with Claude Code and tested on Ubuntu 24.04 LTS. May need adjustments for other distributions.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/ianbarber/strix-halo-skills.git

# Copy the skill to your project
cp -r strix-halo-skills/.claude/skills/strix-halo-setup your-project/.claude/skills/

# In Claude Code:
@strix-halo-setup
```

The skill will verify your system, create a conda environment, install PyTorch, and set up proper configuration.

## What's Included

```
.claude/skills/strix-halo-setup/
├── SKILL.md                    # Main skill
├── README.md                   # Skill documentation
├── scripts/
│   ├── verify_system.sh        # System verification
│   ├── configure_gtt.sh        # GTT memory configuration
│   ├── test_gpu_simple.py      # GPU test
│   ├── test_memory.py          # Memory test
│   ├── test_llm_memory.py      # LLM capacity test
│   └── amd_benchmark_safe.py   # Benchmarks
└── docs/
    ├── GTT_MEMORY_FIX.md       # GTT configuration guide
    └── TROUBLESHOOTING.md      # Common issues

CHANGELOG.md                    # Version history
CLAUDE.md                       # Project context for Claude
AGENTS.md                       # Maintenance guidelines
LICENSE                         # MIT License
```

## Problems This Solves

### PyTorch Installation

Official PyTorch wheels don't work with gfx1151. GPU is detected but compute operations fail with "HIP error: invalid device function". This skill installs community builds that work:

```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

### GTT Memory Configuration

By default, GPU can only access ~33GB. The skill helps configure GTT to access more system RAM, enabling larger models.

## Capabilities

Tested on 64GB RAM system with GTT configured:

- 30B parameter models in FP16
- 113GB GPU-accessible memory
- Works with ROCm 6.4.4+ or 7.0.2

## Model Support

| Model Size | Memory Needed | Works with Default | Works with GTT |
|------------|---------------|-------------------|----------------|
| 7B FP16 | ~14 GB | ✅ | ✅ |
| 13B FP16 | ~26 GB | ✅ | ✅ |
| 30B FP16 | ~60 GB | ❌ | ✅ |
| 65B FP16 | ~130 GB | ❌ | ❌ (needs 128GB+ RAM) |

## System Verification

Check your system before setup:

```bash
./claude/skills/strix-halo-setup/scripts/verify_system.sh
```

Checks: hardware, ROCm, user groups, GTT, Python, PyTorch, and GPU compute.

## Prerequisites

- AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151)
- Ubuntu 24.04 LTS (or similar)
- ROCm 6.4.4+ or 7.0.2
- User in `render` and `video` groups
- 64GB+ RAM recommended for 30B models

## FAQ

**Will official PyTorch wheels work?**
No. Use community builds from AMD nightlies or scottt's repository.

**How much RAM do I need?**
7B-13B models work with default ~33GB. 30B models require 64GB+ RAM and GTT configuration.

**Should I use ROCm or Vulkan?**
ROCm for PyTorch/training. Vulkan for inference (llama.cpp, Ollama).

**What if I get "HIP error: invalid device function"?**
You're using official PyTorch wheels. Reinstall with community builds (see skill).

## Community Resources

- PyTorch Wheels: https://github.com/scottt/rocm-TheRock/releases
- ROCm Community: https://github.com/ROCm/TheRock/discussions/655
- Strix Halo Info: https://llm-tracker.info/_TOORG/Strix-Halo

## License

MIT License - Copyright (c) 2025 Ian Barber

## Credits

- Created by: Ian Barber
- Community PyTorch builds: [@scottt](https://github.com/scottt/rocm-TheRock)
- ROCm team and community contributors
