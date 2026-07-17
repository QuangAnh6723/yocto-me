# linux-yocto_%.bbappend
FILESEXTRAPATHS:prepend := "${THISDIR}/linux-yocto:"

SRC_URI:append:bbb-custom = " file://bbb-custom-leds.dtsi"

do_configure:append:bbb-custom() {
    install -m 0644 ${WORKDIR}/bbb-custom-leds.dtsi ${S}/arch/arm/boot/dts/
}