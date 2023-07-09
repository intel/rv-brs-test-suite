#!/bin/bash

################################################################################
# Script: get_efi_offset.sh
#
# Description:
#   This script is used to extract the load address of an EFI file for GDB
#   debugging purposes. It assumes that you have an example EFI file which you
#   want to debug.
#
# Usage:
#   ./get_efi_offset.sh <edk2 build path> <edk2-test build path> <qemu debug.log> <output filename>
#
# Arguments:
#   <edk2_build_path>: The path to the edk2 build directory.
#   <edk2-test_build_path>: The path to the edk2-test build directory.
#   <qemu debug.log>: Qemu log with uefi debug enabled.
#   <output filename>: Gdb script file generated.
#
# Notes:
#   - Ensure that you have the the specified edk2 and edk2-test build path is the same used in qemu.
################################################################################


# Function to print script usage
print_usage() {
    echo "Usage: $0 <edk2 build path> <edk2-test build path> <qemu debug.log filepath> <output filename>"
}

# Check if all required arguments are provided
if [ $# -ne 4 ]; then
    print_usage
    exit 1
fi

edk2_build_path="$1"
edk2_test_build_path="$2"
qemu_debug_log="$3"
output_filename="$4"

# Check if edk2 build path, edk2-test build path, qemu debug log, and output filename exist
if [ ! -d "$edk2_build_path" ] || [ ! -d "$edk2_test_build_path" ] || [ ! -f "$qemu_debug_log" ] || [ -e "$output_filename" ]; then
    if [ ! -d "$edk2_build_path" ]; then
        echo "Error: EDK2 build path '$edk2_build_path' does not exist."
    fi
    
    if [ ! -d "$edk2_test_build_path" ]; then
        echo "Error: EDK2-test build path '$edk2_test_build_path' does not exist."
    fi
    
    if [ ! -f "$qemu_debug_log" ]; then
        echo "Error: QEMU debug log file '$qemu_debug_log' does not exist."
    fi
    
    if [ -e "$output_filename" ]; then
        echo "Warning: Output filename '$output_filename' already exists."
        read -p "Do you want to overwrite it? (y/n) " choice
        if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
            echo "Exiting script."
            exit 0
        else
	    > $output_filename
        fi
    fi
fi

# Download preinfo repo if it doesn't exist
if [ ! -d "peinfo" ]; then
    git clone https://github.com/retrage/peinfo.git || { echo "Failed to download preinfo repo."; exit 1; }
fi

# Check if peinfo executable exists
if [ ! -x "peinfo/peinfo" ]; then
    # Build peinfo
    cd peinfo || { echo "Failed to change directory to 'peinfo'."; exit 1; }
    make || { echo "Failed to build peinfo."; exit 1; }
    cd .. || { echo "Failed to change directory."; exit 1; }
fi
PEINFO="peinfo/peinfo"
cat ${qemu_debug_log} | grep Loading | grep -i efi | tac | while read LINE; do
   BASE="`echo ${LINE} | cut -d " " -f4`"
   NAME="`echo ${LINE} | cut -d " " -f6 | tr -d "[:cntrl:]"`"
   if [ -e ${edk2_build_path}/${NAME} ];then
       efi_file_path=$edk2_build_path
   elif [ -e ${edk2_test_build_path}/${NAME} ];then
       efi_file_path=$edk2_test_build_path
   else
       echo "${edk2_test_build_path}/${NAME} for ${edk2_build_path}/${NAME} not exist!" 1>&2
       continue
   fi
   ADDR="`${PEINFO} ${efi_file_path}/${NAME} \
        | grep -A 5 text | grep VirtualAddress | cut -d " " -f2`"
   TEXT="`python -c "print(hex(${BASE} + ${ADDR}))"`"
   SYMS="`echo ${NAME} | sed -e "s/\.efi/\.debug/g"`"
   # Check if line exists in the output file and update or append accordingly
   grep -qF "add-symbol-file ${efi_file_path}/${SYMS}" "$output_filename" && \
   sed -i 's/add-symbol-file ${efi_file_path}\/${SYMS} .*/add-symbol-file ${efi_file_path}\/${SYMS} ${TEXT}/' "$output_filename" || \
       echo "add-symbol-file ${efi_file_path}/${SYMS} ${TEXT}" >> "$output_filename"

done
echo "update gdb script $output_filename."
