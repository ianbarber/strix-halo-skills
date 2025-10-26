# How to Use the Strix Halo Skill

This repository contains a **self-contained Claude Code skill** in `.claude/skills/strix-halo-setup/`.

## ✅ What You Have

A complete, ready-to-share skill package:

```
.claude/skills/strix-halo-setup/     (104KB, 11 files)
├── SKILL.md                         # Main skill with YAML frontmatter
├── README.md                        # Skill documentation
├── scripts/                         # 6 executable scripts
│   ├── verify_system.sh            # Complete system check
│   ├── configure_gtt.sh            # GTT memory configuration
│   ├── test_gpu_simple.py          # Quick GPU test
│   ├── test_memory.py              # Memory capacity test
│   ├── test_llm_memory.py          # LLM simulation test
│   └── amd_benchmark_safe.py       # Performance benchmarks
└── docs/                            # 3 comprehensive guides
    ├── STRIX_HALO_COMPLETE_GUIDE.md (559 lines)
    ├── GTT_MEMORY_FIX.md           # Memory config details
    └── TROUBLESHOOTING.md          # Common issues
```

## 🚀 How to Use It

### Method 1: Copy to Another Project

```bash
# In any project directory:
mkdir -p .claude/skills
cp -r /path/to/this/repo/.claude/skills/strix-halo-setup .claude/skills/

# Then in Claude Code:
@strix-halo-setup
```

### Method 2: Test Locally First

```bash
# From this repository:
cd .claude/skills/strix-halo-setup

# Run verification
./scripts/verify_system.sh

# Test GPU
python scripts/test_gpu_simple.py
```

### Method 3: Share via Git

After pushing to GitHub, others can:

```bash
# Clone and copy
git clone https://github.com/ianbarber/strix-halo-skills.git
cp -r strix-halo-skills/.claude/skills/strix-halo-setup your-project/.claude/skills/

# Or use as submodule
cd your-project
git submodule add https://github.com/ianbarber/strix-halo-skills.git .strix
ln -s .strix/.claude/skills/strix-halo-setup .claude/skills/
```

## ✨ What Makes This Self-Contained

**Everything is included in one directory:**
- ✅ All scripts (no external dependencies)
- ✅ All documentation (complete guides)
- ✅ Test suite (verify it works)
- ✅ Configuration helpers (GTT setup)

**No external files needed** - just copy `.claude/skills/strix-halo-setup/` and it works.

## 📋 Testing the Skill

### Test 1: Verify Structure

```bash
cd .claude/skills/strix-halo-setup
ls -la

# Should see:
# - SKILL.md (with YAML frontmatter)
# - README.md
# - scripts/ directory
# - docs/ directory
```

### Test 2: Check YAML Frontmatter

```bash
head -10 SKILL.md

# Should show:
# ---
# name: strix-halo-setup
# description: ...
# license: MIT
# metadata:
#   hardware: AMD Strix Halo (gfx1151)
#   ...
# ---
```

### Test 3: Run System Verification

```bash
./scripts/verify_system.sh

# This checks:
# - Hardware detection
# - ROCm installation
# - User groups
# - GTT configuration
# - PyTorch
# - GPU compute
```

### Test 4: Use in Claude Code

```bash
# In any project with the skill copied:
@strix-halo-setup
```

Claude will:
1. Check system configuration
2. Ask for project name
3. Create conda environment
4. Install working PyTorch
5. Configure environment variables
6. Create project structure
7. Verify everything works

## 🎯 What This Solves

### Problem 1: Official PyTorch Doesn't Work
**Before**: Hours of "HIP error: invalid device function" frustration
**After**: Skill installs community builds that actually work

### Problem 2: Limited Memory (33GB)
**Before**: Can only run 7B models
**After**: GTT configuration enables 30B models (113GB accessible)

### Problem 3: Complex Setup
**Before**: Manual ROCm, environment variables, conda setup
**After**: One skill invocation automates everything

## 📦 Repository vs Skill

**Repository** (what you're publishing):
```
strix-halo-skills/
├── .claude/skills/strix-halo-setup/  ← THE SKILL (copy this)
├── README.md                         ← Repo overview
├── GETTING_STARTED.md                ← How to use
├── CHANGELOG.md                      ← Version history
├── LICENSE                           ← MIT license
└── archive/                          ← Development files
```

**Skill** (what users copy):
```
strix-halo-setup/  ← Just this directory
├── SKILL.md       ← Everything needed
├── scripts/       ← is in here
└── docs/          ← or here
```

## ✅ Verification Checklist

Before sharing:
- [x] SKILL.md has valid YAML frontmatter
- [x] Directory name matches skill name (strix-halo-setup)
- [x] All scripts are executable
- [x] All docs are present
- [x] No external dependencies
- [x] No hardcoded paths or names
- [x] License included
- [x] README explains usage
- [x] Tested on real hardware (October 2025)

## 🚀 Ready to Share!

Your skill is **production-ready** and follows Claude Code best practices.

**To publish:**
```bash
git remote add origin https://github.com/ianbarber/strix-halo-skills.git
git push -u origin main
```

**To use in another project:**
```bash
cp -r .claude/skills/strix-halo-setup /other-project/.claude/skills/
```

That's it! Self-contained, portable, ready to share. 🎉
