# Troubleshooting

Start by preserving the exact error and collecting facts from the affected
environment:

```bash
./.claude/skills/strix-halo-setup/scripts/verify_system.sh
python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py --verbose
python -m torch.utils.collect_env
python -m pip freeze
env | grep -E '^(AMD|GPU|HIP|HSA|ROCBLAS|ROCR|TORCH|PYTORCH)_'
```

## GPU Enumerates but Compute Fails

Symptoms include `invalid device function`, `no kernel image`, or a failure on
the first tensor operation.

1. Check `gcnArchName` in `verify_pytorch.py` output. It must contain `gfx1151`.
2. For TheRock, confirm both device packages are installed:

   ```bash
   python -m pip show rocm-sdk-device-gfx1151 amd-torch-device-gfx1151
   ```

3. Remove `HSA_OVERRIDE_GFX_VERSION`; it can make an incompatible package get
   past detection but cannot add missing kernels.
4. Recreate the environment from one track in [INSTALLATION.md](INSTALLATION.md).

## torch.cuda.is_available() Is False

Check the host before reinstalling Python packages:

```bash
rocminfo | grep -A2 -B2 gfx1151
ls -l /dev/kfd /dev/dri/renderD*
id -nG
```

The user needs access to `/dev/kfd` and a DRM render node and normally belongs
to `render` and `video`. Log out and back in after group changes. In containers,
pass `/dev/kfd`, `/dev/dri`, the required groups, and sufficient shared memory.

## Flash Attention Is Unavailable

Run the feature in a new process so the AOTriton switch is set before PyTorch
imports:

```bash
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 \
  python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py \
    --require flash_attention --verbose
```

If it fails, record the resolved torch, Triton, ROCm, and gfx1151 device-package
versions. Flash dispatch also depends on dtype, head dimension, masks, dropout,
and backward requirements; compare the failing model shape with the bounded
probe. Do not assume a third-party FlashAttention wheel supports gfx1151.

## torch.compile Fails

First prove eager FP16 and the default capability checks. Then run:

```bash
python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py \
  --require compile --verbose
```

Use a fresh TheRock multi-arch environment if the supported stack lacks a fix.
Keep eager execution as the fallback. Do not combine a Triton wheel from one
track with torch from another.

## Convolution or Diffusion Artifacts

Run the convolution probe before changing HSA runtime behavior. If corruption
is reproducible, test a workaround in one process:

```bash
HSA_ENABLE_SDMA=0 python your_reproducer.py
```

This disables DMA copies and can reduce performance. Keep it only if it fixes a
captured reproducer on the installed versions; report that reproducer upstream.

## Out of Memory

1. Read physical RAM, GTT, and VRAM as separate overlapping views with
   `configure_gtt.sh`.
2. Watch system memory and swap as well as PyTorch allocator statistics.
3. Reduce batch size, context, precision, or cache before changing the host.
4. If the real workload is GTT-limited, follow
   [GTT_MEMORY_FIX.md](GTT_MEMORY_FIX.md) and keep OS/CPU headroom.

Do not use VRAM plus GTT as a capacity estimate, and do not validate capacity by
allocating uninitialized tensors without running the workload.

## Nightly Regression

Create a second fresh environment instead of upgrading the last working one.
Query TheRock's current CI status and open issues, compare both environments
with the same verifier command, and include `collect_env` plus `pip freeze` in
the report.

- [TheRock CI dashboard](https://therock-hud-dev.amd.com/)
- [TheRock issues](https://github.com/ROCm/TheRock/issues)
- [TheRock supported GPU status](https://github.com/ROCm/TheRock/blob/main/SUPPORTED_GPUS.md)
