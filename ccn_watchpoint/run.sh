#!/bin/bash

: << 'COMMENT'
Relate this to "CCN-512 Register Base Addresses" in "Intel® Axxia™ Lionfish Communication Processor CPU Complex"
arm-ccn 4000000000.ccn: Region 64: id=0, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 65: id=1, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 66: id=2, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 67: id=3, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 68: id=4, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 69: id=5, type=0x08 (CCN_TYPE_XP) -> ARM Cluster 0
arm-ccn 4000000000.ccn: Region 70: id=6, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 71: id=7, type=0x08 (CCN_TYPE_XP) -> CEVA Cluster
arm-ccn 4000000000.ccn: Region 72: id=8, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 73: id=9, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 74: id=10, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 75: id=11, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 76: id=12, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 77: id=13, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 78: id=14, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 79: id=15, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 80: id=16, type=0x08 (CCN_TYPE_XP) -> CEVA Cluster
arm-ccn 4000000000.ccn: Region 81: id=17, type=0x08 (CCN_TYPE_XP)

vc (channel type) = 0
	0b000 Select REQ channel
	0b001 Select RESP channel
	0b010 Select SNP channel
	0b011 Select DATA channel

port (device port) = 1
	0 or 1

dir (direction) = 1
	0 Select RX channel.
	1 Select TX channel.

cmp_l (watchpoint comparison low bits) = 0

cmp_h (watchpoint comparison high bits) = 0xe << 18
	val/mask[21:18] QOS

mask_l (comparator mask) = 0xffffffffffffffff
	bit 0 corresnponds into matching, bit 1 into not matching

mask_h = 0xFFFFFFFFFFC3FFFF
	zero on qos only, meaning match against that field only

#example:
#perf stat -a -e ccn/xp_watchpoint,xp=5,vc=3,port=1,dir=1,cmp_l=0,cmp_h=$((0xe<<18)),mask=0/ sleep 1
COMMENT

#root@axx-w033-a53:~# cat /sys/devices/ccn/cmp_mask/
#0h  0l  1h  1l  2h  2l  3h  3l  4h  4l  5h  5l  6h  6l  7h  7l  8h  8l  9h  9l  ah  al  bh  bl

echo 0xffffffffffffffff > /sys/devices/ccn/cmp_mask/0l
echo 0xFFFFFFFFFFC3FFFF > /sys/devices/ccn/cmp_mask/0h

cpunu=`cat /sys/devices/ccn/cpumask`
echo "CCN perf runs on CPU${cpunu}"

#qos=$((0xe<<18))
qos=$((0x0<<18))
compare=${qos}
echo "compare field ${compare}"

xp_id=7
echo "xp id ${xp_id}"

perf stat -a -e \
ccn/xp_watchpoint,xp=${xp_id},vc=0,port=1,dir=0,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=1,dir=0,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=1,dir=0,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=2,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/ \
sleep 200

: << 'EOF'
taskset -c 0 ./mem_load -N 100000 &

perf stat -a -e ccn/xp_watchpoint,xp=${xp_id},vc=0,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=2,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=1,dir=1,cmp_l=0,cmp_h=${compare},mask=0/ sleep 5

ps -e -o pid,psr,comm | grep "bw_mem\|mem_load"
killall mem_load
EOF
