/*
 *  Copyright (c) LSI Corporation, 2013
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License 2 as published by the
 *  Free Software Foundation.
 *
 */


#include <linux/random.h>
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/irq.h>
#include <linux/interrupt.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/platform_device.h>
#include <linux/of_irq.h>
#include <linux/dmaengine.h>
#include <linux/crc32.h>
#include <linux/delay.h>
#include <linux/highmem.h>

static int repetitions = 1000;
module_param(repetitions, int, 0660);
MODULE_PARM_DESC(repetitions, "Repettions");

/*#define SIZE (SZ_16M)*/
#define SIZE (SZ_32M)

static void __iomem* buf;
static int alloc_init(void)
{
	unsigned long address = 0;
	phys_addr_t start_addr = 0xc0000000;
	/* now map a single page for compiler not optimzing away */
	unsigned long address2 = __get_free_pages(GFP_KERNEL | __GFP_ZERO, 0);
	pr_info("mb: address2 %lx\n", address2);

	buf = (void*) ioremap_cache(start_addr, SIZE);
	if (!buf)
		return -ENOMEM;

	for(address = (unsigned long) buf;
			address < (unsigned long) buf + SIZE; address += 8) {
		*(volatile unsigned long*) address = address2; /*should be 4 bytes*/
	}

	pr_info("mb: %lx @ %p\n", *(volatile unsigned long*) buf, (void*) buf);

	while(repetitions--) {
		if (0 == repetitions % 100)
			pr_info("mb: reps %d\n", repetitions);
		for(address = (unsigned long) buf; address < (unsigned long) buf + SIZE; address += 64)
				asm volatile(
						"ldr x9, [%[ad]]\n"
						"ldr w10,[x9]\n"
						: : [ad] "r" (address));
	}
	pr_info("mb: mem_load done\n");
	return 0;
}

static void alloc_exit(void)
{
	iounmap((void __iomem*)buf);
}

module_init(alloc_init);
module_exit(alloc_exit);

MODULE_AUTHOR("mb:");
MODULE_DESCRIPTION("test CCN perf");
MODULE_LICENSE("GPL v2");
