#!/usr/bin/env bash

# Copyright (c) 2021, ARM Limited and Contributors. All rights reserved.
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
GRUB_SRC_TAG=grub-2.06

get_fwts_src()
{
    git clone --single-branch https://git.launchpad.net/fwts
    pushd $TOP_DIR/fwts
    git checkout V23.01.00
    git submodule update --init
    popd
}
get_sct_src()
{
    git clone --single-branch https://github.com/tianocore/edk2-test
    pushd $TOP_DIR/edk2-test
    git checkout 06f84debb796b2f6ac893b130e90ab5599195b29
    popd
}

get_uefi_src()
{
    git clone --depth 1 --single-branch \
    --branch edk2-stable202208 https://github.com/tianocore/edk2.git
    pushd $TOP_DIR/edk2
    git submodule update --init
    popd
}

get_grub_src()
{
    GRUB_SRC_TAG=riscv_devel_Nikita_V3
    echo "Downloading grub source code,Version: ${GRUB_SRC_TAG}"
    git clone -b $GRUB_SRC_TAG https://github.com/tekkamanninja/grub.git grub
    pushd $TOP_DIR/grub
    echo "Applying Grub patch..."
    git apply $TOP_DIR/../../common/patches/grub_update_default_gunlib_url.patch
    popd
}

get_linux_src()
{
    LINUX_KERNEL_VERSION=acpi-6.2
    echo "Downloading Linux source code. Version : ${LINUX_KERNEL_VERSION}"
    git clone --branch $LINUX_KERNEL_VERSION \
        https://github.com/intel-innersource/frameworks.platforms.risc-v.linux-kernel.git linux
}

get_buildroot_src()
{
    BUILDROOT_SRC_VERSION=2023.02
    echo "Downloading Buildroot source code. TAG : ${BUILDROOT_SRC_VERSION}"
    git clone -b $BUILDROOT_SRC_VERSION https://github.com/buildroot/buildroot.git
    pushd $TOP_DIR/buildroot/package/fwts
    echo "Applying Buildroot FWTS patch..."
    git apply $TOP_DIR/../../common/patches/build_fwts_version.patch
    popd
}

sudo apt install git curl mtools gdisk gcc openssl automake autotools-dev libtool \
                 bison flex bc uuid-dev python3 libglib2.0-dev libssl-dev autopoint

get_uefi_src
get_sct_src
get_fwts_src
get_grub_src
get_linux_src
get_buildroot_src

