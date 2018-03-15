#!/bin/bash

CODENAME=releases
VERSION=17.01.4
DEVICE=ar71xx
VARIANT=nand
PROFILE=WNDR4300V1

TOPDIR=$(dirname $(readlink -f $0))
URL="https://downloads.lede-project.org/$CODENAME/${VERSION}/targets/${DEVICE}/${VARIANT}/lede-imagebuilder-${VERSION}-${DEVICE}-${VARIANT}.Linux-x86_64.tar.xz"
BINDIR="bin/targets/$DEVICE/$VARIANT"
FILE=$(basename $URL)
DIR=${FILE%.tar.xz}

PACKAGES="ca-bundle ca-certificates luci luci-theme-material luci-app-firewall uci dnsmasq-full -dnsmasq wpad-mini iptables-mod-tproxy ip kmod-usb-storage-extras kmod-fs-ntfs kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat luci-app-sqm mwan3 luci-app-mwan3 miniupnpd luci-app-upnp luci-app-ddns luci-proto-ipv6"

if [ ! -e $FILE ]; then
  wget $URL
fi

tar -axf $FILE

mkdir -p $TOPDIR/build

cd $DIR

sed -i '/^wndr4300_mtdlayout/{s/23552k/121856k/;s/25600k/123904k/;}' target/linux/ar71xx/image/legacy.mk

for patch in $TOPDIR/patches/*.patch; do
  patch -p1 < $patch
done


make image PROFILE="$PROFILE" PACKAGES="$(echo $PACKAGES)"
cp $BINDIR/*.{tar,img} $TOPDIR/build
cd $TOPDIR/build
