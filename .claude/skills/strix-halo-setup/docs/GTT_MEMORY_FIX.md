# Strix Halo Unified Memory and GTT

Strix Halo uses physically shared CPU/GPU memory. GPUVM maps that memory into
per-process GPU address spaces; GTT is a mapping limit, not a second pool of
RAM. The `mem_info_vram_total` and `mem_info_gtt_total` values therefore
overlap. Never sum them when estimating capacity.

## Inspect

Run the repository's read-only report:

```bash
./.claude/skills/strix-halo-setup/scripts/configure_gtt.sh
```

Or inspect the underlying values:

```bash
awk '/MemTotal/ { printf "Physical RAM: %.2f GiB\n", $2 / 1048576 }' /proc/meminfo
cat /sys/class/drm/card*/device/mem_info_gtt_total
cat /sys/class/drm/card*/device/mem_info_vram_total
cat /sys/module/ttm/parameters/pages_limit
getconf PAGESIZE
```

The default GTT limit is approximately half of physical RAM. GTT allocations
are dynamic and are not permanently carved out, but GPU and CPU allocations
still compete for the same physical memory.

## Decide Whether to Change It

Change GTT only after a representative workload fails for capacity. Include:

- model weights and quantization metadata
- KV cache at the intended context and batch size
- activations, gradients, and optimizer state when training
- PyTorch and library workspaces
- CPU-side copies, page cache, and operating-system headroom

An allocation-only script does not prove a model fits or runs correctly.

## Configure with AMD's Helper

AMD recommends a small BIOS dedicated-VRAM reservation, such as 0.5 GB, and a
larger shared TTM/GTT mapping limit. Use AMD's helper rather than calculating
kernel page parameters manually:

```bash
sudo apt install pipx
pipx ensurepath
pipx install amd-debug-tools
amd-ttm
amd-ttm --set <GiB>
```

Review the reported physical RAM and current limit before choosing `<GiB>`.
Leave explicit headroom for the OS and CPU side of the real workload. Reboot,
then run both verifiers again.

The helper writes `/etc/modprobe.d/ttm.conf`. To restore kernel defaults:

```bash
amd-ttm --clear
```

Reboot after clearing.

## Kernel Support

The required upstream KFD fixes are in Linux 6.18.4 and newer. AMD-supported
Ubuntu OEM kernels include backports beginning with 6.14.0-1018-oem, while
other distributions can backport the fixes independently. Do not judge support
from a simple version comparison alone: the ROCm/kernel matrix and a real
queue/kernel launch are authoritative.

## Source

[AMD Strix Halo system optimization](https://rocm.docs.amd.com/en/docs-7.2.0/how-to/system-optimization/strixhalo.html)
