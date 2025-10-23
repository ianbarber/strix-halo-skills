#!/bin/bash

# Script to configure GTT size for AMD Strix Halo on Ubuntu
# Allows GPU to access more than 33.5GB of system memory

echo "AMD Strix Halo GTT Configuration Script"
echo "========================================"
echo ""
echo "This will configure your system to allow the GPU to access up to 108GB of memory"
echo "Current limit: 33.5GB"
echo "Target limit: 108GB"
echo ""

# Check current GTT size
echo "Current GTT size:"
if [ -f /sys/class/drm/card1/device/mem_info_gtt_total ]; then
    current_gtt=$(cat /sys/class/drm/card1/device/mem_info_gtt_total)
    echo "  $(($current_gtt / 1024 / 1024 / 1024)) GB"
else
    echo "  Unable to detect"
fi

echo ""
echo "To increase GTT size, we need to modify kernel parameters."
echo ""

# Calculate TTM parameters for 108GB
# Formula: (GB * 1024 * 1024) / 4.096
TTM_PAGES=27648000  # For 108GB

echo "Step 1: Backup current GRUB configuration"
echo "  sudo cp /etc/default/grub /etc/default/grub.backup"
echo ""

echo "Step 2: Add kernel parameters"
echo "  Edit /etc/default/grub and add to GRUB_CMDLINE_LINUX_DEFAULT:"
echo ""
echo "  amdttm.pages_limit=$TTM_PAGES amdttm.page_pool_size=$TTM_PAGES"
echo ""

echo "Full line example:"
echo '  GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdttm.pages_limit=27648000 amdttm.page_pool_size=27648000"'
echo ""

echo "Step 3: Update GRUB and reboot"
echo "  sudo update-grub"
echo "  sudo reboot"
echo ""

echo "Alternative TTM values:"
echo "  64GB:  pages_limit=16777216"
echo "  96GB:  pages_limit=25165824"
echo "  108GB: pages_limit=27648000 (recommended maximum)"
echo ""

# Offer to do it automatically
read -p "Would you like to apply these changes automatically? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup
    sudo cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d_%H%M%S)
    
    # Check if parameters already exist
    if grep -q "amdttm.pages_limit" /etc/default/grub; then
        echo "TTM parameters already set in GRUB. Current configuration:"
        grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
        echo ""
        echo "To modify, manually edit /etc/default/grub"
    else
        # Add parameters
        sudo sed -i.bak 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 amdttm.pages_limit=27648000 amdttm.page_pool_size=27648000"/' /etc/default/grub
        
        echo "Modified /etc/default/grub:"
        grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
        echo ""
        
        echo "Updating GRUB..."
        sudo update-grub
        
        echo ""
        echo "✓ Configuration complete!"
        echo ""
        echo "IMPORTANT: You must reboot for changes to take effect."
        echo "After reboot, run: python test_memory.py"
    fi
else
    echo ""
    echo "Manual configuration required. Follow the steps above."
fi