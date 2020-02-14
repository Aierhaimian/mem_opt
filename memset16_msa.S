/*
 * Copyright (c) 2019, Loongson Ltd. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

/*
 * void memset16_msa(uint16_t* dst, uint16_t value, int count);
 */

#include "SkUtils_regdef_mips.h"

    .text
    .align 4
    .global memset16_msa
    .ent memset16_msa
    .type memset16_msa, @function

memset16_msa:
    .set noreorder

	nop

	.set reorder
	.end memset16_msa
