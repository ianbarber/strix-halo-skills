# Changelog

All notable changes to the Strix Halo Skills project will be documented in this file.

## [2.0.0] - July 14, 2026

### Rebuilt Installation and Capability Validation

**Breaking changes:**

- Replaced the retired per-family TheRock install with the unified multi-arch
  index and the `device-gfx1151` package extras.
- Removed blanket HSA, device-visibility, SDMA, allocator, and BLAS environment
  overrides from the baseline setup.
- Removed synthetic model-capacity tests and the benchmark script; their
  allocation results did not prove that a model or optimized kernel executed.
- Changed GTT configuration from a hard-coded system modification to a
  read-only advisor using AMD's `amd-ttm` workflow.

**Added:**

- Separate AMD-supported ROCm 7.2.1/PyTorch 2.9.1 and experimental TheRock
  nightly installation tracks.
- A bounded `verify_pytorch.py` probe for gfx1151, FP16, BF16, convolution
  forward/backward, SDPA, forced flash SDPA, `torch.compile`, and touched memory.
- Feature-specific documentation for AOTriton, Triton/Inductor, precision,
  BLAS selection, convolution, allocator behavior, and SDMA.
- Environment version capture and nightly rollback guidance.

**Corrected:**

- Unified VRAM and GTT mappings are now reported separately and never summed.
- Kernel checks account for Ubuntu OEM backports and the upstream Linux 6.18.4
  fixes instead of assuming every newer-looking kernel has them.
- Official AMD gfx1151 support is documented; the previous claim that all
  official wheels fail is no longer current.
- Model support is no longer inferred from a successful tensor allocation.

**Hardware validation (TheRock track):**

- Host: AMD Ryzen AI MAX+ 395 (`gfx1151`), 64 GiB RAM, Ubuntu 24.04
- Kernel: 6.17.0-1028-oem
- System ROCm: 7.2.0
- Fresh Python 3.12 environment: PyTorch 2.12.0, torchvision 0.27.0,
  torchaudio 2.11.0, Triton 3.7.1, and ROCm 7.15.0 development packages dated
  July 12, 2026
- Installed and verified `rocm-sdk-device-gfx1151` and
  `amd-torch-device-gfx1151`; `pip check` reported no broken requirements
- Passed real gfx1151 kernels for FP32, FP16, BF16, convolution
  forward/backward, SDPA, forced flash SDPA forward/backward, Inductor
  `torch.compile`, and touched memory with no runtime overrides; GEMM,
  convolution, and attention outputs matched bounded FP32 CPU references
- Passed the same forced flash test with
  `TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1`; the ROCm profiler recorded flash
  forward/backward operators plus `attn_fwd.kd` and `bwd_kernel_fuse.kd`
- Passed torchvision GPU NMS; torchaudio imported; TheRock `rocm-sdk test`
  passed all 19 tests; MIOpen runtime reported 3.5.2
- Physical RAM, GTT, and VRAM mappings were reported separately as 61.44,
  30.72, and 64.00 GiB; no TTM, BIOS, or boot configuration was changed
- The AMD-supported track is based on AMD's published compatibility matrix and
  exact wheel set; it was not reinstalled during this July 14 hardware run

Pre-2.0 entries below are retained as release history. Their allocation-only
model estimates and microbenchmarks were not end-to-end model validation and
are superseded by the v2.0 capability checks and memory-accounting rules.

## [1.1.1] - January 23, 2026

### ROCm 7.2 Documentation Update

- Added ROCm 7.x notes, troubleshooting, and then-current environment settings.
- Updated the then-current per-family nightly instructions and TheRock links.
- Recorded BF16 and FP32 microbenchmarks, since removed from the maintained skill
  because they age quickly and do not predict application performance.
- Superseded in v2.0: blanket runtime overrides and the per-family install are no
  longer the baseline.

**Tested Configuration:**
- ROCm: 7.2.0 (system) + 7.11.0 nightlies (PyTorch)
- Kernel: 6.17.0-1005-oem
- PyTorch: 2.11.0a0+rocm7.11.0a20260106

---

## [1.0.0] - October 23, 2025

### Initial Release

- Added the initial `strix-halo-setup` skill, environment scaffolding, GTT
  helper, troubleshooting, allocation probes, and microbenchmark script.
- Documented the then-current community gfx1151 wheels and Vulkan alternative.
- Allocation probes estimated model-size memory needs but did not load or run
  those models. Their capacity claims and summed memory accounting are
  superseded by v2.0.

### Tested Configuration

- **Hardware**: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
- **ROCm**: 6.4.2 (system drivers)
- **PyTorch**: 2.7.0a0 + HIP 6.5.25190 (community build)
- **Linux Kernel**: 6.14.0-33-generic
- **OS**: Ubuntu 24.04 LTS
- **System RAM**: 64 GB
- **Validation method**: synthetic allocations and microbenchmarks only;
  superseded by v2.0's bounded kernel and workload-specific validation policy

### Credits

- **Created by**: Ian Barber
- **Community PyTorch builds**: [@scottt](https://github.com/scottt/rocm-TheRock)
- **ROCm team** and community contributors
- Research from llm-tracker.info, Jeff Geerling, and ROCm/TheRock community

---

## How to Report Issues

- GitHub Issues: https://github.com/ianbarber/strix-halo-skills/issues
- Include: ROCm version, PyTorch version, error messages, system specs
