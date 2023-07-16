#!/usr/bin/env bash

# Copyright (c) 2021, ARM Limited and Contributors. All rights reserved.
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

get_sct_src()
{
    git clone  https://github.com/tianocore/edk2-test
    pushd $TOP_DIR/edk2-test
    git checkout 39f27f233aeab16f71fc8f5ed6b287eb9f884ec6
    popd
}

get_uefi_src()
{
    git clone  https://github.com/tianocore/edk2.git
    pushd $TOP_DIR/edk2
    git checkout 94b5a98ea0b6536f5e9798243edf8b85389adb24
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
    LINUX_KERNEL_VERSION=v6.3-rc1
    echo "Downloading Linux source code. Version : ${LINUX_KERNEL_VERSION}"
    git clone --depth 1 --single-branch --branch aia_plic \
              https://github.com/vlsunil/linux.git linux
}

get_buildroot_src()
{
    BUILDROOT_SRC_VERSION=2023.02
    echo "Downloading Buildroot source code. TAG : ${BUILDROOT_SRC_VERSION}"
    git clone -b $BUILDROOT_SRC_VERSION https://github.com/buildroot/buildroot.git
    pushd $TOP_DIR/buildroot/
    echo "Applying Buildroot patch..."
    git apply $TOP_DIR/../../common/patches/buildroot_update_fwts_version.patch
    git apply $TOP_DIR/../../common/patches/buildroot_enable_busybox_auto_login.patch
    popd
}
function check_requirements() {

  # Check if operating system is Ubuntu and version is 22.04
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  fi

  if [[ "$OS" == "Ubuntu" && ("$VER" == "22.04" || "$VER" == "20.04" )]]; then
      echo "$OS $VER Proceeding with the build..."
  else
      echo "You are running $OS $VER"
      echo "Warning: It is recommended to run this build on Ubuntu 22.04/20.04."\
           "However if you choose to proceed with a different version, press 'y' to continue."
      read -p "Do you want to continue anyway? (y/n) " choice
      case "$choice" in
          y|Y ) ;;
          * ) exit 0;;
      esac
  fi
  # Check free disk space (at least 20GB)
  local disk_space=$(df . -m --output=avail | tail -n 1 | tr -d '[:space:]')
  if [[ $disk_space -lt 20*1024 ]]; then
    echo "Warning: Only $(expr $disk_space / 1024)GB of free disk space remaining."\
          "The application requires at least 20GB of free disk space during the build and test process."
    read -p "Do you want to continue anyway? (y/n) " choice
    case "$choice" in
        y|Y ) ;;
        * ) exit 0;;
    esac
  fi

  if [[ "$OS" == "Ubuntu" || "$OS" == "Debian GNU/Linux" ]]; then
      sudo apt install git curl mtools gdisk gcc openssl automake autotools-dev libtool \
                       bison flex bc uuid-dev python3 libglib2.0-dev libssl-dev autopoint libslirp-dev \
                       make g++ gcc-riscv64-unknown-elf gettext
  fi

}

check_requirements
get_uefi_src
get_sct_src
get_grub_src
get_linux_src
get_buildroot_src

