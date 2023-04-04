WD=`pwd`
IMG_NAME=bbr.img
dd if=/dev/zero of=${IMG_NAME} bs=1M count=512
sudo sgdisk -g --clear --new=1:0:+16M: --new=2:0:+100M: -t 2:EF00 -d 1 ${IMG_NAME}
# Mount image in loop device
LOOPID=`sudo losetup --partscan --find --show ${IMG_NAME}`
# X is the device number generated in losetup
sudo mkfs.vfat ${LOOPID}p2
sudo mkdir -p /mnt/brs
sudo mount ${LOOPID}p2 /mnt/brs
sudo mkdir -p /mnt/brs/EFI/BOOT/brs/SCT
sudo mkdir -p /mnt/brs/acs_results
sudo cp -a $WD/edk2-test/uefi-sct/Build/UefiSct/DEBUG_GCC5/SctPackageRISCV64/RISCV64/* /mnt/brs/EFI/BOOT/brs/SCT
sudo cp $WD/build-scripts/config/BRSIStartup.nsh /mnt/brs/startup.nsh
sync
sudo umount /mnt/brs
sudo losetup -d ${LOOPID}
echo "generate image at:$WD/${IMG_NAME}"