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
# PLATDIR - Platform Output directory
# GRUB_PATH - path to GRUB source
# CROSS_COMPILE - PATH to GCC including CROSS-COMPILE prefix
# PARALLELISM - number of cores to build across
#


TOP_DIR=`pwd`
arch=$(uname -m)
GRUB_TARGET=riscv64-linux-gnu

GRUB_PATH=grub
GRUB_PLAT_CONFIG_FILE=${TOP_DIR}/build-scripts/config/grub_prefix.cfg

do_build ()
{
    if [[ $arch = "riscv64" ]]; then
        CROSS_COMPILE_DIR=''
    else
        CROSS_COMPILE=riscv64-linux-gnu-
    fi

    if [ -d $TOP_DIR/$GRUB_PATH ]; then
        pushd $TOP_DIR/$GRUB_PATH
        echo $CROSS_COMPILE_DIR
        mkdir -p $TOP_DIR/$GRUB_PATH/output
        # On the master branch of grub, commit '35b90906'
        #("gnulib: Upgrade Gnulib and switch to bootstrap tool")
        # required the bootstrap tool to be executed before the configure step.
        if [ -e bootstrap ]; then
            if [ ! -e grub-core/lib/gnulib/stdlib.in.h ]; then
                ./bootstrap
            fi
        fi

        ./autogen.sh

        if [[ $arch = "riscv64" ]]; then
            ./configure \
            --target=riscv64-linux-gnu --with-platform=efi \
            --prefix=$TOP_DIR/$GRUB_PATH/output/ \
            --disable-werror
        else
            ./configure STRIP=${CROSS_COMPILE}strip \
            --target=$GRUB_TARGET --with-platform=efi \
            --prefix=$TOP_DIR/$GRUB_PATH/output/ \
            TARGET_CC=${CROSS_COMPILE}gcc --disable-werror
        fi

        make -j $PARALLELISM install
        output/bin/grub-mkimage -v -c ${GRUB_PLAT_CONFIG_FILE} \
        -o output/grubriscv64.efi -O riscv64-efi --disable-shim-lock -p "" \
        part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 normal chain \
        boot configfile linux help  terminal terminfo configfile \
        lsefi search normal gettext loadenv read search_fs_file search_fs_uuid search_label \
        pgp gcry_sha512 gcry_rsa tpm

        popd
    fi

}

do_clean ()
{
    if [ -d $TOP_DIR/$GRUB_PATH ]; then
        pushd $TOP_DIR/$GRUB_PATH
        rm -rf output
        git clean -fdX
        popd
    fi
}

do_package ()
{
    # sign grub with db key, currently skipped!
    pushd $TOP_DIR/$GRUB_PATH
    popd
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/framework.sh $@

