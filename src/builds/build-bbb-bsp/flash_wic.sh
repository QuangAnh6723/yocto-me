#!/bin/bash

# File names (using symlinks to always target the latest build)
WIC_FILE="tmp/deploy/images/bbb-custom/core-image-minimal-bbb-custom.rootfs.wic"
BMAP_FILE="tmp/deploy/images/bbb-custom/core-image-minimal-bbb-custom.rootfs.wic.bmap"
TARGET_DEV=$1

# 1. Check input arguments
if [ -z "$TARGET_DEV" ]; then
    echo "❌ Error: Target device (SD card/USB) not specified."
    echo "👉 Usage: ./flash_wic.sh /dev/sdX  (or /dev/mmcblkX)"
    echo "💡 Tip: Run 'lsblk' to identify your target drive name."
    exit 1
fi

# 2. Check if image files exist
if [ ! -f "$WIC_FILE" ] || [ ! -f "$BMAP_FILE" ]; then
    echo "❌ Error: $WIC_FILE or $BMAP_FILE not found in the current directory."
    echo "Make sure you are running this from the deploy/images/bbb-custom directory."
    exit 1
fi

# 3. Check if the target device exists
if [ ! -b "$TARGET_DEV" ]; then
    echo "❌ Error: Device '$TARGET_DEV' does not exist or is not a valid block device."
    exit 1
fi

# 4. Safety confirmation warning
echo "========================================================"
echo "⚠️  WARNING: ALL DATA ON $TARGET_DEV WILL BE PERMANENTLY ERASED!"
echo "Source File:   $WIC_FILE"
echo "Target Device: $TARGET_DEV"
echo "========================================================"
read -p "Are you sure you want to continue? (Type 'yes' to confirm): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "🛑 Flashing canceled."
    exit 0
fi

# 6. Unmount existing partitions on the target device to avoid conflicts
echo "🔄 Unmounting existing partitions on $TARGET_DEV..."
sudo umount ${TARGET_DEV}* 2>/dev/null

# 7. Flash the image using bmaptool
echo "🚀 Flashing image via bmaptool..."
sudo bmaptool copy --bmap "$BMAP_FILE" "$WIC_FILE" "$TARGET_DEV"

# 8. Check execution result
if [ $? -eq 0 ]; then
    echo "🎉 Success! The image has been successfully flashed to $TARGET_DEV."
    echo "🔌 You can now safely eject the SD card and boot your BeagleBone Black."
else
    echo "❌ Error: Flashing process failed."
fi