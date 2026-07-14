#!/usr/bin/env bash

# Read-only host checks for AMD Strix Halo (gfx1151).

set -uo pipefail

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
# gfx1151 reports PCI device ID 0x1586; filter out any discrete Radeon card.
STRIX_HALO_DEVICE_ID='0x1586'

pass() {
    printf '[PASS] %s\n' "$*"
    PASS_COUNT=$((PASS_COUNT + 1))
}

warn() {
    printf '[WARN] %s\n' "$*"
    WARN_COUNT=$((WARN_COUNT + 1))
}

fail() {
    printf '[FAIL] %s\n' "$*"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

info() {
    printf '[INFO] %s\n' "$*"
}

bytes_to_gib() {
    awk -v bytes="$1" 'BEGIN { printf "%.2f", bytes / 1073741824 }'
}

printf 'Strix Halo host verification\n'
printf '%s\n' '============================'

if command -v rocminfo >/dev/null 2>&1; then
    ROCMINFO_OUTPUT=$(rocminfo 2>/dev/null || true)
    if grep -qE '(^|[^[:alnum:]_])gfx1151([^[:alnum:]_]|$)' <<<"$ROCMINFO_OUTPUT"; then
        pass 'HSA reports gfx1151'
    else
        fail 'rocminfo is installed but does not report gfx1151'
    fi
else
    if command -v lspci >/dev/null 2>&1 && lspci -nn | grep -Eqi 'Radeon 8060S|Strix Halo'; then
        warn 'Strix Halo display hardware found, but rocminfo is unavailable'
    else
        fail 'Cannot identify gfx1151; install rocminfo or check the AMD GPU driver'
    fi
fi

if [[ -e /dev/kfd ]]; then
    if [[ -r /dev/kfd && -w /dev/kfd ]]; then
        pass '/dev/kfd is accessible'
    else
        fail '/dev/kfd exists but is not readable and writable by this user'
    fi
else
    fail '/dev/kfd is missing'
fi

RENDER_NODE=''
for sys_node in /sys/class/drm/renderD*; do
    [[ -r "$sys_node/device/vendor" && -r "$sys_node/device/device" ]] || continue
    if [[ "$(< "$sys_node/device/vendor")" == '0x1002' && \
          "$(< "$sys_node/device/device")" == "$STRIX_HALO_DEVICE_ID" ]]; then
        RENDER_NODE="/dev/dri/$(basename "$sys_node")"
        break
    fi
done
if [[ -n "$RENDER_NODE" ]]; then
    if [[ -r "$RENDER_NODE" && -w "$RENDER_NODE" ]]; then
        pass "$RENDER_NODE is accessible"
    else
        fail "$RENDER_NODE exists but is not readable and writable by this user"
    fi
else
    fail 'No DRM render node found under /dev/dri'
fi

USER_GROUPS=$(id -nG 2>/dev/null || true)
if grep -qw render <<<"$USER_GROUPS"; then
    pass 'User is in the render group'
else
    warn 'User is not in the render group; device ACLs currently provide access'
fi
if grep -qw video <<<"$USER_GROUPS"; then
    pass 'User is in the video group'
else
    warn 'User is not in the video group'
fi

SYSTEM_ROCM=''
if command -v dpkg-query >/dev/null 2>&1; then
    SYSTEM_ROCM=$(dpkg-query -W -f='${Version}' rocm-core 2>/dev/null || true)
fi
if [[ -z "$SYSTEM_ROCM" && -r /opt/rocm/.info/version ]]; then
    SYSTEM_ROCM=$(< /opt/rocm/.info/version)
fi
if [[ -n "$SYSTEM_ROCM" ]]; then
    pass "System ROCm package: $SYSTEM_ROCM"
elif command -v amd-smi >/dev/null 2>&1; then
    AMD_SMI_VERSION=$(amd-smi version 2>/dev/null | tr '\n' ' ' | tr -s ' ' || true)
    pass "AMD SMI is available${AMD_SMI_VERSION:+: $AMD_SMI_VERSION}"
else
    warn 'No system ROCm version was found; TheRock wheels can supply user-space ROCm'
fi

KERNEL=$(uname -r)
KERNEL_BASE=$(sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/' <<<"$KERNEL")
OEM_SUPPORTED=0
if [[ "$KERNEL" == *-oem* ]] && command -v dpkg >/dev/null 2>&1; then
    if dpkg --compare-versions "$KERNEL_BASE" gt '6.14.0'; then
        OEM_SUPPORTED=1
    elif [[ "$KERNEL" =~ ^6\.14\.0-([0-9]+)-oem ]] && (( 10#${BASH_REMATCH[1]} >= 1018 )); then
        OEM_SUPPORTED=1
    fi
fi
if command -v dpkg >/dev/null 2>&1 && dpkg --compare-versions "$KERNEL_BASE" ge '6.18.4'; then
    pass "Kernel $KERNEL includes the upstream Strix Halo memory fixes"
elif (( OEM_SUPPORTED == 1 )); then
    pass "Ubuntu OEM kernel $KERNEL is in AMD's supported kernel line"
else
    warn "Kernel $KERNEL may require distribution backports; a real PyTorch launch is authoritative"
fi

MEM_KIB=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
MEM_BYTES=$((MEM_KIB * 1024))
info "Physical RAM: $(bytes_to_gib "$MEM_BYTES") GiB"

FOUND_MEMORY=0
for card in /sys/class/drm/card[0-9]*; do
    [[ -d "$card/device" ]] || continue
    [[ -r "$card/device/vendor" && -r "$card/device/device" ]] || continue
    [[ "$(< "$card/device/vendor")" == '0x1002' ]] || continue
    [[ "$(< "$card/device/device")" == "$STRIX_HALO_DEVICE_ID" ]] || continue
    GTT_FILE="$card/device/mem_info_gtt_total"
    VRAM_FILE="$card/device/mem_info_vram_total"
    if [[ -r "$GTT_FILE" || -r "$VRAM_FILE" ]]; then
        FOUND_MEMORY=1
        CARD_NAME=$(basename "$card")
        [[ -r "$GTT_FILE" ]] && info "$CARD_NAME GTT aperture: $(bytes_to_gib "$(< "$GTT_FILE")") GiB"
        [[ -r "$VRAM_FILE" ]] && info "$CARD_NAME VRAM mapping: $(bytes_to_gib "$(< "$VRAM_FILE")") GiB"
    fi
done
if (( FOUND_MEMORY == 0 )); then
    warn 'Could not read AMDGPU GTT/VRAM accounting from sysfs'
else
    info 'VRAM and GTT are overlapping views of unified physical memory; do not add them'
fi

if [[ -r /sys/module/ttm/parameters/pages_limit ]]; then
    PAGES_LIMIT=$(< /sys/module/ttm/parameters/pages_limit)
    PAGE_SIZE=$(getconf PAGESIZE 2>/dev/null || printf '4096')
    info "TTM pages_limit: $PAGES_LIMIT ($(bytes_to_gib "$((PAGES_LIMIT * PAGE_SIZE))") GiB at $PAGE_SIZE-byte pages)"
fi

if command -v python3.12 >/dev/null 2>&1; then
    pass "Python 3.12 available: $(python3.12 --version 2>&1)"
    if python3.12 -m venv --help >/dev/null 2>&1; then
        pass 'Python 3.12 venv support is available'
    else
        fail 'Python 3.12 is present but the venv module is missing'
    fi
else
    fail 'Python 3.12 is required by the AMD-supported wheel set'
fi

ACTIVE_PYTHON=$(command -v python 2>/dev/null || command -v python3 2>/dev/null || true)
if [[ -n "$ACTIVE_PYTHON" ]] && "$ACTIVE_PYTHON" -c 'import torch' >/dev/null 2>&1; then
    info "PyTorch found in $ACTIVE_PYTHON; checking a real gfx1151 kernel launch"
    if "$ACTIVE_PYTHON" - <<'PY'
import torch

assert torch.version.hip is not None, "this is not a ROCm PyTorch build"
assert torch.cuda.is_available(), "torch.cuda.is_available() is false"
props = torch.cuda.get_device_properties(0)
arch = getattr(props, "gcnArchName", "")
assert "gfx1151" in arch, f"unexpected GPU architecture: {arch!r}"
x = torch.arange(1024, dtype=torch.float32, device="cuda")
y = (x * 2 + 1).sum()
torch.cuda.synchronize()
assert y.item() == 1048576.0
print(f"PyTorch {torch.__version__}; HIP {torch.version.hip}; {props.name}; {arch}")
PY
    then
        pass 'Active PyTorch launched and synchronized a gfx1151 compute kernel'
    else
        fail 'Active PyTorch could not complete a gfx1151 compute kernel'
    fi
else
    info 'PyTorch is not installed in the active Python; install a track, then run verify_pytorch.py'
fi

printf '\nSummary: %d passed, %d warnings, %d failed\n' \
    "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

if (( FAIL_COUNT > 0 )); then
    exit 1
fi
