# Agent Guidelines for Strix Halo Skills Repository

This document provides guidance for AI agents (like Claude Code) when making changes to this repository.

## Repository Purpose

This is a **Claude Code skills package** for AMD Strix Halo (Ryzen AI MAX+ 395) hardware. The goal is to help users set up PyTorch environments for running ML workloads, particularly large language models up to 30B parameters.

## Key Principles

1. **Self-Contained Skill**: Everything users need is in `.claude/skills/strix-halo-setup/`
2. **Tested on Real Hardware**: All claims should be verifiable with actual testing
3. **Focused on Core Setup**: Get PyTorch working, GTT configured, basic verification
4. **Minimal Root Clutter**: Keep root directory clean with only essential docs

## When Making Changes

### Always Update

1. **CHANGELOG.md**: Document changes with version numbers
2. **metadata.tested_date** in SKILL.md frontmatter if re-testing
3. **skill_version** in SKILL.md frontmatter for breaking changes

### Skill Documentation (.claude/skills/strix-halo-setup/)

When modifying the skill:
- Keep SKILL.md focused on setup steps
- Update docs/TROUBLESHOOTING.md for new issues
- Update scripts/ if verification logic changes
- Test scripts on actual hardware if possible
- Ensure all file paths are relative to project root

### Version Bumping

- **Patch (1.0.x)**: Bug fixes, doc updates, script improvements
- **Minor (1.x.0)**: New features (e.g., Vulkan support), new scripts
- **Major (x.0.0)**: Breaking changes (e.g., ROCm version requirement change)

### What to Avoid

- **Don't add performance benchmarks**: They become outdated quickly
- **Don't add excessive dependencies**: Keep to PyTorch + essentials
- **Don't duplicate docs**: Information should live in one place
- **Don't add untested features**: Verify on hardware first
- **Don't over-promise**: Be realistic about capabilities

## Testing Requirements

Before committing changes that affect functionality:

1. **Run verify_system.sh**: Ensure all checks still work
2. **Test on hardware**: If available, verify on actual Strix Halo
3. **Check script syntax**: Ensure scripts are executable and error-free
4. **Validate YAML**: Check SKILL.md frontmatter is valid

## Documentation Standards

### Writing Style
- Be concise and actionable
- Provide specific commands, not abstractions
- Show expected output
- Explain "why" for non-obvious decisions
- Link to community resources for details

### Code Examples
- Should be copy-pasteable
- Include error handling
- Show verification steps
- Use bash heredocs for multi-line scripts

## Maintenance Priorities

### High Priority
- Keep PyTorch installation instructions current
- Update ROCm version recommendations
- Fix reported issues promptly
- Keep GTT configuration accurate

### Medium Priority
- Add new test scripts if needed
- Improve troubleshooting guide
- Update community resource links
- Respond to pull requests

### Low Priority
- Formatting improvements
- Additional documentation
- Example projects
- Video walkthroughs

## Common Tasks

### Updating for New ROCm Version

1. Test on hardware with new ROCm
2. Update supported_rocm in SKILL.md metadata
3. Update installation commands if changed
4. Add entry to CHANGELOG.md
5. Update README.md if capabilities changed

### Adding New Script

1. Add to `.claude/skills/strix-halo-setup/scripts/`
2. Make executable: `chmod +x script.sh`
3. Document in skill's README.md
4. Reference from SKILL.md if part of setup
5. Add to CHANGELOG.md

### Fixing Issues

1. Reproduce the issue if possible
2. Document fix in docs/TROUBLESHOOTING.md
3. Update SKILL.md if it affects setup
4. Update verify_system.sh if it's a common check
5. Add to CHANGELOG.md

## File Organization

### Keep in Repository Root
- README.md (overview and quick start)
- CHANGELOG.md (version history)
- LICENSE (MIT)
- .gitignore
- AGENTS.md (this file)
- .claude.md (loads this file)

### Keep in Skill Directory (.claude/skills/strix-halo-setup/)
- SKILL.md (main skill with YAML frontmatter)
- README.md (skill-specific documentation)
- scripts/ (all verification and setup scripts)
- docs/TROUBLESHOOTING.md (common issues)
- docs/GTT_MEMORY_FIX.md (if still needed after simplification)

### Remove from Repository
- Duplicative "getting started" type docs (consolidate into README)
- Archive folders (not needed in published repo)
- Benchmark result JSON files
- Development scripts not used in production

## Skill Design Philosophy

**Goal**: Get Strix Halo working for PyTorch with minimal friction

**In scope**:
- ROCm verification
- PyTorch installation (community builds)
- GTT configuration
- Basic environment setup
- Verification testing

**Out of scope**:
- Model-specific setup (Llama, Mistral, etc.)
- Framework integration (LangChain, vLLM, etc.)
- Advanced training techniques
- Performance tuning beyond basics
- Windows-specific setup (mention it exists, but focus on Linux)

## Community Engagement

When responding to issues:
- Thank contributors
- Ask for hardware/software details
- Reproduce if possible
- Document fix in troubleshooting
- Update skill if it's a common issue
- Credit contributors in CHANGELOG

## Questions to Consider

Before adding features, ask:
- Does this belong in the skill or in user's project?
- Is this tested on real hardware?
- Does this complicate the setup unnecessarily?
- Will this need frequent updates?
- Is this the simplest solution?

---

*This document helps AI agents maintain consistency and quality when updating this repository.*
