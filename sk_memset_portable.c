#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>

#include "my_test.h"

#define assign_16_longs(dst, value)             \
    do {                                        \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
        *(dst)++ = value;   *(dst)++ = value;   \
    } while (0)

///////////////////////////////////////////////////////////////////////////////

static void sk_memset16_portable(uint16_t dst[], uint16_t value, int count) {

    if (dst == NULL && count < 0) {
        printf("assert error!\n");
        return;
    }

    if (count == 0) {
        return;
    }

    // not sure if this helps to short-circuit on small values of count
    if (count < 8) {
        do {
            *dst++ = (uint16_t)value;
        } while (--count != 0);
        return;
    }

    // ensure we're on a long boundary
    if ((size_t)dst & 2) {
        *dst++ = (uint16_t)value;
        count -= 1;
    }

    uint32_t value32 = ((uint32_t)value << 16) | value;

    // handle the bulk with our unrolled macro
    {
        int sixteenlongs = count >> 5;
        if (sixteenlongs) {
            uint32_t* dst32 = (uint32_t*)dst;
            do {
                assign_16_longs(dst32, value32);
            } while (--sixteenlongs != 0);
            dst = (uint16_t*)dst32;
            count &= 31;
        }
    }

    // handle (most) of the rest
    {
        int longs = count >> 1;
        if (longs) {
            do {
                *(uint32_t*)dst = value32;
                dst += 2;
            } while (--longs != 0);
        }
    }

    // cleanup a possible trailing short
    if (count & 1) {
        *dst = (uint16_t)value;
    }
}

static void sk_memset32_portable(uint32_t dst[], uint32_t value, int count) {
    SkASSERT(dst != NULL && count >= 0);

    int sixteenlongs = count >> 4;
    if (sixteenlongs) {
        do {
            assign_16_longs(dst, value);
        } while (--sixteenlongs != 0);
        count &= 15;
    }

    if (count) {
        do {
            *dst++ = value;
        } while (--count != 0);
    }
}
