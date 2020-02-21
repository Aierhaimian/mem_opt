#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/time.h>

#include "my_test.h"

#define NUM_byte 1024
#define NUM (NUM_byte/4)
#define VAL 65535

int main(void)
{
    struct timeval tv1, tv2;
    long test_time;
    int arr_1[NUM];
    uint16_t arr_2[NUM];
    uint32_t arr_3[NUM];

    for (int i=0; i<NUM; i++)
    {
        arr_1[i] = i;
        arr_2[i] = i;
        arr_3[i] = i;
    }

    for (int i=0; i<NUM; i++) {
        printf("%d ", arr_1[i]);
    }
    printf("\n");

    gettimeofday(&tv1, NULL);
    //memset(arr_1, VAL, NUM);
    //libc_memset(arr_1, VAL, NUM);
    //sk_memset16_portable(arr_2, VAL, NUM);
    //sk_memset32_portable(arr_3, VAL, NUM);
    //android_memset16(arr_2, VAL, NUM);
    //android_memset32(arr_3, VAL, NUM);
    //sk_memset16(arr_2, VAL, NUM);
    //bionic_android_memset16(arr_2, VAL, NUM);
    //bionic_android_memset32(arr_3, VAL, NUM);
    //bionic_android_memset(arr_1, VAL, NUM);
    //bionic_android_memset_64(arr_1, VAL, NUM_byte);
    //bionic_android_memset16_64(arr_2, VAL, NUM_byte);
    bionic_android_memset32_64(arr_3, VAL, NUM_byte);
    gettimeofday(&tv2, NULL);

    test_time = (tv2.tv_sec - tv1.tv_sec)*1000000 + (tv2.tv_usec - tv1.tv_usec);

    printf("the time of memset 100000 numbers in memory is: %ld us.\n", test_time);

    for (int i=0; i<NUM; i++) {
        printf("%d ", arr_3[i]);
    }
    printf("\n");


    return 0;
}
