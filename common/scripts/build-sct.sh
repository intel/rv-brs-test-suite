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
# CROSS_COMPILE - PATH to GCC including CROSS-COMPILE prefix
# PARALLELISM - number of cores to build across
# UEFI_BUILD_ENABLED - Flag to enable building UEFI
# UEFI_PATH - sub-directory containing UEFI code
# UEFI_BUILD_MODE - DEBUG or RELEASE
# UEFI_TOOLCHAIN - Toolchain supported by Linaro uefi-tools: GCC49, GCC48 or GCC47
# UEFI_PLATFORMS - List of platforms to build
# UEFI_PLAT_{platform name} - array of platform parameters:
#     - platname - the name of the platform used by the build
#     - makefile - the makefile to execute for this platform
#     - output - where to store the files in packaging phase
#     - defines - extra platform defines during the build
#     - binary - what to call the final output binary

TOP_DIR=`pwd`
arch=$(uname -m)
UEFI_PATH=edk2
SCT_PATH=edk2-test
UEFI_TOOLCHAIN=GCC5
UEFI_BUILD_MODE=DEBUG
TARGET_ARCH=RISCV64
KEYS_DIR=$TOP_DIR/security-interface-extension-keys
TEST_DB1_KEY=$KEYS_DIR/TestDB1.key
TEST_DB1_CRT=$KEYS_DIR/TestDB1.crt
CROSS_COMPILE=$TOP_DIR/$GCC

# if [[ $BUILD_TYPE = S ]]; then
    BRS_DIR=$TOP_DIR/../..
# else
#     BRS_DIR=$TOP_DIR/rv-brs-test-suite
#     export WORKSPACE=$TOP_DIR/$SCT_PATH/uefi-sct
# fi

BRSI_TEST_DIR=$BRS_DIR/common/sct-tests/brsi-tests
# if [[ $BUILD_TYPE = S ]]; then
    sed -i 's|^SctPkg/TestCase/UEFI/EFI/RuntimeServices/SecureBoot/BlackBoxTest/SecureBootBBTest.inf|#SctPkg/TestCase/UEFI/EFI/RuntimeServices/SecureBoot/BlackBoxTest/SecureBootBBTest.inf|g' $BRS_DIR/common/sct-tests/brsi-tests/BRS_SCT.dsc
    sed -i 's|^SctPkg/TestCase/UEFI/EFI/RuntimeServices/BBSRVariableSizeTest/BlackBoxTest/BBSRVariableSizeBBTest.inf|#SctPkg/TestCase/UEFI/EFI/RuntimeServices/BBSRVariableSizeTest/BlackBoxTest/BBSRVariableSizeBBTest.inf|g' $BRS_DIR/common/sct-tests/brsi-tests/BRS_SCT.dsc
    sed -i 's|^SctPkg/TestCase/UEFI/EFI/Protocol/TCG2Protocol/BlackBoxTest/TCG2ProtocolBBTest.inf|#SctPkg/TestCase/UEFI/EFI/Protocol/TCG2Protocol/BlackBoxTest/TCG2ProtocolBBTest.inf|g' $BRS_DIR/common/sct-tests/brsi-tests/BRS_SCT.dsc
    sed -i 's|^SctPkg/TestCase/UEFI/EFI/RuntimeServices/SecureBoot/BlackBoxTest/Dependency/Images/Images.inf|#SctPkg/TestCase/UEFI/EFI/RuntimeServices/SecureBoot/BlackBoxTest/Dependency/Images/Images.inf|g' $BRS_DIR/common/sct-tests/brsi-tests/BRS_SCT.dsc
# fi

