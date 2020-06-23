#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "mem_helper.h"

#define SZ_16M 0x1000000U
#define SZ_32M 0x2000000U
#define SZ_64M 0x4000000U
#define SIZE SZ_64M

/*mem_load -N repetitions <size> rd*/

int

main(int argc, char **argv)
{
	int	c;
	unsigned long repetitions = 1;
	static unsigned array[SIZE/sizeof(unsigned)] __attribute__ ((aligned(0x1000)));
	unsigned *from = &array[0]; /*where the allocation starts*/

	while (( c = getopt(argc, argv, "N:")) != EOF) {
		switch(c) {
		case 'N':
			repetitions = atoi(optarg);
			break;
		default:
			break;
		}
	}

	memset((void*)from, 0xab, SIZE);
	printf("mb: buf %x @ from %p to %p\n", *(volatile unsigned*) from,
		from, (void*) ((char*) from + SIZE));
	printf("mb: after memset buf: %x @ %p\n", *(volatile unsigned*) from, (void*) from);
	printf("mb: repetitions %lu\n",repetitions);
	while(repetitions--) {
		/*printf("mb: reps %lu\n", repetitions);*/	
		mem_load((void*)from, SIZE);
	}
	printf("mb: mem_load done\n");
	

#if 0
#define SZ_10M 0xa00000
	static unsigned array[SZ_10M/sizeof(unsigned)] __attribute__ ((aligned(0x1000)));
	unsigned long address, from = (unsigned long) &array[0]; /*where the allocation starts*/
	unsigned long to = from + SZ_10M;
	memset((void*)from, 0xab, SZ_10M);
	printf("mb: buf @ %p - %p\n", from, to);
	printf("mb: after memset buf: %x @ %p\n", *(volatile unsigned long*) from, (void*) from);
	while(repetitions--) {
		/*printf("mb: %d\n", repetitions);*/
		for(address = from; address < to; address += 64)
				asm volatile(                                
						"dsb sy\n"                           
						"ldr x9, [%[ad]]\n"                  
						"dsb sy\n"                           
						: : [ad] "r" (address));             
	}
	
	printf("mb: lmbecnh done\n");
#endif
	return 0;
}

