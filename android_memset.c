/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>

#include "my_test.h"

/* Use mips-assembler versions supplied by bionic/libc/arch-mips/string/memset.S: */
void _memset16(uint16_t* dst, uint16_t value, size_t size);
void _memset32(uint32_t* dst, uint32_t value, size_t size);
void _memset(void* dst, int value, size_t size);
void _memset_64(void* dst, int value, size_t size);

void bionic_android_memset16(uint16_t* dst, uint16_t value, size_t size)
{
    _memset16(dst, value, size);
}

void bionic_android_memset32(uint32_t* dst, uint32_t value, size_t size)
{
    _memset32(dst, value, size);
}

void bionic_android_memset(void* dst, int value, size_t size)
{
    _memset(dst, value, size);
}

#define _MIPS_SIM _ABI64
void bionic_android_memset_64(void* dst, int value, size_t size)
{
    _memset_64(dst, value, size);
}
