/*++
  The material contained herein is not a license, either
  expressly or impliedly, to any intellectual property owned
  or controlled by any of the authors or developers of this
  material or to any contribution thereto. The material
  contained herein is provided on an "AS IS" basis and, to the
  maximum extent permitted by applicable law, this information
  is provided AS IS AND WITH ALL FAULTS, and the authors and
  developers of this material hereby disclaim all other
  warranties and conditions, either express, implied or
  statutory, including, but not limited to, any (if any)
  implied warranties, duties or conditions of merchantability,
  of fitness for a particular purpose, of accuracy or
  completeness of responses, of results, of workmanlike
  effort, of lack of viruses and of lack of negligence, all
  with regard to this material and any contribution thereto.
  Designers must not rely on the absence or characteristics of
  any features or instructions marked "reserved" or
  "undefined." The Unified EFI Forum, Inc. reserves any
  features or instructions so marked for future definition and
  shall have no responsibility whatsoever for conflicts or
  incompatibilities arising from future changes to them. ALSO,
  THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT,
  QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR
  NON-INFRINGEMENT WITH REGARD TO THE TEST SUITE AND ANY
  CONTRIBUTION THERETO.

  IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THIS MATERIAL OR
  ANY CONTRIBUTION THERETO BE LIABLE TO ANY OTHER PARTY FOR
  THE COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST
  PROFITS, LOSS OF USE, LOSS OF DATA, OR ANY INCIDENTAL,
  CONSEQUENTIAL, DIRECT, INDIRECT, OR SPECIAL DAMAGES WHETHER
  UNDER CONTRACT, TORT, WARRANTY, OR OTHERWISE, ARISING IN ANY
  WAY OUT OF THIS OR ANY OTHER AGREEMENT RELATING TO THIS
  DOCUMENT, WHETHER OR NOT SUCH PARTY HAD ADVANCE NOTICE OF
  THE POSSIBILITY OF SUCH DAMAGES.

  Copyright 2006 - 2016 Unified EFI, Inc. All
  Rights Reserved, subject to all existing rights in all
  matters included within this Test Suite, to which United
  EFI, Inc. makes no claim of right.

  Copyright (c) 2016, ARM Ltd. All rights reserved.
  Copyright (c) 2023 Intel Corporation

--*/
/*++

Module Name:

  BrsBootServicesBBTestMain.h

Abstract:

  Contains definitions for test information and test GUIDs.

--*/

#ifndef _BRSBOOTSERVICES_TEST_MAIN_H_
#define _BRSBOOTSERVICES_TEST_MAIN_H_

#include "Efi.h"
#include "Guid.h"
#include <Library/EfiTestLib.h>

#define BRSBOOTSERVICES_TEST_REVISION 0x00010000

#define BRSBOOTSERVICES_TEST_GUID \
  { 0x236da812, 0x2002, 0x4ad9, {0x88, 0x4d, 0x05, 0x8f, 0xd2, 0xdd, 0x13, 0x86 }}

#define ACPI_TABLE_EXPECTED_LENGTH 36
#define ACPI_TABLE_CHECKSUM_LENGTH 20
#define SMBIOS30_ANCHOR_STRING "_SM3_"
#define RSDP_SIGNATURE_STRING "RSD PTR "

EFI_STATUS
InitializeBBTestBrsBootServices (
  IN EFI_HANDLE           ImageHandle,
  IN EFI_SYSTEM_TABLE     *SystemTable
  );

EFI_STATUS
BBTestBrsBootServicesUnload (
  IN EFI_HANDLE       ImageHandle
  );

//
// Test Case GUIDs
//

#define BRSBOOTSERVICES_MEMORYMAP_GUID \
  { 0x1b610277, 0xcadb, 0x433d, {0xa7, 0xab, 0xa7, 0x7f, 0xe4, 0x26, 0xfb, 0xfd }}

#define BRSBOOTSERVICES_ACPITABLE_GUID \
  { 0xbfc24bf8, 0xe8f8, 0x4c80, {0xb3, 0x30, 0xe6, 0xd6, 0x29, 0xd8, 0x43, 0x24 }}

#define BRSBOOTSERVICES_SMBIOSTABLE_GUID \
  { 0x970c1d8b, 0x17c1, 0x42dd, {0x9b, 0x05, 0x2b, 0x65, 0x37, 0x49, 0x9c, 0xa2 }}

#endif /* _BRSBOOTSERVICES_TEST_MAIN_H_ */
