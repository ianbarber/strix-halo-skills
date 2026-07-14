#!/usr/bin/env python3
"""Run bounded, real PyTorch ROCm capability checks on gfx1151."""

from __future__ import annotations

import argparse
import importlib.metadata
import os
import sys
import traceback
from collections.abc import Callable


FEATURES = (
    "bf16",
    "compile",
    "convolution",
    "flash_attention",
    "fp16",
    "memory",
    "sdpa",
)


def package_version(name: str) -> str | None:
    try:
        return importlib.metadata.version(name)
    except importlib.metadata.PackageNotFoundError:
        return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify bounded PyTorch ROCm capabilities on Strix Halo."
    )
    parser.add_argument(
        "--require",
        action="append",
        choices=FEATURES,
        default=[],
        help="Treat an optional feature failure as fatal; may be repeated.",
    )
    parser.add_argument(
        "--allocation-mib",
        type=int,
        default=256,
        help="Size of the touched GPU allocation check (default: 256 MiB).",
    )
    parser.add_argument(
        "--skip-compile",
        action="store_true",
        help="Skip torch.compile unless it is required.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print tracebacks for failed checks.",
    )
    args = parser.parse_args()
    if args.allocation_mib < 1:
        parser.error("--allocation-mib must be positive")
    if args.skip_compile and "compile" in args.require:
        parser.error("--skip-compile conflicts with --require compile")
    return args


