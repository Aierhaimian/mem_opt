/*
 * Copyright (c) 2019, Loongson Ltd. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

/*
 * void memset32_msa(uint32_t* dst, uint32_t value, int count);
 */

#include <SkUtils_regdef_mips.h>

    .text
    .align 4
    .global memset32_msa
    .ent memset32_msa
    .type memset32_msa, @function

memset32_msa:
    .set noreorder

	nop

	.set reorder
	.end memset32_msa
