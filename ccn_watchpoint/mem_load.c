#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "mem_helper.h"

#define SZ_16M 0x1000000U
#define SZ_32M 0x2000000U
#define SZ_64M 0x4000000U
#define SIZE SZ_64M

/* mem_load -N repetitions <size> rd */

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
	printf("%s: buf %x @ from %p to %p\n",
		__FILE__, *(volatile unsigned*)from,
		from, (void*)((char*)from + SIZE));
	printf("%s: after memset buf: %x @ %p\n",
		__FILE__, *(volatile unsigned*)from, (void*)from);
	printf("%s: repetitions %lu\n",__FILE__, repetitions);
	while(repetitions--) {
		/*printf("%s: reps %lu\n", __FILE__, repetitions);*/	
		mem_load((void*)from, SIZE);
	}
	printf("%s: mem_load done\n", __FILE__);
	

#if 0 /* Don't use it. Leaving for reference */
{
#define SZ_10M 0xa00000
	static unsigned array[SZ_10M/sizeof(unsigned)] __attribute__ ((aligned(0x1000)));
	unsigned long address, from = (unsigned long) &array[0]; /*where the allocation starts*/
	unsigned long to = from + SZ_10M;
	memset((void*)from, 0xab, SZ_10M);
	printf("%s: buf @ %p - %p\n", __FILE__, (void*)from, (void*)to);
	printf("%s: after memset buf: %lx @ %p\n",
		__FILE__, *(volatile unsigned long*)from, (void*)from);
	while(repetitions--) {
		/*printf("%s: %d\n", __FILE__, repetitions);*/
		for(address = from; address < to; address += 64)
				asm volatile(                                
						"dsb sy\n"                           
						"ldr x9, [%[ad]]\n"                  
						"dsb sy\n"                           
						: : [ad] "r" (address));             
	}
	
	printf("%s: mem_load done\n", __FILE__);
}
#endif
	return 0;
}

