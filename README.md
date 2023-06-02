# The Boot and Runtime Services - Test Suite
The Boot and Runtime Services (BRS) specification provides the requirements for system vendors and Operating System Vendors (OSVs) to interoperate with one another by providing expectations for the Operating System (OS) to utilize in acts of device discovery, system management, and other rich operations provided in this specification.

For more information, see the [BRS specification](https://github.com/riscv-non-isa/riscv-os-a-see/).

The BRS test suite check for compliance against the BRS specifications. These tests are also delivered through two runtime executable environments:
  - UEFI Self Certification Tests (SCT)
  - Firmware Test Suite (FWTS)

#### Prerequisites
Ubuntu 22.04 or Docker environment for compatible versions, with at least 20GB of free disk space.
To prevent potential issues, please ensure there is no whitespace (e.g., spaces, tabs, line breaks, carriage returns) in the PATH environment variable. E.g. if you're on WSL, you might want a clean environment without the Windows paths like '/mnt/c/Program Files/'.
#### Steps to Build and Run RV BRS test suite live image
- `git clone https://github.com/intel/rv-brs-test-suite.git`
- `cd rv-brs-test-suite/brsi/scripts/`
- `./build-scripts/get_brsi_source.sh`

	This script will automatically download the required components from the following sources:
	| repo  | source/release            |branch/tag/commit|
	| ------------- | ------------------------------ |------------------|
	| `edk2`  | https://github.com/tianocore/edk2.git       |branch:edk2-stable202208|
	| `UEFI-SCT`   | https://github.com/tianocore/edk2-test     |commit:06f84debb|
	| `grub`   | https://github.com/tekkamanninja/grub.git     |tag:riscv_devel_Nikita_V3|
	| `kernel`   | https://github.com/vlsunil/linux.git     |branch:aia_plic|
	| `buildroot`   | https://github.com/buildroot/buildroot.git     |branch:2023.02|
	| `FWTS`   | https://fwts.ubuntu.com/release/fwts-V23.03.00.tar.gz     |version:v23.03.00|
	
	The following packages are required for the script to run smoothly. If any of these packages are missing, they will be installed:
	curl mtools gdisk gcc openssl automake autotools-dev libtool bison flex bc uuid-dev python3 libglib2.0-dev libssl-dev autopoint gcc-riscv64-unknown-elf gcc g++

- `./build-scripts/build_brsi.sh`
- `./build-scripts/build_image.sh`

If everything goes well, the live image will be available at `brsi/scripts/output/brs_live_image.img.xz`
Note: it would take around 1 hour to finish the build, if you just want to have a quick try,
you can use the prebuilt images in `rv-brs-test-suite/brsi/prebuilt_images/`

To run the tests with QEMU and the live image, execute:
- `./build-scripts/start_qemu.sh`

	This script will automatically download the required components from the following sources:
	| repo  | source            |branch|
	| ------------- | ------------------------------ |------------------|
	| `QEMU`  | https://github.com/vlsunil/qemu.git       |branch:aia_plic|
This would start the live image and automatically run the UEFI SCT tests without intervention. After finishing the SCT tests,
it would boot to the linux and stop at the login:
```
Welcome to Buildroot
buildroot login:
```

and then you can login with user name `root`. After login to the linux system, you can run the FWTS test by enter `fwts`.

## UEFI Self Certification Tests
UEFI SCT tests the UEFI implementation requirements defined by the BRS specification.

**Prerequisite**: Ensure that the system time is correct before starting SCT tests.

### Running SCT
The BRS SCT tests are built as part of the test suite. <br />

Running BRS SCT tests is now automated. You can choose to skip the automated SCT tests by pressing any key when the UEFI shell prompts.

- Shell>Press any key to stop the EFI SCT running

To run SCT manually, follow these steps:


1. `Shell>FS(X):`
- `FS(X):>cd EFI\BOOT\brs\SCT`
- To run BRS tests
 `FS(X):EFI\BOOT\brs\SCT>SCT -s BRSI.seq`
- To run all tests
 `FS(X):EFI\BOOT\brs\SCT>SCT -a -v`


You can also select and run tests individually. For more information on running SCT, see the [SCT User Guide](http://www.uefi.org/testtools).

### Manual intervention tests
Some SCT tests require manual intervention or interaction.
To run the tests, follow these steps.

1. Move or copy the SCT logs into the result partition so they do not get overwritten.

	- `Shell>FS(Y):`
	- `FS(Y):> cd \acs_results\`
	- `FS(Y):\acs_results\> mv sct_results sct_results_orginal`

2. Run manual tests.

	- `FS(X):EFI\BOOT\brs\SCT>SCT -s BRSI_manual.seq`
 
3. While the system runs the reset tests, you may have to manually reset the system if it hangs.

**Note:** The logs for the manual tests will overwrite the logs for the original test run which is the reason to have a copy of the original test. This new folder contains the logs from the new tests run in the manual sequence file. You may to concatenate some of the logs to view together.
### SCT test log analysis
SCT log will store at:

	- `FS(Y):\acs_results\sct_results_previous_run\sct_results\Overall\>`
	- `03/22/2023  11:48           9,678,122  Summary.ekl`
	- `03/22/2023  11:48          11,523,502  Summary.log`

Take the `PlatformSpecificElements` test case as an example. This particular test case is divided into several sub-tests, and each sub-test will print a brief log to aid in debugging. This log can be particularly helpful in identifying any issues or errors that may arise during the testing process.

```
  UEFI 2.6
  Test Configuration #0
  ------------------------------------------------------------
  Check the platform specific elements defined in the UEFI Spec Section 2.6.2                                  <<<<case description
  ------------------------------------------------------------
  Logfile: "\EFI\BOOT\brs\SCT\Overall\Summary.log"
  Test Started: 03/22/23  11:48a
  ------------------------------------------------------------
  UEFI Compliant - Console protocols must be implemented -- PASS                                               <<<<sub-test status
  8F7556C2-4665-4353-A3AF-9C005A1E63E1                                                                         <<<<guid
  /ptah_to_source_code/EfiCompliantBBTestPlatform_uefi.c:1022:Text Input - Yes, Text Output - Yes, Text ...    <<<<detail debug log
  ...
  UEFI Compliant - Boot from network protocols must be implemented -- FAILURE
  98551AE7-5020-4DDD-861A-CFFFB4D60382
  /ptah_to_source_code/EfiCompliantBBTestPlatform_uefi.c:1594:PXE BC - No, SNP - Yes, MNP - No, UNDI - No

  UEFI Compliant - UEFI General Network Application required -- WARNING
  76A6A1B0-8C53-407D-8486-9A6E6332D3CE
  /ptah_to_source_code/EfiCompliantBBTestPlatform_uefi.c:1729:MnpSB-N, ArpSB-N, Ip4SB-N, Dhcp4SB-N, Tcp4SB-N,...
  ...
  PlatformSpecificElements: [FAILED]                                                                           <<<<case summary
    Passes........... 8
    Warnings......... 18
    Errors........... 4
  ------------------------------------------------------------
```

## Firmware Test Suite (FWTS)

The Firmware Test Suite (FWTS), a package hosted by Canonical, provides tests for ACPI, SMBIOS and UEFI. Quite a few BRS assertions are tested through FWTS, especially for BRS-I.

### Running FWTS tests manually

From the UEFI shell, you can choose to boot Linux OS by entering the command:

```
Shell>FS0:
FS0:\> cd EFI
FS0:\EFI\> cd BOOT
FS0:\EFI\BOOT\> bootriscv64.efi
```

This command loads the grub menu. Press enter to choose the option `Linux Buildroot` that boots the OS, finally the login message would prompt and wait for input. <br />
```
Welcome to Buildroot
buildroot login:
```

Then you can login with user name `root` and run the FWTS test by enter `fwts`. `results.log` will be stored in the current directory when trigger the fwts test.

## License
 
Risc-v BRS test suite is distributed under Apache v2.0 License.

## Feedback, contributions and support

 - For feedback, use the GitHub Issue Tracker that is associated with this repository.
 - Welcomes code contributions through GitHub pull requests. See the GitHub documentation on how to raise pull requests.
