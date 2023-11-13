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
QEMU_SRC_VERSION=riscv_acpi_b2_v7

get_qemu_src()
{
    if [ ! -f "$TOP_DIR/qemu" ];then
        echo "Downloading qemu. TAG : $QEMU_SRC_VERSION"
        git clone --single-branch \
        --branch riscv_acpi_b2_v7 https://github.com/vlsunil/qemu.git qemu
        pushd $TOP_DIR/qemu
        git checkout 15ecd5f3774b63a5893adb0c0ff657a9b316cb56
        git submodule update --init --recursive
        popd
    fi
}

get_opensbi_src()
{
    if [ ! -f "$TOP_DIR/opensbi" ];then
        echo "Downloading opensbi."
        git clone --depth 1 --single-branch \
        --branch dev-upstream https://github.com/ventanamicro/opensbi.git
        pushd $TOP_DIR/opensbi
        git checkout 9772fd290ad1914bc99cb8d3107c36a589d428ed
        popd
    fi
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

build_edk2()
{
    if [ -f "$TOP_DIR/Build/RiscVVirtQemu/RELEASE_GCC5/FV/RISCV_VIRT_CODE.fd" ];then
	    echo "skip build edk2."
    else
	    echo "build edk2..."
	    pushd $TOP_DIR
        export GCC5_RISCV64_PREFIX=riscv64-linux-gnu-
        export PACKAGES_PATH=$TOP_DIR/edk2
        export EDK_TOOLS_PATH=$TOP_DIR/edk2/BaseTools
        source edk2/edksetup.sh
        make -C edk2/BaseTools clean
        make -C edk2/BaseTools
        make -C edk2/BaseTools/Source/C
        source edk2/edksetup.sh BaseTools
        build -a RISCV64 --buildtarget RELEASE -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t GCC5
        truncate -s 32M Build/RiscVVirtQemu/RELEASE_GCC5/FV/RISCV_VIRT_CODE.fd
        truncate -s 32M Build/RiscVVirtQemu/RELEASE_GCC5/FV/RISCV_VIRT_VARS.fd
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
    $TOP_DIR/qemu/build/qemu-system-riscv64 -nographic \
    -machine virt,aia=aplic,pflash0=pflash0,pflash1=pflash1 \
    -cpu rv64 -m 4G -smp 2   \
    -bios $TOP_DIR/opensbi/build/platform/generic/firmware/fw_dynamic.bin \
    -drive file=$BRS_IMG,if=none,format=raw,id=drv1 -device virtio-blk-device,drive=drv1      \
    -blockdev node-name=pflash0,driver=file,read-only=on,filename=$TOP_DIR/Build/RiscVVirtQemu/RELEASE_GCC5/FV/RISCV_VIRT_CODE.fd \
    -blockdev node-name=pflash1,driver=file,filename=$TOP_DIR/Build/RiscVVirtQemu/RELEASE_GCC5/FV/RISCV_VIRT_VARS.fd \
    -device e1000,netdev=net0 \
    -netdev type=user,id=net0 \
    -device qemu-xhci \
    -device usb-mouse \
    -device usb-kbd
}
get_qemu_src
build_qemu
get_opensbi_src
build_edk2
build_opensbi
start_qemu
