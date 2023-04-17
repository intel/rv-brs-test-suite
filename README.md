# The Boot and Runtime Services - Test Suite
The Boot and Runtime Services (BRS) specification provides the requirements for system vendors and Operating System Vendors (OSVs) to interoperate with one another by providing expectations for the Operating System (OS) to utilize in acts of device discovery, system management, and other rich operations provided in this specification.

For more information, see the [BRS specification](https://github.com/riscv-non-isa/riscv-os-a-see/).

The BRS test suite check for compliance against the BRS specifications. These tests are also delivered through two runtime executable environments:
  - UEFI Self Certification Tests (SCT)
  - Firmware Test Suite (FWTS)

#### Building BRS test suite
- `cd ./brsi/scripts/`
- `./build-scripts/get_brsi_source.sh`
- `./build-scripts/build_brsi.sh`
- `./build-scripts/build_image.sh`
To run the tests with QEMU and a pre-built UEFI image, execute:
- `./build-scripts/run.sh`

## UEFI Self Certification Tests
UEFI SCT tests the UEFI implementation requirements defined by the BRS specification.

**Prerequisite**: Ensure that the system time is correct before starting SCT tests.

### Running SCT
BRS SCT tests are built as part of the test suite. <br />

Running BRS SCT tests is now automated. You can choose to skip the automated SCT tests by pressing any key when the UEFI shell prompts.

- Shell>Press any key to stop the EFI SCT running

To run SCT manually, follow these steps:


1. `Shell>FS(X):`
- `FS(X):>cd EFI\BOOT\brs\SCT`
- To run BRS tests
 `FS(X):EFI\BOOT\brs\SCT>SCT -s <BRSI.seq>`
- To run all tests
 `FS(X):EFI\BOOT\brs\SCT>SCT -a -v`


You can also select and run tests individually. For more information on running the tests, see the [SCT User Guide](http://www.uefi.org/testtools).

### Manual intervention tests
Some SCT tests for the ACS require manual intervention or interaction.
To run the tests, follow these steps.

1. Move or copy the SCT logs into the result partition so they do not get overwritten.

	- `Shell>FS(Y):`
	- `FS(Y):> cd \acs_results\`
	- `FS(Y):\acs_results\> mv sct_results sct_results_orginal`

2. Run manual tests.

	- `FS(X):EFI\BOOT\brs\SCT>SCT -s BRSI_manual.seq`
 
3. While the system runs the reset tests, you may have to manually reset the system if it hangs.

**Note:** The logs for the manual tests will overwrite the logs for the original test run 

is the reason to have a copy of the original test. This new folder contains the logs from the new tests run in the manual sequence file. You may to concatenate some of the logs to view together.



## BRS based on Firmware Test Suite
FWTS is a package hosted by Canonical. FWTS provides tests for ACPI, SMBIOS and UEFI.
Several BRS assertions are tested through FWTS.

### Running FWTS tests

From the UEFI shell, you can choose to boot Linux OS by entering the command:

`Shell>exit`

This command loads the grub menu. Press enter to choose the option 'Linux BusyBox' that boots the OS and runs FWTS tests automatically. <br />

Logs are stored in the results partition, which can be viewed on any machine after the tests are run.

## License
 
Risc-v BRS ACS is distributed under Apache v2.0 License.

## Feedback, contributions and support

 - For feedback, use the GitHub Issue Tracker that is associated with this repository.
 - Welcomes code contributions through GitHub pull requests. See the GitHub documentation on how to raise pull requests.
