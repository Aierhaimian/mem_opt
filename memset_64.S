/*
 * Copyright (c) 2013
 *      MIPS Technologies, Inc., California.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MIPS Technologies, Inc., nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE MIPS TECHNOLOGIES, INC. ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE MIPS TECHNOLOGIES, INC. BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "bionic_asm.h"

#if defined(_MIPS_SIM) && ((_MIPS_SIM == _ABI64) || (_MIPS_SIM == _ABIN32))
# ifndef DISABLE_DOUBLE
#  define USE_DOUBLE
# endif
#endif

#ifndef USE_DOUBLE
# ifndef DISABLE_DOUBLE_ALIGN
#  define DOUBLE_ALIGN
# endif
#endif

/* Some asm.h files do not have the L macro definition.  */
#ifndef L
# if _MIPS_SIM == _ABIO32
#  define L(label) $L ## label
# else
#  define L(label) .L ## label
# endif
#endif

/* Some asm.h files do not have the PTR_ADDIU macro definition.  */
#ifndef PTR_ADDIU
# if _MIPS_SIM == _ABIO32
#  define PTR_ADDIU	addiu
# else
#  define PTR_ADDIU	daddiu
# endif
#endif

/* We load/store 64 bits at a time when USE_DOUBLE is true.
   The C_ prefix stands for CHUNK and is used to avoid macro name
   conflicts with system header files.  */

#ifdef USE_DOUBLE
# define C_ST	sd
# if __MIPSEB
#  define C_STHI	sdl	/* high part is left in big-endian	*/
# else
#  define C_STHI	sdr	/* high part is right in little-endian	*/
# endif
#else
# define C_ST	sw
# if __MIPSEB
#  define C_STHI	swl	/* high part is left in big-endian	*/
# else
#  define C_STHI	swr	/* high part is right in little-endian	*/
# endif
#endif

/* Bookkeeping values for 32 vs. 64 bit mode.  */
#ifdef USE_DOUBLE
# define NSIZE 8
# define NSIZEMASK 0x3f
# define NSIZEDMASK 0x7f
#else
# define NSIZE 4
# define NSIZEMASK 0x1f
# define NSIZEDMASK 0x3f
#endif
#define UNIT(unit) ((unit)*NSIZE)
#define UNITM1(unit) (((unit)*NSIZE)-1)

LEAF(_memset_64,0)

    .set nomips16
    .set noreorder
/* If the size is less than 2*NSIZE (8 or 16), go to L(lastb).  Regardless of
   size, copy dst pointer to v0 for the return value.  */
	slti	$t2,$a2,(2 * NSIZE)
	bne	$t2,$zero,L(lastb)
	move	$v0,$a0

/* If memset value is not zero, we copy it to all the bytes in a 32 or 64
   bit word.  */
	beq	$a1,$zero,L(set0)		/* If memset value is zero no smear  */
	PTR_SUBU $a3,$zero,$a0
	nop

	/* smear byte into 32 or 64 bit word */
#if ((__mips == 64) || (__mips == 32)) && (__mips_isa_rev >= 2)
# ifdef USE_DOUBLE
	dins	$a1, $a1, 8, 8        /* Replicate fill byte into half-word.  */
	dins	$a1, $a1, 16, 16      /* Replicate fill byte into word.       */
	dins	$a1, $a1, 32, 32      /* Replicate fill byte into dbl word.   */
# else
	ins	$a1, $a1, 8, 8        /* Replicate fill byte into half-word.  */
	ins	$a1, $a1, 16, 16      /* Replicate fill byte into word.       */
# endif
#else
# ifdef USE_DOUBLE
    and     $a1,0xff
	dsll	$t2,$a1,8
	or	$a1,$t2
	dsll	$t2,$a1,16
	or	$a1,$t2
	dsll	$t2,$a1,32
	or	$a1,$t2
# else
    and     $a1,0xff
	sll	$t2,$a1,8
	or	$a1,$t2
	sll	$t2,$a1,16
	or	$a1,$t2
# endif
#endif

/* If the destination address is not aligned do a partial store to get it
   aligned.  If it is already aligned just jump to L(aligned).  */
L(set0):
    andi	$t2,$a3,(NSIZE-1)		/* word-unaligned address?          */
	beq	$t2,$zero,L(aligned)	/* t2 is the unalignment count      */
	PTR_SUBU $a2,$a2,$t2
	C_STHI	$a1,0($a0)
	PTR_ADDU $a0,$a0,$t2

L(aligned):
/* If USE_DOUBLE is not set we may still want to align the data on a 16
   byte boundry instead of an 8 byte boundry to maximize the opportunity
   of proAptiv chips to do memory bonding (combining two sequential 4
   byte stores into one 8 byte store).  We know there are at least 4 bytes
   left to store or we would have jumped to L(lastb) earlier in the code.  */
