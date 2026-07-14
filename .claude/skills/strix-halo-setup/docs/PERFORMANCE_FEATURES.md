# Performance Features

Enable features one at a time and prove them with the target workload. A newer
package can expose a feature while regressing a particular model shape.

## Flash Attention and AOTriton

ROCm PyTorch uses scaled dot-product attention (SDPA) dispatch. Let PyTorch
select a backend during normal execution. To establish that the flash backend
works on gfx1151, enable AMD's experimental AOTriton path before importing
PyTorch and force flash-only dispatch in the verifier:

```bash
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 \
  python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py \
    --require flash_attention
```

The probe runs causal FP16 attention forward and backward. If forcing flash is
unsupported for its shape, PyTorch raises instead of silently using the math
backend. This validates the tested shape, not every head dimension, dtype,
mask, dropout setting, or framework wrapper.

Use PyTorch SDPA (`torch.nn.functional.scaled_dot_product_attention`) rather
than adding a third-party FlashAttention package by default. External packages
often carry a narrower GPU build matrix and must be tested independently.

## Precision

- FP16 is the dtype AMD officially validates for gfx1151 in the ROCm 7.2 Ryzen
  matrix.
- BF16 is valuable for ML range and works in newer stacks on some workloads,
  but treat the verifier result and the real model step as the evidence.
- FP32 remains useful for reductions, sensitive layers, and correctness checks.

Do not infer dtype support from tensor allocation. The verifier launches GEMM
kernels and compares their output with an FP32 CPU reference.

## torch.compile and Triton

TheRock's current multi-arch packages include compatible Triton components.
Run the default verifier to compile a full graph and execute it twice:

```bash
python .claude/skills/strix-halo-setup/scripts/verify_pytorch.py \
  --require compile
```

Compilation has shape-dependent startup cost. Compare the real steady-state
workload before keeping it enabled, and preserve an eager-mode fallback.

## Matrix Multiplication

Leave rocBLAS/hipBLASLt selection on its automatic default. Do not export
`ROCBLAS_USE_HIPBLASLT=1` globally: support and winning shapes change with the
library build. The FP16 and BF16 GEMM probes establish kernel execution, not
which backend is faster.

When investigating a GEMM bottleneck, use ROCm profiling tools and compare the
specific model shapes in isolated processes. Record the package versions and
any backend override with the result.

## Convolution

The capability verifier runs a bounded FP16 convolution forward and backward,
which exercises the ROCm convolution path used by training and diffusion
workloads. A passing small probe does not guarantee every MIOpen algorithm or
large tensor shape.

## Allocator and Copies

Start with PyTorch's default allocator and SDMA enabled. In particular:

- `HSA_ENABLE_SDMA=0` disables DMA copies in all directions; it is a diagnostic
  workaround, not a general optimization.
- Set `PYTORCH_ALLOC_CONF` only for a reproduced fragmentation problem and
  validate peak physical memory as well as PyTorch's allocator statistics.
- Device visibility variables are for selection/isolation, not performance.

## Sources

- [ROCm 7.2 PyTorch compatibility and AOTriton status](https://rocm.docs.amd.com/en/docs-7.2.2/compatibility/ml-compatibility/pytorch-compatibility.html)
- [AMD Ryzen PyTorch install and AOTriton switch](https://rocm.docs.amd.com/projects/radeon-ryzen/en/docs-7.2.1/docs/install/installryz/native_linux/install-pytorch.html)
- [ROCR runtime environment variables](https://rocm.docs.amd.com/projects/ROCR-Runtime/en/latest/api-reference/environment_variables.html)
- [rocBLAS environment variables](https://rocm.docs.amd.com/projects/rocBLAS/en/latest/reference/env-variables.html)
