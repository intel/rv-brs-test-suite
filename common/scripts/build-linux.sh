#!/usr/bin/env bash

# Copyright (c) 2021-2023, ARM Limited and Contributors. All rights reserved.
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

#
# This script uses the following environment variables from the variant
#
# VARIANT - build variant name
# TOP_DIR - workspace root directory
# PARALLELISM - number of cores to build across
# LINUX_PATH - sub-directory containing Linux code
# LINUX_ARCH - Build architecture (riscv)
# LINUX_IMAGE_TYPE - Image or zImage (Image is the default if not specified)
# LINUX_OUT_DIR - directory store the built linux image

TOP_DIR=`pwd`
LINUX_ARCH=riscv
LINUX_IMAGE_TYPE=Image
LINUX_PATH=$TOP_DIR/linux
LINUX_OUT_DIR=out

do_build ()
{
    export ARCH=$LINUX_ARCH

    pushd $LINUX_PATH
    mkdir -p $LINUX_OUT_DIR
    echo "Building using defconfig..."
    cp arch/riscv/configs/defconfig $LINUX_OUT_DIR/.config
    arch=$(uname -m)
    if [[ $arch = "riscv64" ]]
    then
        echo "riscv64 machine"
        make ARCH=riscv O=$LINUX_OUT_DIR olddefconfig
    else
        echo "x86 cross compile"
        make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- O=$LINUX_OUT_DIR olddefconfig
    fi
    #Configurations needed for FWTS
    sed -i 's/# CONFIG_EFI_TEST is not set/CONFIG_EFI_TEST=y/g' $LINUX_OUT_DIR/.config
    sed -i 's/# CONFIG_DMI_SYSFS is not set/CONFIG_DMI_SYSFS=y/g' $LINUX_OUT_DIR/.config
    sed -i 's/# CONFIG_CGROUP_FREEZER is not set/CONFIG_CGROUP_FREEZER=y/g' $LINUX_OUT_DIR/.config

    if [[ $arch = "riscv64" ]]
    then
        echo "riscv64 machine"
        make ARCH=riscv O=$LINUX_OUT_DIR -j$PARALLELISM
    else
        make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- O=$LINUX_OUT_DIR -j$PARALLELISM
    fi
    popd
}

do_clean ()
{
    export ARCH=$LINUX_ARCH

    pushd $LINUX_PATH
    make O=$LINUX_OUT_DIR distclean
    popd

    rm -rf $LINUX_PATH/$LINUX_OUT_DIR
}

do_package ()
{
    echo "Packaging Linux... $VARIANT";
    # Copy binary to output folder
    pushd $TOP_DIR

    cp $LINUX_PATH/$LINUX_OUT_DIR/arch/$LINUX_ARCH/boot/$LINUX_IMAGE_TYPE \
    ${OUTDIR}/$LINUX_IMAGE_TYPE
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/framework.sh $@
