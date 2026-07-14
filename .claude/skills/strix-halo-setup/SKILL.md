---
name: strix-halo-setup
description: Set up and diagnose PyTorch ROCm environments on AMD Strix Halo (gfx1151) Linux systems. Use for selecting a supported or TheRock nightly stack, verifying real GPU kernels and attention backends, inspecting unified-memory limits, or troubleshooting invalid-device-function and out-of-memory failures.
license: MIT
metadata:
  hardware: AMD Strix Halo (gfx1151)
  supported_rocm: "ROCm 7.2.1/PyTorch 2.9.1 supported; TheRock multi-arch nightlies experimental"
  tested_date: "2026-07-14"
  skill_version: "2.0.0"
---

# Strix Halo PyTorch Setup

Set up a reproducible gfx1151 environment, then prove the capabilities the
workload needs. Do not infer support from GPU enumeration or a large allocation.

## Workflow

1. Run the system verifier from the repository root:

   ```bash
   ./.claude/skills/strix-halo-setup/scripts/verify_system.sh
   ```

2. Choose an installation track with the user:

   | Track | Use when | Tradeoff |
   | --- | --- | --- |
   | AMD supported | Stability and AMD's validated matrix matter most | Older PyTorch and kernel stack |
   | TheRock multi-arch | New PyTorch, Triton, AOTriton, or rapid gfx1151 fixes matter most | Moving nightly packages; regressions are possible |

   Default to the AMD supported track unless the user explicitly prioritizes
   new features or agrees to nightly risk. See [installation details](docs/INSTALLATION.md).

3. Create a fresh Python 3.12 virtual environment. Never install these wheels
   into the system Python or an existing environment unless the user requests it.

4. Install one track. Do not combine AMD supported wheels, PyTorch.org wheels,
   old per-family TheRock wheels, or multi-arch TheRock packages in one
   environment.

5. Run the capability verifier:

   ```bash
   python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py
   ```

6. For AOTriton flash attention, start a new process with the experimental
   switch and force the backend during verification:

   ```bash
   TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 \
     python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py \
       --require flash_attention
   ```

7. Capture the resolved environment after it passes:

   ```bash
   python -m torch.utils.collect_env > collect-env.txt
   python -m pip freeze > requirements-lock.txt
   ```

## Installation Tracks

### AMD Supported

AMD's ROCm 7.2.1 Ryzen matrix validates gfx1151 with Python 3.12, PyTorch
2.9.1, and FP16. Install AMD's exact `repo.radeon.com` wheels as documented in
[INSTALLATION.md](docs/INSTALLATION.md), not similarly named PyTorch.org wheels.

Use this track when reproducibility is more important than the newest compiler
or attention work.

### TheRock Multi-Arch Nightly

TheRock replaced new per-family releases with a unified multi-architecture
index. Follow the exact [TheRock multi-arch installation](docs/INSTALLATION.md#therock-multi-arch-nightly)
and select gfx1151 through the `device-gfx1151` package extras.

Do not add `--pre` by default. The index already publishes ROCm development
builds behind stable-looking PyTorch versions; `--pre` may select a newer
PyTorch alpha. Always record the resolved versions and retain the environment
until its replacement passes the same capability checks.

## Runtime Configuration

Start with no Strix-specific environment overrides. Current packages already
identify gfx1151, select visible devices, and choose BLAS/allocator defaults.

Set only the switch required by a tested feature:

```bash
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
```

Do not set these globally:

- `HSA_OVERRIDE_GFX_VERSION`: hides an architecture/package mismatch.
- `PYTORCH_ROCM_ARCH`: build-time/JIT target selection, not normal runtime setup.
- `HSA_ENABLE_SDMA=0`: disables DMA copies; use only to isolate a reproduced bug.
- `ROCR_VISIBLE_DEVICES` or `HIP_VISIBLE_DEVICES`: restrict devices only when asked.
- `ROCBLAS_USE_HIPBLASLT=1`: leave backend selection on automatic unless a
  workload-specific comparison proves otherwise.
- `HSA_CU_MASK`, `HSA_XNACK`, `HSA_FORCE_FINE_GRAIN_PCIE`, and heap percentage
  overrides: diagnostic controls, not baseline optimizations.

See [performance features](docs/PERFORMANCE_FEATURES.md) for attention,
`torch.compile`, BLAS, convolution, and dtype guidance.

## Unified Memory

Strix Halo has unified physical memory. Linux exposes overlapping VRAM and GTT
accounting views; never add them together or describe their sum as usable RAM.

Before changing memory configuration:

1. Read physical RAM, current GTT, and VRAM separately.
2. Estimate weights, KV cache, activations, allocator overhead, and host needs.
3. Leave enough physical RAM for the OS and the workload's CPU allocations.
4. Prefer AMD's `amd-ttm` helper over hand-written kernel parameters.
5. Reboot and re-run verification after a change.

Run the read-only advisor:

```bash
./.claude/skills/strix-halo-setup/scripts/configure_gtt.sh
```

See [GTT memory configuration](docs/GTT_MEMORY_FIX.md). Do not claim a model is
supported from a synthetic allocation; run a representative inference or
training step with the intended precision and context length.

## Interpreting Verification

- `verify_system.sh` checks host prerequisites without modifying the machine.
- `verify_pytorch.py` launches bounded real kernels for FP32, FP16, BF16,
  matrix multiplication, MIOpen convolution/backward, SDPA, forced flash SDPA,
  `torch.compile`, and a touched allocation.
- Optional feature warnings do not invalidate basic PyTorch compute. A feature
  requested through `--require` must pass or the script exits nonzero.
- BF16 passing locally is useful evidence, but AMD's ROCm 7.2.1 Ryzen matrix
  officially lists FP16 validation for gfx1151.
- A flash-attention pass proves PyTorch dispatched the forced SDPA backend for
  the tested shape. It does not prove every model shape uses that backend.

## Troubleshooting Order

1. Save the exact command and complete error.
2. Run both verifiers in the affected environment.
3. Confirm the installed wheel contains a gfx1151 device package.
4. Remove inherited ROCm/HSA overrides and retry in a new process.
5. Compare against a fresh environment on the other installation track.
6. Check TheRock's current test status and issues before changing the host.

Use [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for symptom-specific fixes.

## Boundaries

- Focus on Linux PyTorch setup and validation, not model-specific scaffolding.
- Treat TheRock versions and feature status as time-sensitive; query the index
  when installing rather than copying a version from this document.
- Do not add benchmark numbers or generic model-size compatibility tables.
- Do not modify BIOS, kernel boot parameters, or system memory without explicit
  user approval and a rollback plan.
