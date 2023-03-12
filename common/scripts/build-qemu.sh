#!/usr/bin/env bash

TOP_DIR=`pwd`

build_qemu()
{
    if [ -f "$TOP_DIR/qemu/build/qemu-system-riscv64" ];then
	    echo "skip build qemu-riscv64"
    else
	    echo "build qemu-riscv64"
	    pushd $TOP_DIR/qemu
	    ./configure  --enable-debug --target-list=riscv64-softmmu
	    make -j `nproc`
	    popd
    fi
}

start_qemu()
{
    echo "Starting rv64 qemu..."
    ./qemu/build/qemu-system-riscv64  -nographic\
     -drive file=$TOP_DIR/uefi_qemu_flash1.img,if=pflash,format=raw,unit=1 -machine virt -m 2G -smp 2 -numa node,mem=1G -numa node,mem=1G \
     -drive file=fat:rw:$TOP_DIR/edk2-test/uefi-sct/Build/UefiSct/RELEASE_GCC5/SctPackageRISCV64/,id=hd0 -device virtio-blk-device,drive=hd0  -device e1000,netdev=net0 -netdev user,id=net0
}

build_qemu
# start_qemu