def main() -> int:
    args = parse_args()

    try:
        import torch
        import torch.nn.functional as functional
    except Exception as exc:
        print(f"[FAIL] Cannot import PyTorch: {exc}")
        return 1

    print("Strix Halo PyTorch capability verification")
    print("===========================================")
    print(f"Python: {sys.version.split()[0]}")
    print(f"PyTorch: {torch.__version__}")
    print(f"PyTorch HIP build: {torch.version.hip}")

    packages = (
        "torchvision",
        "torchaudio",
        "triton",
        "rocm-sdk-core",
        "rocm-sdk-libraries",
        "rocm-sdk-device-gfx1151",
        "amd-torch-device-gfx1151",
    )
    for package in packages:
        version = package_version(package)
        if version is not None:
            print(f"{package}: {version}")

    risky_overrides = (
        "HSA_OVERRIDE_GFX_VERSION",
        "PYTORCH_ROCM_ARCH",
        "HSA_ENABLE_SDMA",
        "ROCR_VISIBLE_DEVICES",
        "HIP_VISIBLE_DEVICES",
        "ROCBLAS_USE_HIPBLASLT",
        "HSA_CU_MASK",
        "HSA_XNACK",
        "HSA_FORCE_FINE_GRAIN_PCIE",
        "GPU_MAX_HEAP_SIZE",
        "GPU_MAX_ALLOC_PERCENT",
        "PYTORCH_ALLOC_CONF",
        "PYTORCH_HIP_ALLOC_CONF",
        "TORCH_BLAS_PREFER_HIPBLASLT",
    )
    inherited = [
        f"{name}={os.environ[name]}"
        for name in risky_overrides
        if name in os.environ
    ]
    if inherited:
        print(f"[WARN] Inherited runtime overrides: {', '.join(inherited)}")
    aotriton = os.environ.get("TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL")
    print(f"AOTriton experimental switch: {aotriton or 'unset'}")

    fatal_failures = 0
    optional_failures = 0

    if torch.version.hip is None:
        print("[FAIL] This PyTorch build has no ROCm/HIP runtime")
        return 1
    if not torch.cuda.is_available():
        print("[FAIL] torch.cuda.is_available() is false")
        return 1

    try:
        properties = torch.cuda.get_device_properties(0)
        architecture = getattr(properties, "gcnArchName", "unknown")
        print(f"Device: {properties.name}")
        print(f"Architecture: {architecture}")
        print(f"PyTorch multiprocessor count: {properties.multi_processor_count}")
        print(f"PyTorch-visible memory: {properties.total_memory / 2**30:.2f} GiB")
        if "gfx1151" not in architecture:
            print(f"[FAIL] Expected gfx1151, got {architecture}")
            return 1
        print("[PASS] PyTorch reports gfx1151")
    except Exception as exc:
        print(f"[FAIL] Could not inspect the ROCm device: {exc}")
        return 1

    if package_version("rocm-sdk-core") and not package_version(
        "rocm-sdk-device-gfx1151"
    ):
        print("[FAIL] TheRock ROCm packages are installed without rocm-sdk-device-gfx1151")
        return 1

    def run_check(
        name: str,
        label: str,
        check: Callable[[], str | None],
        *,
        core: bool = False,
    ) -> None:
        nonlocal fatal_failures, optional_failures
        required = core or name in args.require
        try:
            detail = check()
            torch.cuda.synchronize()
            suffix = f" ({detail})" if detail else ""
            print(f"[PASS] {label}{suffix}")
        except Exception as exc:
            level = "FAIL" if required else "WARN"
            print(f"[{level}] {label}: {type(exc).__name__}: {exc}")
            if args.verbose:
                traceback.print_exc()
            if required:
                fatal_failures += 1
            else:
                optional_failures += 1
        finally:
            try:
                torch.cuda.empty_cache()
            except Exception:
                pass

    def basic_compute() -> str:
        values = torch.arange(1024, dtype=torch.float32, device="cuda")
        result = (values * 2 + 1).sum()
        expected = 1048576.0
        if result.item() != expected:
            raise AssertionError(f"expected {expected}, got {result.item()}")
        return "FP32 elementwise kernel and host synchronization"

    def matmul(dtype: torch.dtype) -> str:
        torch.manual_seed(7)
        left = torch.randn((256, 256), device="cuda", dtype=dtype) * 0.05
        right = torch.randn((256, 256), device="cuda", dtype=dtype) * 0.05
        result = left @ right
        if not torch.isfinite(result).all().item():
            raise AssertionError("matrix multiplication produced non-finite values")
        expected = left.float().cpu() @ right.float().cpu()
        torch.testing.assert_close(
            result.float().cpu(), expected, rtol=0.05, atol=0.005
        )
        return f"256x256 GEMM, dtype={dtype}, FP32 CPU reference"

    def convolution() -> str:
        torch.manual_seed(11)
        inputs = (
            torch.randn((2, 8, 32, 32), device="cuda", dtype=torch.float16)
            * 0.05
        ).requires_grad_()
        weights = (
            torch.randn((16, 8, 3, 3), device="cuda", dtype=torch.float16)
            * 0.05
        ).requires_grad_()
        output = functional.conv2d(inputs, weights, padding=1)
        expected = functional.conv2d(
            inputs.detach().float().cpu(),
            weights.detach().float().cpu(),
            padding=1,
        )
        torch.testing.assert_close(
            output.detach().float().cpu(), expected, rtol=0.05, atol=0.005
        )
        output.float().square().mean().backward()
        if inputs.grad is None or weights.grad is None:
            raise AssertionError("convolution backward did not create gradients")
        if not torch.isfinite(inputs.grad).all().item() or not torch.isfinite(
            weights.grad
        ).all().item():
            raise AssertionError("convolution gradients contain non-finite values")
        return "FP16 forward against FP32 CPU reference, plus backward"

    def make_qkv() -> tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        shape = (2, 4, 128, 64)

        def tensor() -> torch.Tensor:
            return (
                torch.randn(shape, device="cuda", dtype=torch.float16) * 0.05
            ).requires_grad_()

        return tensor(), tensor(), tensor()

    def check_sdpa() -> str:
        query, key, value = make_qkv()
        output = functional.scaled_dot_product_attention(
            query, key, value, is_causal=True
        )
        expected = functional.scaled_dot_product_attention(
            query.detach().float().cpu(),
            key.detach().float().cpu(),
            value.detach().float().cpu(),
            is_causal=True,
        )
        torch.testing.assert_close(
            output.detach().float().cpu(), expected, rtol=0.05, atol=0.005
        )
        output.float().sum().backward()
        if query.grad is None or not torch.isfinite(query.grad).all().item():
            raise AssertionError("SDPA backward gradient is invalid")
        return "FP16 causal forward against FP32 CPU reference, plus backward"

    def check_flash_attention() -> str:
        from torch.nn.attention import SDPBackend, sdpa_kernel

        query, key, value = make_qkv()
        with sdpa_kernel([SDPBackend.FLASH_ATTENTION]):
            output = functional.scaled_dot_product_attention(
                query, key, value, is_causal=True
            )
        expected = functional.scaled_dot_product_attention(
            query.detach().float().cpu(),
            key.detach().float().cpu(),
            value.detach().float().cpu(),
            is_causal=True,
        )
        torch.testing.assert_close(
            output.detach().float().cpu(), expected, rtol=0.05, atol=0.005
        )
        output.float().sum().backward()
        if query.grad is None or not torch.isfinite(query.grad).all().item():
            raise AssertionError("flash SDPA backward gradient is invalid")
        return (
            "forced FLASH_ATTENTION backend, FP16 forward against FP32 CPU "
            "reference, plus backward"
        )

    def check_compile() -> str:
        if not hasattr(torch, "compile"):
            raise RuntimeError("torch.compile is unavailable")

        def function(left: torch.Tensor, right: torch.Tensor) -> torch.Tensor:
            return functional.silu(left @ right)

        compiled = torch.compile(function, fullgraph=True)
        torch.manual_seed(13)
        left = torch.randn((128, 128), device="cuda", dtype=torch.float16) * 0.05
        right = torch.randn((128, 128), device="cuda", dtype=torch.float16) * 0.05
        expected = function(left, right)
        actual = compiled(left, right)
        second = compiled(left, right)
        if not torch.allclose(actual, expected, rtol=0.02, atol=0.02):
            raise AssertionError("compiled output differs from eager output")
        if not torch.allclose(second, expected, rtol=0.02, atol=0.02):
            raise AssertionError("cached compiled output differs from eager output")
        return "Inductor full graph and cached second call"

    def check_memory() -> str:
        size = args.allocation_mib * 1024 * 1024
        allocation = torch.empty(size, dtype=torch.uint8, device="cuda")
        allocation.fill_(165)
        sample = allocation[:: max(1, size // 4096)]
        if not torch.all(sample == 165).item():
            raise AssertionError("touched allocation did not read back correctly")
        return f"{args.allocation_mib} MiB allocated, written, and sampled"

    run_check("basic", "Basic GPU compute", basic_compute, core=True)
    run_check(
        "fp16",
        "FP16 matrix multiplication",
        lambda: matmul(torch.float16),
        core=True,
    )
    run_check("bf16", "BF16 matrix multiplication", lambda: matmul(torch.bfloat16))
    run_check("convolution", "Convolution", convolution)
    run_check("sdpa", "Scaled dot-product attention", check_sdpa)
    run_check("flash_attention", "Forced flash attention", check_flash_attention)
    if not args.skip_compile:
        run_check("compile", "torch.compile", check_compile)
    else:
        print("[INFO] torch.compile skipped")
    run_check("memory", "Bounded memory", check_memory)

    print()
    print(
        f"Summary: {fatal_failures} required failures, "
        f"{optional_failures} optional warnings"
    )
    if fatal_failures:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
