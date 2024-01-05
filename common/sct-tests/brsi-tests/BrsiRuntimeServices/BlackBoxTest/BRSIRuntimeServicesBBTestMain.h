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

  Copyright (c) 2016, ARM Corporation. All rights reserved.<BR>
  Copyright (c) 2024 Intel Corporation

--*/
/*++

Module Name:

  BRSIRuntimeServicesBBTestMain.h

Abstract:

  Header file for BRSIRuntimeServicesBBTestMain.c.

--*/

#ifndef _BRSIRUNTIMESERVICES_TEST_MAIN_H_
#define _BRSIRUNTIMESERVICES_TEST_MAIN_H_

#include "Efi.h"

#define BRSIRUNTIMESERVICES_TEST_REVISION 0x00010000

#define BRSIRUNTIMESERVICES_TEST_GUID     \
{ 0x1c3c483b, 0x3ba3, 0x42ab, {0x80, 0xec, 0x5a, 0xe7, 0x9d, 0x31, 0xf1, 0x93 }}

#define BRSIRUNTIMESERVICES_NONVOLATILEVARIABLE_RESET_GUID \
{ 0xc7303991, 0xe0d4, 0x48b1, {0x82, 0x9d, 0x5a, 0xa2, 0xbc, 0x31, 0x0c, 0x4a }}

#define VENDOR_GUID \
{ 0x9f228f94, 0x9b2d, 0x4a21, {0xae, 0xf3, 0x64, 0x77, 0xde, 0xdd, 0x9c, 0xca }}

#define TPL_ARRAY_SIZE 3

typedef struct _RESET_DATA {
  UINTN           Step;
  UINTN           TplIndex;
  UINT32          RepeatTimes;
} RESET_DATA;

EFI_STATUS
InitializeBBTestBRSIRuntimeServices (
  IN EFI_HANDLE           ImageHandle,
  IN EFI_SYSTEM_TABLE     *SystemTable
  );

EFI_STATUS
BBTestBRSIRuntimeServices (
  IN EFI_HANDLE       ImageHandle
  );

//
// Entry GUIDs
//

#define BRSIRUNTIMESERVICES_TEST_CASE_GUID \
{ 0xe5a45402, 0xeda8, 0x4bfd, {0x86, 0x17, 0x4a, 0xe5, 0xa6, 0x97, 0xb7, 0x2c }}

#define BRSIRUNTIMESERVICES_TEST_CASE_RESETSHUTDOWN_GUID \
{ 0x94011d32, 0x68b9, 0x4556, {0xa5, 0x74, 0x5d, 0x34, 0xd7, 0x9b, 0x12, 0x65 }}

#define BRSIRUNTIMESERVICES_TEST_CASE_NONVOLATILEVARIABLE_GUID \
{ 0xea2fdafd, 0xbcc3, 0x4f37, {0x9c, 0xf4, 0x81, 0x7f, 0x86, 0x40, 0x15, 0x28 }}

#endif /* _BRSIRUNTIMESERVICES_TEST_MAIN_H_ */
