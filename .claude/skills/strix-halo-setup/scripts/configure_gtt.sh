#!/usr/bin/env bash

# Read-only unified-memory report and GTT configuration advisor.

set -uo pipefail

# gfx1151 reports PCI device ID 0x1586; filter out any discrete Radeon card.
STRIX_HALO_DEVICE_ID='0x1586'

bytes_to_gib() {
    awk -v bytes="$1" 'BEGIN { printf "%.2f", bytes / 1073741824 }'
}

MEM_KIB=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
MEM_BYTES=$((MEM_KIB * 1024))

printf 'Strix Halo unified-memory report\n'
printf '%s\n' '================================'
printf 'Physical RAM: %s GiB\n' "$(bytes_to_gib "$MEM_BYTES")"

FOUND=0
for card in /sys/class/drm/card[0-9]*; do
    [[ -d "$card/device" ]] || continue
    [[ -r "$card/device/vendor" && -r "$card/device/device" ]] || continue
    [[ "$(< "$card/device/vendor")" == '0x1002' ]] || continue
    [[ "$(< "$card/device/device")" == "$STRIX_HALO_DEVICE_ID" ]] || continue
    GTT_FILE="$card/device/mem_info_gtt_total"
    VRAM_FILE="$card/device/mem_info_vram_total"
    if [[ -r "$GTT_FILE" || -r "$VRAM_FILE" ]]; then
        FOUND=1
        CARD_NAME=$(basename "$card")
        [[ -r "$GTT_FILE" ]] && printf '%s GTT aperture: %s GiB\n' "$CARD_NAME" "$(bytes_to_gib "$(< "$GTT_FILE")")"
        [[ -r "$VRAM_FILE" ]] && printf '%s VRAM mapping: %s GiB\n' "$CARD_NAME" "$(bytes_to_gib "$(< "$VRAM_FILE")")"
    fi
done
if (( FOUND == 0 )); then
    printf 'Strix Halo GTT/VRAM accounting: unavailable\n'
fi

PAGE_SIZE=$(getconf PAGESIZE 2>/dev/null || printf '4096')
if [[ -r /sys/module/ttm/parameters/pages_limit ]]; then
    PAGES_LIMIT=$(< /sys/module/ttm/parameters/pages_limit)
    printf 'TTM pages_limit: %s (%s GiB)\n' "$PAGES_LIMIT" \
        "$(bytes_to_gib "$((PAGES_LIMIT * PAGE_SIZE))")"
fi
if [[ -r /sys/module/ttm/parameters/page_pool_size ]]; then
    PAGE_POOL_SIZE=$(< /sys/module/ttm/parameters/page_pool_size)
    printf 'TTM page_pool_size: %s (%s GiB)\n' "$PAGE_POOL_SIZE" \
        "$(bytes_to_gib "$((PAGE_POOL_SIZE * PAGE_SIZE))")"
fi

if (( FOUND == 1 )); then
    printf '\nVRAM and GTT are overlapping views of the same physical RAM. Do not add them.\n'
fi
printf 'No settings were changed.\n\n'
printf 'AMD-supported configuration path:\n'
printf '  1. Set BIOS dedicated VRAM to its small/minimum value when practical.\n'
printf '  2. Install the helper: pipx install amd-debug-tools\n'
printf '  3. Inspect it:         amd-ttm\n'
printf '  4. Set a chosen GTT:   amd-ttm --set <GiB>\n'
printf '  5. Reboot and run verify_system.sh again.\n\n'
printf 'No target is calculated automatically. Size from the real workload, leave\n'
printf 'explicit OS and CPU-side headroom, and preserve a rollback.\n'
