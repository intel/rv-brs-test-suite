# RV BRS Test Suite Developer Guide

This guide provides instructions for developers to add user-defined test cases, update components, build single components, verify private changes, and contribute upstream.

## Adding User-Defined UEF-SCT Test Cases
To add a user-defined SCT test case in the BRS test suite, please follow the steps below:

1. Create a new directory for your test under the `common/sct-tests/brsi-tests` directory.
2. Add source files (`.inf`, `.c`, `.h`, etc.) to this directory.
3. Update the `common/sct-tests/brsi-tests/BRS_SCT.dsc` Driver Source Code file by adding the new directory path within the `<TestDirs>` element.
4. Build the project by running:`rv-brs_commit/brsi/scripts$ ./build-scripts/build-sct.sh`
5. Update image with `rv-brs_commit/brsi/scripts$ ./build-scripts/build_image.sh` 
6. Follow `README.md` to run testcase to verify whether the testcase works as expected.
7. Refer to the EDK2 community [support page](https://github.com/tianocore/tianocore.github.io/wiki/Community-Support) for more information on SCT development and related issues. Also, here is a commit example that adds a new testcase https://github.com/tianocore/edk2-test/pull/65.

## Upstreaming Changes to UEFI-SCT
If you want to upstream changes to UEFI-SCT, follow these steps:

1. Clone the [UEFI-SCT GitHub repository](https://github.com/tianocore/edk2-test/tree/master/uefi-sct).
2. Adhere to the UEFI-SCT contribution guidelines and follow the [EDK2 Git workflow](https://github.com/tianocore/tianocore.github.io/wiki/How-To-Contribute) to commit to the UEFI-SCT repository.

Note: Use the patched file located in `common/patches` and apply the patch within the `script/brsi/scripts/build-scripts/build_brsi.sh` before changes are accepted.

## Updating Components version in BRS Test Suite
To update components, such as UEFI-SCT or linux, along with a private component in the BRS test suite, follow these steps:

1. Update the `<repository>` and/or `<branch/tag/commit>` element(s) in the `brsi/scripts/build-scripts/get_source.sh` file.
2. Remove the old directory and run `brsi/scripts/build-scripts/get_brsi_source.sh` to update the component.
3. Follow the `README.md` to build the project and confirm that the updated component version is included in the final image.

### Updating FWTS version in BRS Test Suite
Since the FWTS was a builtin package of buildroot, its version depend on that of buildroot. If you need a different FWTS, a fresh patch was needed to update the FWTS version(`common/patches/build_fwts_version.patch`). Once you updated the aforementioned patch, please remove the old buildroot source directory and run the `get_brsi_source.sh` again to include the changes.

For any issues or further queries, please feel free to raise them as a GitHub issue.
