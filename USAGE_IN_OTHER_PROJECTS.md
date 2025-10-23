# Using Strix Halo Skills in Other Projects

This guide shows you how to use the Strix Halo skills in any project.

## 🚀 Quick Test

Let's test the skills by creating a new test project.

### Step 1: Create a Test Project Directory

```bash
# Create a new project directory
mkdir ~/test-strix-project
cd ~/test-strix-project
```

### Step 2: Copy the Skills

**Option A: Copy from this repository**

```bash
# Copy skills from the amdtest directory
cp -r ~/Projects/amdtest/.claude .
```

**Option B: Clone from GitHub (after pushing)**

```bash
# Clone and copy skills
git clone https://github.com/YOUR_USERNAME/strix-halo-skills.git /tmp/strix-skills
cp -r /tmp/strix-skills/.claude .
```

### Step 3: Verify Skills Are Available

```bash
ls -la .claude/skills/
# Should show:
# - strix-halo-setup.md
# - QUICK_REFERENCE.md
# - STRIX_HALO_COMPLETE_GUIDE.md
# - README.md
```

### Step 4: Use in Claude Code

Open Claude Code in your test project:

```bash
code .
```

Then in Claude Code, type:

```
@strix-halo-setup
```

Claude will now have access to the skill and can help you set up a new Strix Halo project!

## 📋 What the Skill Does

When you invoke `@strix-halo-setup`, Claude will:

1. **Check System Configuration**
   - Verify ROCm installation
   - Check GTT configuration
   - Verify user groups

2. **Create Conda Environment**
   - Python 3.12
   - Project-specific name

3. **Install PyTorch**
   - Community builds for gfx1151
   - From AMD nightlies or scottt's repo

4. **Configure Environment Variables**
   - HSA settings for gfx1151
   - Unified memory configuration
   - Performance optimizations

5. **Create Project Structure**
   - scripts/, notebooks/, data/, models/, tests/
   - Test scripts for GPU verification
   - README with project-specific info

6. **Verify Everything Works**
   - GPU detection test
   - Compute test
   - Memory test

## 🎯 Example Session

Here's what a typical session looks like:

```
You: @strix-halo-setup

Claude: I'll help you set up a new Strix Halo PyTorch project.
First, let me check your system configuration...

[Checks ROCm, GTT, user groups]

What would you like to name your project?

You: my-llm-project

Claude: Creating environment 'my-llm-project' with Python 3.12...
Installing PyTorch from AMD nightlies for gfx1151...
Setting up environment variables...
Creating project structure...

Done! Your project is ready. To get started:
  conda activate my-llm-project
  python scripts/test_gpu.py
```

## 🔄 Alternative: Use the Automated Script

If you prefer command-line setup without Claude Code:

```bash
# Copy the setup script
cp ~/Projects/amdtest/setup_new_project.sh .

# Run it
./setup_new_project.sh

# Follow the prompts
```

## 📦 For Long-Term Use

### Method 1: Git Submodule (Recommended)

If your project is a git repo:

```bash
cd your-project
git submodule add https://github.com/YOUR_USERNAME/strix-halo-skills.git .strix-halo
ln -s .strix-halo/.claude/skills .claude/skills
```

This way you can pull updates:

```bash
git submodule update --remote
```

### Method 2: Copy and Version

Copy the skills and commit them to your repo:

```bash
cp -r /path/to/strix-halo-skills/.claude .
git add .claude
git commit -m "Add Strix Halo Claude Code skills"
```

### Method 3: Global Skills (All Projects)

If you want these skills available in ALL your projects:

```bash
# Create a global skills directory
mkdir -p ~/.claude/skills

# Copy skills there
cp ~/Projects/amdtest/.claude/skills/* ~/.claude/skills/

# Claude Code will check this location for skills
```

## 🧪 Testing the Setup

After setting up a new project with the skills:

### 1. Quick GPU Test

```bash
conda activate your-project-name
python -c "import torch; a=torch.tensor([1.0]).cuda(); print('✓ GPU Works:', (a+1).item())"
```

Expected output:
```
✓ GPU Works: 2.0
```

### 2. Full Test Suite

```bash
python scripts/test_gpu.py
```

Should show:
```
============================================================
STRIX HALO GPU TEST
============================================================
✓ GPU detected: AMD Radeon Graphics
  Memory: 113.2 GB

Testing compute...
  ✓ Compute successful

============================================================
✓ ALL TESTS PASSED
============================================================
```

### 3. Memory Capacity Test

```bash
python scripts/benchmark_memory.py
```

Should successfully allocate 30GB+ memory.

## 🔍 Quick Reference

Once skills are installed, you can also use:

```
@QUICK_REFERENCE
```

This gives you quick access to:
- Common commands
- Troubleshooting tips
- Performance optimization
- Environment variables

## 📚 Full Documentation

Access the complete guide:

```
@STRIX_HALO_COMPLETE_GUIDE
```

Or directly:

```bash
cat .claude/skills/STRIX_HALO_COMPLETE_GUIDE.md
```

## 🐛 Troubleshooting

### Skills Not Found

If Claude Code doesn't find your skills:

1. Check directory structure:
   ```bash
   ls .claude/skills/
   ```

2. Restart Claude Code

3. Verify skills are markdown files (`.md`)

### Skill Doesn't Run Correctly

1. Check the skill file isn't corrupted:
   ```bash
   head .claude/skills/strix-halo-setup.md
   ```

2. Update to latest version:
   ```bash
   cp -r ~/Projects/amdtest/.claude/skills/* .claude/skills/
   ```

## 🚢 Publishing to GitHub

When ready to share:

```bash
cd ~/Projects/amdtest

# Create repo on GitHub (YOUR_USERNAME/strix-halo-skills)

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/strix-halo-skills.git
git branch -M main
git push -u origin main
```

Then others can use:

```bash
git clone https://github.com/YOUR_USERNAME/strix-halo-skills.git
cd strix-halo-skills
./setup_new_project.sh
```

## 💡 Tips

1. **Keep Skills Updated**: Periodically pull latest from the repo
2. **Customize for Your Needs**: Fork and modify skills for your workflow
3. **Share Your Improvements**: Submit PRs with enhancements
4. **Document Your Setup**: Add project-specific notes to README

## 🎓 Learning More

- Read the complete guide: `.claude/skills/STRIX_HALO_COMPLETE_GUIDE.md`
- Check test results: `UPDATE_SUMMARY_OCT2025.md`
- Review troubleshooting: `TROUBLESHOOTING.md`
- Explore test scripts in `scripts/`

---

**Need Help?** Check the issues on GitHub or refer to the community resources in the main README.
