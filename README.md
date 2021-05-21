# Base Boot Requirements - Architecture Compliance Suite
BBR specification complements the BSA specification by defining the base firmware requirements
required for out-of-box support of any BSA compatible operating system or hypervisor. These requirements are comprehensive enough
to enable booting multi-core ARM platforms while remaining minimal enough to allow for OEM and ODM innovation, and
market differentiation.

For more information, see [BBR specification](https://developer.arm.com/documentation/den0044/latest).

The BBR test suites check for compliance against the SBBR/EBBR specification. The BBR tests are delivered through:
  - UEFI Self Certification Tests (SCT)
  - Firmware Test Suite (FWTS)

## Release details
- Code Quality: v0.8 Beta-0
- The BBR tests are written for version 1.0 of the BBR specification.
- The compliance suite is not a substitute for design verification.
- To review the ACS logs, Arm licensees can contact Arm directly through their partner managers


## Building BBR
BBR is automatically built and packaged into ACS, but it can also be built independently.

#### 1.  Get BBR repository 
    `git clone https://github.com/ARM-software/bbr-acs.git` 

#### 2. Getting the required Source codes and Tools 
navigate to the `bbr-acs/<ebbr/sbbr>/scripts` directory

get source by running the
`./build-scripts/get_<ebbr/sbbr>_source.sh`

This will download `edk2-test, edk2, fwts and tools`

#### 3. Building ACS for SBBR & EBBR
 run
`./build-scripts/build_<ebbr/sbbr>.sh`
to build BBR ACS components, SCT and FWTS.

The script will apply  patches to create a "EBBR or SBBR" build recipe in the SCT/FWTS build system.

The the binaries of SCT are generated here
    `bbr-acs/<ebbr/sbbr>/scripts/edk2-test/uefi-sct/<ARCH>_SCT #(i.e. AARCH64_SCT)`

The the binaries of FWTS are generated here
    `bbr-acs/<ebbr/sbbr>/scripts/fwts/fwts_output`


## UEFI Self Certification Tests
Self-Certification Tests (SCT) test the UEFI implementation requirements defined by SBBR/EBBR. 

**Prerequisite** : Ensure that the system time is correct before starting SCT tests.

### Running SCT
BBR SCT tests are built as part of the test suite <br />

Running of BBR SCT tests is now automated. You can choose to skip the automated SCT tests by pressing any key when the UEFI shell prompts.

- Shell>Press any key to stop the EFI SCT running

To run SCT manually, Follow these steps:


1. `Shell>FS(X):`
- `FS(X):>cd EFI\BOOT\bbr\SCT`
- To run EBBR or SBBR tests
 `FS(X):EFI\BOOT\bbr\SCT>SCT -s <ebbr.seq/sbbr.seq>`
 - To run all tests
 `FS(X):EFI\BOOT\bbr\SCT>SCT -a -v`
 

The User can also select and run tests individually. For information about running the tests, see [SCT User Guide](http://www.uefi.org/testtools).


## Firmware Test Suite
Firmware Test Suite (FWTS) is a package that is hosted by Canonical. FWTS provides tests for ACPI, SMBIOS and UEFI.
Several SBBR assertions are tested though FWTS.

### Running FWTS tests

You can choose to boot Linux OS from UEFI by entering the command:

`Shell>exit`

This command loads the grub menu. Press enter to choose the option 'Linux BusyBox' that boots the OS and runs FWTS tests and OS context BSA tests automatically. <br />

Logs are stored into the a results partition, which can be viewed on any machine after tests are run. 


## License
 
Arm BBR ACS is distributed under Apache v2.0 License.


## Feedback, contributions and support

 - For feedback, use the GitHub Issue Tracker that is associated with this repository.
 - For support, please send an email to "support-systemready-acs@arm.com" with details.
 - Arm licensees may contact Arm directly through their partner managers.
 - Arm welcomes code contributions through GitHub pull requests. See GitHub documentation on how to raise pull requests.

--------------

*Copyright (c) 2021, Arm Limited and Contributors. All rights reserved.*
