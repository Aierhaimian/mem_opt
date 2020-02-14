/*
 * Copyright (c) 2019, Loongson Ltd. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

/*
 * void mips_memset32(uint32_t* dst, uint32_t value, int count);
 */

#include "SkUtils_regdef_mips.h"

    .text
    .align 4
    .global mips_memset32
    .ent mips_memset32
    .type mips_memset32, @function

mips_memset32:
	.set noreorder

    beqz    a0, func_ret            # assert dst != NULL
    sll     a2, a2, 2               # size = count*4

    bnez    a2, handle_more         # assert size >= 0
    addu    t0, a0, a2              # t0 is the "past the end" address

func_ret:
    j       ra
    nop

handle_more:
    andi    t1, a2, 0x3f            # any 64-byte chunks?
                                    # t1 is the byte count past 64-byte chunks
    beq     a2, t1, chk8w           # when a2 == t1, no 64-byte chunk then
                                    # There will be at most 1 32-byte chunk then
    subu    a3, a2, t1              # subtract from a2 the reminder
                                    # Here a3 counts bytes in 16w chunks
    addu    a3, a0, a3              # Now a3 is the final dst after 64-byte chunks

chk16w:                             # there could be up to 3 "64-byte nopref30" chunks
    addiu   a0, a0, 64
    sw      a1, -64(a0)
    sw      a1, -60(a0)
    sw      a1, -56(a0)
    sw      a1, -52(a0)
    sw      a1, -48(a0)
    sw      a1, -44(a0)
    sw      a1, -40(a0)
    sw      a1, -36(a0)
    sw      a1, -32(a0)
    sw      a1, -28(a0)
    sw      a1, -24(a0)
    sw      a1, -20(a0)
    sw      a1, -16(a0)
    sw      a1, -12(a0)
    sw      a1, -8(a0)
    bne     a0, a3, chk16w
    sw      a1, -4(a0)

chk8w:                              # t1 here is the byte count past 64-byte chunks
    andi    t2, t1, 0x1f            # is there a 32-byte chunk?
                                    # the t2 is the reminder count past 32-bytes
    beq     t1, t2, chk1w           # when t1==t2, no 32-byte chunk
    move    a2, t2

    sw      a1, 0(a0)
    sw      a1, 4(a0)
    sw      a1, 8(a0)
    sw      a1, 12(a0)
    sw      a1, 16(a0)
    sw      a1, 20(a0)
    sw      a1, 24(a0)
    sw      a1, 28(a0)
    addiu   a0, a0, 32

chk1w:
    andi    t2, a2, 0x3             # now t8 is the reminder past 1w chunks
    beq     a2, t2, last4aligned
    subu    a3, a2, t2              # a3 is the count of bytes in 1w chunks
    addu    a3, a0, a3              # now a3 is the dst address past the 1w chunks

wordCopy_loop:
    addiu   a0, a0, 4
    bne     a0, a3, wordCopy_loop
    sw      a1, -4(a0)

last4aligned:
    j       ra
    swl	    a1, -1(t0)

	.set reorder
	.end mips_memset32