do_build()
{

    pushd $TOP_DIR/$SCT_PATH
    export KEYS_DIR=$TOP_DIR/security-interface-extension-keys
    export EDK2_TOOLCHAIN=$UEFI_TOOLCHAIN
    export PATH="$TOP_DIR/efitools:$PATH"

    export EDK2_TOOLCHAIN=$UEFI_TOOLCHAIN
    export ${UEFI_TOOLCHAIN}_RISCV64_PREFIX=$CROSS_COMPILE

    # # export EDK2 enviromnent variables
    # export PACKAGES_PATH=$TOP_DIR/$UEFI_PATH
    # export PYTHON_COMMAND=/usr/bin/python3
    # #export HOST_ARCH = `uname -m`
    # #MACHINE=`uname -m`

    # #Build base tools
    if [ ! -d $TOP_DIR/$SCT_PATH/uefi-sct/edk2 ]; then
    	ln -s $TOP_DIR/edk2 $TOP_DIR/$SCT_PATH/uefi-sct/edk2
    fi
    source $TOP_DIR/$UEFI_PATH/edksetup.sh || ture
    make -C $TOP_DIR/$UEFI_PATH/BaseTools

    #Copy over extra files needed for BRSI tests
    # if [[ $BUILD_PLAT != SIE ]] ; then
        # cp -r $BRSI_TEST_DIR/BrsiBootServices uefi-sct/SctPkg/TestCase/UEFI/EFI/BootServices/
        cp -r $BRSI_TEST_DIR/BrsiEfiSpecVerLvl  uefi-sct/SctPkg/TestCase/UEFI/EFI/Generic/
        # cp -r $BRSI_TEST_DIR/BrsiRequiredUefiProtocols $BRSI_TEST_DIR/BrsiSmbios $BRSI_TEST_DIR/BrsiSysEnvConfig uefi-sct/SctPkg/TestCase/UEFI/EFI/Generic/
        # cp -r $BRSI_TEST_DIR/BrsiRuntimeServices uefi-sct/SctPkg/TestCase/UEFI/EFI/RuntimeServices/
        cp $BRSI_TEST_DIR/BRS_SCT.dsc uefi-sct/SctPkg/UEFI/
        cp $BRSI_TEST_DIR/build_brs.sh uefi-sct/SctPkg/
    # fi

    #Startup/runtime files.
    mkdir -p uefi-sct/SctPkg/BRS
    #BRSI
    cp $BRS_DIR/brsi/config/BRSIStartup.nsh uefi-sct/SctPkg/BRS/
    cp $BRS_DIR/brsi/config/BRSI.seq uefi-sct/SctPkg/BRS/
    cp $BRS_DIR/brsi/config/BRSI_manual.seq uefi-sct/SctPkg/BRS/
    cp $BRS_DIR/brsi/config/BRSI_extd_run.seq uefi-sct/SctPkg/BRS/
    cp $BRS_DIR/brsi/config/EfiCompliant_BRSI.ini  uefi-sct/SctPkg/BRS/

    pushd uefi-sct
    DSC_EXTRA="ShellPkg/ShellPkg.dsc MdeModulePkg/MdeModulePkg.dsc" ./SctPkg/build_brs.sh $TARGET_ARCH GCC ${UEFI_BUILD_MODE}  -n $PARALLELISM

    popd
}

do_clean()
{
    pushd $TOP_DIR/$SCT_PATH/uefi-sct
    if [[ $arch != "riscv64" ]]; then
        CROSS_COMPILE_DIR=$(dirname $CROSS_COMPILE)
        PATH="$PATH:$CROSS_COMPILE_DIR"
    fi
    #Build base tools
    if [ ! -d $TOP_DIR/$SCT_PATH/uefi-sct/edk2 ]; then
    	ln -s $TOP_DIR/edk2 $TOP_DIR/$SCT_PATH/uefi-sct/edk2
    fi
    source $TOP_DIR/$UEFI_PATH/edksetup.sh || ture
    make -C $TOP_DIR/$UEFI_PATH/BaseTools clean
    rm -rf Build
    rm -rf ${TARGET_ARCH}_SCT

    popd

}
# sign SCT efi files
SecureBootSign() {
    echo "KEYS_DIR = $KEYS_DIR"

    for f in $1/*.efi
    do
        echo "sbsign --key $TEST_DB1_KEY --cert $TEST_DB1_CRT $f --output $f"
        sbsign --key $TEST_DB1_KEY --cert $TEST_DB1_CRT $f --output $f
    done
}

do_package ()
{
    echo "Packaging sct... $VARIANT";
    # Copy binaries to output folder
    pushd $TOP_DIR/$SCT_PATH/uefi-sct

    mkdir -p ${TARGET_ARCH}_SCT/SCT

        #BRSI
        mkdir -p ${TARGET_ARCH}_SCT/SCT/Dependency/EfiCompliantBBTest ${TARGET_ARCH}_SCT/SCT/Sequence
        cp -r Build/UefiSct/${UEFI_BUILD_MODE}_${UEFI_TOOLCHAIN}/SctPackage${TARGET_ARCH}/${TARGET_ARCH}/* ${TARGET_ARCH}_SCT/SCT/
        cp SctPkg/BRS/EfiCompliant_BRSI.ini ${TARGET_ARCH}_SCT/SCT/Dependency/EfiCompliantBBTest/EfiCompliant.ini
        cp SctPkg/BRS/BRSI_manual.seq ${TARGET_ARCH}_SCT/SCT/Sequence/BRSI_manual.seq
        cp SctPkg/BRS/BRSI_extd_run.seq ${TARGET_ARCH}_SCT/SCT/Sequence/BRSI_extd_run.seq
        cp SctPkg/BRS/BRSI.seq ${TARGET_ARCH}_SCT/SCT/Sequence/BRSI.seq
        cp SctPkg/BRS/BRSIStartup.nsh ${TARGET_ARCH}_SCT/SctStartup.nsh
        #BBSR
        # cp $BRS_DIR/bbsr/config/sie_SctStartup.nsh ${TARGET_ARCH}_SCT/sie_SctStartup.nsh
        # cp $BRS_DIR/bbsr/config/BBSR.seq  ${TARGET_ARCH}_SCT/SCT/Sequence
        cp $TOP_DIR/edk2-test/uefi-sct/SctPkg/BRS/BRSI.seq  $TOP_DIR/edk2-test/uefi-sct/Build/UefiSct/${UEFI_BUILD_MODE}_${UEFI_TOOLCHAIN}/SctPackage${TARGET_ARCH}/${TARGET_ARCH}/Sequence/

    pushd $TOP_DIR

}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/framework.sh $@

