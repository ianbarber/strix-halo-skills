# Strix Halo Skills for Claude Code

This directory contains Claude Code skills for working with AMD Strix Halo (Ryzen AI MAX+ 395, gfx1151).

## Available Skills

### `strix-halo-setup`
**Purpose**: Set up a new PyTorch project optimized for Strix Halo

**Usage in Claude Code**:
```
@strix-halo-setup
```

**What it does**:
- Checks system configuration (ROCm, GTT, user groups)
- Creates conda environment with working PyTorch for gfx1151
- Sets up environment variables automatically
- Creates project structure with test scripts
- Verifies GPU functionality

**When to use**:
- Starting a new ML project on Strix Halo
- Setting up PyTorch after system updates
- Creating isolated environments for different projects

### `QUICK_REFERENCE`
**Purpose**: Quick reference for common operations and troubleshooting

**Contains**:
- System info commands
- PyTorch installation commands
- Environment variables
- Monitoring commands
- Common issues and fixes
- Performance tips

## Automated Setup Script

For command-line setup without Claude Code:

```bash
./setup_new_project.sh
```

This script automates the entire project setup process.

## Key Information

### Critical: PyTorch Installation
**Official PyTorch wheels DON'T WORK with gfx1151**

Always use community builds:
```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch
```

### System Requirements
- ROCm 6.4.2+
- User in `render` and `video` groups
- GTT configured (`amdttm.pages_limit` in kernel params)
- Python 3.12 recommended

### Working Environment
The `rock311` conda environment already has a working setup. Use it as a reference:
```bash
conda activate rock311
```

## Documentation

- **Complete Guide**: `../STRIX_HALO_COMPLETE_GUIDE.md`
- **Update Summary**: `../UPDATE_SUMMARY_OCT2025.md`

## Community Resources

- **PyTorch Wheels**: https://github.com/scottt/rocm-TheRock/releases
- **ROCm Community**: https://github.com/ROCm/TheRock/discussions/655
- **Strix Halo Info**: https://llm-tracker.info/_TOORG/Strix-Halo

---

*Last updated: October 23, 2025*
