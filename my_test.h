#ifndef __MY_TEST_H__
#define __MY_TEST_H__

#include <stdint.h>
#include <sys/types.h>

// From memset.c bionic/libc/bionic
// Use C code.
void* libc_memset(void* dst, int c, size_t n);

// From sk_memset_portable external/skia/src/core/SkUtils.cpp
// Use C code.
void sk_memset16_portable(uint16_t dst[], uint16_t value, int count);
void sk_memset32_portable(uint32_t dst[], uint32_t value, int count);

// Use MIPS Assembly code.
void sk_memset16(uint16_t dst[], uint16_t value, int count);
void sk_memset32(uint32_t dst[], uint32_t value, int count);

//From memory.c system/core/libcutils
// Use C code.
void android_memset16(uint16_t* dst, uint16_t value, size_t size);
void android_memset32(uint32_t* dst, uint32_t value, size_t size);

// From android_memset.c systom/core/libcutils/arch-mips
// Use MIPS Assembly code.
// memset.S
void bionic_android_memset16(uint16_t* dst, uint16_t value, size_t size);
void bionic_android_memset32(uint32_t* dst, uint32_t value, size_t size);
void bionic_android_memset(void* dst, int value, size_t size);

void bionic_android_memset16_64(uint16_t* dst, uint16_t value, size_t size);
void bionic_android_memset32_64(uint32_t* dst, uint32_t value, size_t size);
void bionic_android_memset_64(void* dst, int value, size_t size);

//From bcopy.c bionic/libc/upstream-openbsd/lib/libc/string
#define MEMCOPY 1
void *memcpy(void *dst0, const void *src0, size_t length);
//void *memmove(void *dst0, const void *src0, size_t length)
//void bcopy(const void *src0, void *dst0, size_t length)

#endif

