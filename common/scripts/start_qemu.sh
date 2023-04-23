#!/usr/bin/env bash

TOP_DIR=`pwd`
QEMU_SRC_VERSION=aa9e7fa4689d1becb2faf67f65aafcbcf664f1ce

get_qemu_src()
{
    echo "Downloading qemu. TAG : $QEMU_SRC_VERSION"
    git clone --depth 1 --single-branch \
    --branch master https://github.com/qemu/qemu.git
    pushd $TOP_DIR/qemu
    git checkout $QEMU_SRC_VERSION
    git submodule update --init --recursive
    popd
}

build_qemu()
{
    if [ -f "$TOP_DIR/qemu/build/qemu-system-riscv64" ];then
	    echo "skip build qemu-riscv64"
    else
	    echo "build qemu-riscv64..."
	    pushd $TOP_DIR/qemu
	    ./configure  --enable-debug --target-list=riscv64-softmmu
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
    -drive file=$TOP_DIR/../prebuilt_images/uefi_flash1_23.04.img,if=pflash,format=raw,unit=1 \
    -machine virt -m 2G -smp 2 -numa node,mem=1G -numa node,mem=1G \
    -device virtio-blk-pci,drive=drv1 \
    -drive format=raw,file=$BRS_IMG,if=none,id=drv1 \
    -device virtio-net-pci,netdev=net0,romfile="" -netdev type=user,id=net0
}
get_qemu_src
build_qemu
start_qemu
