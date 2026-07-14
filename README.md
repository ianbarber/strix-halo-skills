# Strix Halo PyTorch Skill

A Claude Code skill for setting up and validating PyTorch ROCm environments on
AMD Strix Halo (`gfx1151`) Linux systems.

The skill adds value beyond generic setup guidance by encoding the choices and
failure modes that are specific to this hardware:

- AMD-supported and TheRock multi-arch installation tracks
- real kernel checks rather than GPU-enumeration-only verification
- forced PyTorch flash-attention validation with AMD's AOTriton opt-in
- bounded FP16, BF16, MIOpen, backward, and `torch.compile` probes
- correct unified-memory accounting and conservative GTT guidance
- symptom-specific recovery without blanket HSA/ROCm overrides

## Use

Copy `.claude/skills/strix-halo-setup/` into a Claude Code project, then ask
Claude to set up or diagnose Strix Halo PyTorch. The skill starts with:

```bash
./.claude/skills/strix-halo-setup/scripts/verify_system.sh
```

For direct use in this repository, follow
[SKILL.md](.claude/skills/strix-halo-setup/SKILL.md).

## Contents

```text
.claude/skills/strix-halo-setup/
|-- SKILL.md
|-- docs/
|   |-- GTT_MEMORY_FIX.md
|   |-- INSTALLATION.md
|   |-- PERFORMANCE_FEATURES.md
|   `-- TROUBLESHOOTING.md
`-- scripts/
    |-- configure_gtt.sh
    |-- verify_pytorch.py
    `-- verify_system.sh
```

## Scope

The skill covers Linux host checks, PyTorch installation, core capability
validation, and unified-memory setup. Model recipes, framework integrations,
Windows setup, and performance benchmarks are intentionally out of scope.

The TheRock track's current-release claims were checked on a Ryzen AI MAX+ 395
system with 64 GiB RAM. The AMD-supported track follows AMD's published matrix
and exact wheel set but was not reinstalled during that run. See
[CHANGELOG.md](CHANGELOG.md) for the tested software and results.

## Sources

- [AMD Ryzen Linux compatibility matrix](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/compatibility/compatibilityryz/native_linux/native_linux_compatibility.html)
- [AMD Strix Halo system optimization](https://rocm.docs.amd.com/en/latest/how-to/system-optimization/strixhalo.html)
- [ROCm TheRock releases](https://github.com/ROCm/TheRock/blob/main/RELEASES.md)

## License

MIT License. Copyright (c) 2025 Ian Barber.
