In general, a series of modules related to the Network are enabled by default. However, it is noticed that most Network test items are failed during SCT test execution. The most likely reason is the lack of a UNDI driver built in the current platform firmware codebase. RiscVVirt('-machine virt') comes with e1000 as the default NIC device. However, as this device lacks an integrated UEFI UNDI driver, it cannot provide the foundational services to enable the network.
The following proposals could be the reference solutions:
1. Build Intel UNDI driver binary to the FD.
2. Build UsbNetwork/NetworkCommon.inf to the FD.
1. Build edk2-platforms/Drivers/OptionRomPkg/UndiRuntimeDxe/UndiRuntimeDxe.inf to the FD.
1. Build 3rd party UNDI driver to the FD.

From a testing perspective, solution 3 is the recommended approach, here are two recommended steps:
* Build UndiRuntimeDxe to your firmware FD, with the following patch: edk2-platforms/Drivers/OptionRomPkg/UndiRuntimeDxe/UndiRuntimeDxe.inf
* Append NIC 'i82557b' to the qemu command line. 
So, if you intend to enable the edk2 network stack with QEMU in the boot flow, it is suggested to use the following command:

```
 ./qemu-system-riscv64 -nographic -m 8G -smp 2 \
 -machine virt,pflash0=pflash0,pflash1=pflash1 \
 -blockdev node-name=pflash0,driver=file,read-only=on,filename=$FW_DIR/RISCV_SP_CODE.fd \
 -blockdev node-name=pflash1,driver=file,filename=$FW_DIR/RISCV_SP_VARS.fd \
 -bios $Sbi_DIR/fw_dynamic.bin \
 -drive file=$Img_DIR/brs_live_image.img,if=ide,format=raw \
 -device i82557b,netdev=net2 \
 -netdev type=user,id=net2
```

From a product implementation perspective, it is not recommended to directly use UndiRuntimeDxe as the provider for the UNDI services. It is more appropriate to provide the UNDI services based on the NIC device integrated into the platform.