#ifdef DOUBLE_ALIGN
	andi	$t2,$a3,4
	beq	$t2,$zero,L(double_aligned)
	PTR_SUBU $a2,$a2,$t2
	sw	$a1,0($a0)
	PTR_ADDU $a0,$a0,$t2
L(double_aligned):
#endif

/* Now the destination is aligned to (word or double word) aligned address
   Set a2 to count how many bytes we have to copy after all the 64/128 byte
   chunks are copied and a3 to the dest pointer after all the 64/128 byte
   chunks have been copied.  We will loop, incrementing a0 until it equals
   a3.  */
	andi	$t8,$a2,NSIZEDMASK /* any whole 64-byte/128-byte chunks? */
	beq	$a2,$t8,L(chkw)	 /* if a2==t8, no 64-byte/128-byte chunks */
	PTR_SUBU $a3,$a2,$t8	 /* subtract from a2 the reminder */
	PTR_ADDU $a3,$a0,$a3	 /* Now a3 is the final dst after loop */

L(loop16w):
	C_ST	$a1,UNIT(0)($a0)
	C_ST	$a1,UNIT(1)($a0)
	C_ST	$a1,UNIT(2)($a0)
	C_ST	$a1,UNIT(3)($a0)
	C_ST	$a1,UNIT(4)($a0)
	C_ST	$a1,UNIT(5)($a0)
	C_ST	$a1,UNIT(6)($a0)
	C_ST	$a1,UNIT(7)($a0)
	C_ST	$a1,UNIT(8)($a0)
	C_ST	$a1,UNIT(9)($a0)
	C_ST	$a1,UNIT(10)($a0)
	C_ST	$a1,UNIT(11)($a0)
	C_ST	$a1,UNIT(12)($a0)
	C_ST	$a1,UNIT(13)($a0)
	C_ST	$a1,UNIT(14)($a0)
	C_ST	$a1,UNIT(15)($a0)
	PTR_ADDIU $a0,$a0,UNIT(16)	/* adding 64/128 to dest */
	bne	$a0,$a3,L(loop16w)
	nop
	move	$a2,$t8

/* Here we have dest word-aligned but less than 64-bytes or 128 bytes to go.
   Check for a 32(64) byte chunk and copy if if there is one.  Otherwise
   jump down to L(chk1w) to handle the tail end of the copy.  */
L(chkw):
	andi	$t8,$a2,NSIZEMASK	/* is there a 32-byte/64-byte chunk.  */
				/* the t8 is the reminder count past 32-bytes */
	beq	$a2,$t8,L(chk1w)/* when a2==t8, no 32-byte chunk */
	nop
	C_ST	$a1,UNIT(0)($a0)
	C_ST	$a1,UNIT(1)($a0)
	C_ST	$a1,UNIT(2)($a0)
	C_ST	$a1,UNIT(3)($a0)
	C_ST	$a1,UNIT(4)($a0)
	C_ST	$a1,UNIT(5)($a0)
	C_ST	$a1,UNIT(6)($a0)
	C_ST	$a1,UNIT(7)($a0)
	PTR_ADDIU $a0,$a0,UNIT(8)

/* Here we have less than 32(64) bytes to set.  Set up for a loop to
   copy one word (or double word) at a time.  Set a2 to count how many
   bytes we have to copy after all the word (or double word) chunks are
   copied and a3 to the dest pointer after all the (d)word chunks have
   been copied.  We will loop, incrementing a0 until a0 equals a3.  */
L(chk1w):
	andi	$a2,$t8,(NSIZE-1)	/* a2 is the reminder past one (d)word chunks */
	beq	$a2,$t8,L(lastb)
	PTR_SUBU $a3,$t8,$a2	/* a3 is count of bytes in one (d)word chunks */
	PTR_ADDU $a3,$a0,$a3	/* a3 is the dst address after loop */
/* copying in words (4-byte or 8 byte chunks) */
L(wordCopy_loop):
	PTR_ADDIU $a0,$a0,UNIT(1)
	bne	$a0,$a3,L(wordCopy_loop)
	C_ST	$a1,UNIT(-1)($a0)
/* Copy the last 8 (or 16) bytes */
L(lastb):
	blez	$a2,L(leave)
	PTR_ADDU $a3,$a0,$a2       /* a3 is the last dst address */
L(lastbloop):
	PTR_ADDIU $a0,$a0,1
	bne	$a0,$a3,L(lastbloop)
	sb	$a1,-1($a0)
L(leave):
	j	$ra
	nop
	.set	at
	.set	reorder
END(_memset_64)
