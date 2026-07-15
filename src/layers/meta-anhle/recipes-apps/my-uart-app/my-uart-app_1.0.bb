SUMMARY = "Ung dung gui nhan du lieu UART"
DESCRIPTION = "Gui chuoi text tu may ao ARM64 ra cong ttyAMA1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Khai báo file nguồn cần lấy từ thư mục files/
SRC_URI = "file://main.c"

# Đặt thư mục làm việc tạm thời
S = "${UNPACKDIR}"

# Bước biên dịch (sử dụng compiler của Yocto cấp)
do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} main.c -o my-uart-app
}

# Bước cài đặt: Copy file thực thi sau khi build vào thư mục /usr/bin của OS ảo
do_install() {
    install -d ${D}${bindir}
    install -m 0755 my-uart-app ${D}${bindir}
}