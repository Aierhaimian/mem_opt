#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/time.h>

#include "my_test.h"

#define NUM 100000
#define VAL 6553

int main(void)
{
    struct timeval tv1, tv2;
    long test_time;
    pid_t pid;
    int arr_1[NUM];
    uint16_t arr_2[NUM];
    uint32_t arr_3[NUM];

    for (int i=0; i<NUM; i++)
    {
        arr_1[i] = i;
        arr_2[i] = i;
        arr_3[i] = i;
    }

//    pid = fork();
    
//    if (pid < 0) {
//        printf("fork error!\n");
//        exit(1);
//    }else if (pid == 0) {
        gettimeofday(&tv1, NULL);
        //memset(arr_1, VAL, NUM);
        //libc_memset(arr_1, VAL, NUM);
        //sk_memset16_portable(arr_2, VAL, NUM);
        //sk_memset32_portable(arr_3, VAL, NUM);
        //android_memset16(arr_2, VAL, NUM);
        //android_memset32(arr_3, VAL, NUM);
        bionic_android_memset16(arr_2, VAL, NUM);
        gettimeofday(&tv2, NULL);

        test_time = (tv2.tv_sec - tv1.tv_sec)*1000000 + (tv2.tv_usec - tv1.tv_usec);

        printf("the time of memset 100000 numbers in memory is: %ld us.\n", test_time);
//    }else {
//        printf("I am a father process.\n");
//    }


    return 0;
}
