# set KERNELDIR, INCLUDES, etc.
KERNELDIR = /workspace/sw/mbykowsx/lionfish/linux-yocto_private
INCLUDES = -I. -I$(KERNELDIR)/include
KBUILD_CFLAGS += -g
EXTRA_AFLAGS += -S -save-temps
PWD    := $(shell pwd)

#wanna pass anything to mem_load3 module?
#CFLAGS_mem_load3.o := -DITERATIONS=1000

#set either or both
obj-m += mem_load.o
obj-m += mem_load2.o
obj-m += mem_load3.o

build:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

help:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) help

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
