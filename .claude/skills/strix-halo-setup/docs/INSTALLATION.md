# Installation Tracks

Use Python 3.12 and a fresh virtual environment for either track. Mixing wheel
families can produce an environment that imports successfully but launches the
wrong architecture code.

## AMD-Supported ROCm 7.2.1

Choose this for AMD's validated Ryzen combination: Ubuntu 24.04, Python 3.12,
PyTorch 2.9.1, and ROCm 7.2.1. Confirm the current matrix before installing on a
different OS or kernel.

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip wheel
python -m pip install \
  'https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2.1/torch-2.9.1%2Brocm7.2.1.lw.gitff65f5bc-cp312-cp312-linux_x86_64.whl' \
  'https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2.1/torchvision-0.24.0%2Brocm7.2.1.gitb919bd0c-cp312-cp312-linux_x86_64.whl' \
  'https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2.1/torchaudio-2.9.0%2Brocm7.2.1.gite3c6ee2b-cp312-cp312-linux_x86_64.whl' \
  'https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2.1/triton-3.5.1%2Brocm7.2.1.gita272dfa8-cp312-cp312-linux_x86_64.whl'
```

These are AMD's `repo.radeon.com` wheels. The similarly versioned PyTorch.org
ROCm channel is not the tested artifact set in AMD's Ryzen matrix.

## TheRock Multi-Arch Nightly

Choose this when newer PyTorch/Triton integration or recent gfx1151 fixes are
more important than release stability. TheRock nightlies are moving builds.

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install \
  --index-url https://rocm.nightlies.amd.com/whl-multi-arch/ \
  "torch[device-gfx1151]" "torchvision[device-gfx1151]" torchaudio
```

The `device-gfx1151` extras install the architecture-specific ROCm and PyTorch
kernel packages. Compatible user-space ROCm packages are dependencies, so do
not preinstall a different ROCm wheel set in the environment.

The multi-arch channel supersedes new per-family installs such as
`https://rocm.nightlies.amd.com/v2/gfx1151/`. Keep the old index only for
reproducing a historical environment.

Do not add `--pre` without a reason. With the index state checked on 2026-07-14,
the command without `--pre` selected a PyTorch 2.12 build backed by ROCm 7.15
development packages; `--pre` offered a newer PyTorch alpha. Query again at
install time:

```bash
python -m pip index versions torch \
  --index-url https://rocm.nightlies.amd.com/whl-multi-arch/
```

## Verify and Lock

Run from the repository root:

```bash
if command -v rocm-sdk >/dev/null 2>&1; then
  rocm-sdk test
fi
python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 \
  python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py \
    --require flash_attention
python -m torch.utils.collect_env > collect-env.txt
python -m pip freeze > requirements-lock.txt
```

Keep the last working virtual environment while testing a new nightly in a
second environment. A frozen requirements file records what resolved, but the
nightly index may eventually remove old artifacts; retain a wheel cache when
long-term reconstruction matters.

## Sources

- [AMD ROCm 7.2.1 Ryzen PyTorch install](https://rocm.docs.amd.com/projects/radeon-ryzen/en/docs-7.2.1/docs/install/installryz/native_linux/install-pytorch.html)
- [AMD Ryzen Linux compatibility](https://rocm.docs.amd.com/projects/radeon-ryzen/en/docs-7.2/docs/compatibility/compatibilityryz/native_linux/native_linux_compatibility.html)
- [TheRock release and multi-arch install documentation](https://github.com/ROCm/TheRock/blob/main/RELEASES.md)
- [TheRock gfx1151 status](https://github.com/ROCm/TheRock/blob/main/SUPPORTED_GPUS.md)
