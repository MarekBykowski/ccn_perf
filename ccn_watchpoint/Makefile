GCC=aarch64-axxia-linux-gcc
AR=aarch64-axxia-linux-gcc-ar

#CFLAGS=-ggdb --sysroot=/tools/AGRreleases/yocto/morty/axxia_gen2_04apr2018/axxia-arm64-xlf/tools/sysroots/aarch64-axxia-linux -std=gnu99 -O2 -pthread -Wall #--save-temps
CFLAGS=-ggdb --sysroot=/tools/AGRreleases/yocto/thud/axxia_gen2_meta_1.10/axxia-x9-rt/tools/sysroots/aarch64-axxia-linux -std=gnu99 -O2 -pthread -Wall
COMPILE=$(GCC) $(CFLAGS)

all: mem_load

mem_load: mem_load.c mem_helper.S
	$(COMPILE) mem_load.c mem_helper.S -o mem_load

clean:
	rm -rf *.o *.s *.i mem_load
