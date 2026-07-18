# meta-bbb-bsp/recipes-core/images/core-image-%.bbappend
# Absolute bulletproof artifact copier - Zero loops, zero bracket conflicts

organize_and_copy_artifacts() {
    local wic_out="${TOPDIR}/outputs/wic"
    local flash_out="${TOPDIR}/outputs/flash"

    # Bước 1: Xóa sạch thư mục outputs cũ và tạo mới từ đầu cho gọn
    rm -rf "${TOPDIR}/outputs"
    mkdir -p "${wic_out}" "${flash_out}"

    # Bước 2: Nhảy vào thư mục deploy chung của Yocto
    cd "${DEPLOY_DIR_IMAGE}"

    # Bước 3: Copy đích danh các file Ảnh hệ điều hành (Dùng biến link sạch của Yocto)
    # Lệnh cp -L sẽ tự giải mã link ảo thành file thật, độc lập hoàn toàn
    if [ -f "${IMAGE_LINK_NAME}.rootfs.wic" ]; then
        cp -L "${IMAGE_LINK_NAME}.rootfs.wic" "${wic_out}/"
    fi
    if [ -f "${IMAGE_LINK_NAME}.rootfs.wic.bmap" ]; then
        cp -L "${IMAGE_LINK_NAME}.rootfs.wic.bmap" "${wic_out}/"
    fi
    if [ -f "${IMAGE_LINK_NAME}.rootfs.tar.bz2" ]; then
        cp -L "${IMAGE_LINK_NAME}.rootfs.tar.bz2" "${flash_out}/"
    fi

    # Bước 4: Copy đích danh các file Bootloader & Kernel sạch
    cp -L MLO "${flash_out}/" 2>/dev/null || true
    cp -L u-boot.img "${flash_out}/" 2>/dev/null || true
    cp -L zImage "${flash_out}/" 2>/dev/null || true

    # Bước 5: Copy đích danh các file Device Tree (.dtb) sạch, không lấy file timestamp
    cp -L am335x-bone.dtb "${flash_out}/" 2>/dev/null || true
    cp -L am335x-boneblack.dtb "${flash_out}/" 2>/dev/null || true
    cp -L am335x-bonegreen.dtb "${flash_out}/" 2>/dev/null || true
}

do_image_complete[postfuncs] += "organize_and_copy_artifacts"