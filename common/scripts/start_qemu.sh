#!/usr/bin/env bash

# Copyright (c) 2023 Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

TOP_DIR=`pwd`
QEMU_SRC_VERSION=7.2.50

get_qemu_src()
{
    echo "Downloading qemu. TAG : $QEMU_SRC_VERSION"
    git clone --depth 1 --single-branch \
    --branch aia_plic https://github.com/vlsunil/qemu.git
    pushd $TOP_DIR/qemu
    git submodule update --init --recursive
    popd
}

build_opensbi()
{
    if [ -f "$TOP_DIR/opensbi/build/platform/generic/firmware/fw_dynamic.bin" ];then
	    echo "skip build opensbi."
    else
	    echo "build opensbi..."
	    pushd $TOP_DIR/opensbi
	    make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic
	    popd
    fi
}

build_qemu()
{
    if [ -f "$TOP_DIR/qemu/build/qemu-system-riscv64" ];then
	    echo "skip build qemu-riscv64"
    else
	    echo "build qemu-riscv64..."
	    pushd $TOP_DIR/qemu
	    ./configure  --enable-slirp --enable-debug --target-list=riscv64-softmmu
	    make -j `nproc`
	    popd
    fi
}

start_qemu()
{
    BRS_IMG=$TOP_DIR/output/brs_live_image.img
    BRS_IMG_XZ=$TOP_DIR/output/brs_live_image.img.xz

    if [ -e $BRS_IMG ];then
		echo "find image: $BRS_IMG "
	else
        if [ -e $BRS_IMG_XZ ]; then
            echo "decompresing $BRS_IMG_XZ"
            xz -d $BRS_IMG_XZ
        else
            echo "Firmware test suite image: $BRS_IMG_XZ does not exist!" 1>&2
            exit 1
        fi
    fi
    echo "Starting rv64 qemu... press Ctrl+A, X to exit qemu"
    sleep 2
    $TOP_DIR/qemu/build/qemu-system-riscv64 -nographic -machine virt -cpu rv64 -m 4G -smp 2   \
    -drive file=$BRS_IMG,if=none,format=raw,id=drv1 -device virtio-blk-device,drive=drv1      \
    -drive file=$TOP_DIR/../prebuilt_images/uefi_flash1_23.04.img,if=pflash,format=raw,unit=1 \
    -device e1000,netdev=net0 -netdev type=user,id=net0 \
    -device qemu-xhci \
    -device usb-mouse \
    -device usb-kbd
}
get_qemu_src
build_qemu
start_qemu
