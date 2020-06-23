#!/bin/bash

if source /home/mbykowsx/.bashrc_functionss 1>/dev/null 2>&1; then
	start_logging
fi

: << 'COMMENT'
Relate this to "CCN-512 Register Base Addresses" in "Intel® Axxia™ Lionfish Communication Processor CPU Complex"
arm-ccn 4000000000.ccn: Region 64: id=0, type=0x08 (CCN_TYPE_XP) -> ARM Cluster6, Dev0
arm-ccn 4000000000.ccn: Region 65: id=1, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 66: id=2, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 67: id=3, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 68: id=4, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 69: id=5, type=0x08 (CCN_TYPE_XP) -> ARM Cluster5, Dev1
arm-ccn 4000000000.ccn: Region 70: id=6, type=0x08 (CCN_TYPE_XP) -> ARM Cluster4, Dev0
arm-ccn 4000000000.ccn: Region 71: id=7, type=0x08 (CCN_TYPE_XP) -> CEVA Cluster3, Dev1
arm-ccn 4000000000.ccn: Region 72: id=8, type=0x08 (CCN_TYPE_XP) -> CEVA Cluster2, Dev1
arm-ccn 4000000000.ccn: Region 73: id=9, type=0x08 (CCN_TYPE_XP) -> ARM Cluster2, Dev0
arm-ccn 4000000000.ccn: Region 74: id=10, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 75: id=11, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 76: id=12, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 77: id=13, type=0x08 (CCN_TYPE_XP)
arm-ccn 4000000000.ccn: Region 78: id=14, type=0x08 (CCN_TYPE_XP) -> ARM Cluster1, Dev1
arm-ccn 4000000000.ccn: Region 79: id=15, type=0x08 (CCN_TYPE_XP) -> CEVA Cluster1, Dev0
arm-ccn 4000000000.ccn: Region 80: id=16, type=0x08 (CCN_TYPE_XP) -> CEVA Cluster0, Dev1, ARM Cluster0, Dev0
arm-ccn 4000000000.ccn: Region 81: id=17, type=0x08 (CCN_TYPE_XP) -> ARM Cluster7, Dev1

vc (channel type) = 0
	0b000 Select REQ channel
	0b001 Select RESP channel
	0b010 Select SNP channel
	0b011 Select DATA channel

port (device port) = 1
	0 or 1

dir (direction) = 1 from the perspecive of XP
	0 Select RX channel.
	1 Select TX channel.

cmp_l (watchpoint comparison low bits) = 0

cmp_h (watchpoint comparison high bits) = 0xe << 18
	val/mask[21:18] QoS

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
# set mask, zeros, to QoS field
echo 0xFFFFFFFFFFC3FFFF > /sys/devices/ccn/cmp_mask/0h

cpunu=`cat /sys/devices/ccn/cpumask`
echo "CCN perf runs on CPU${cpunu}"

qos=0xe
qos_field=$((qos<<18))
echo "Collecting flits with qos=${qos}"

arm_cluster0()
{
	# mem_load is an app that does the memory load for an ARM CPU specified
	# by taskset. If you don't have it comment out but if you may have no flits
	# collected.
	taskset -c 0 ./mem_load -N 100000 &
	xp_id=16
	dev_port=0
	perf stat -a -e \
	ccn/xp_watchpoint,xp=${xp_id},vc=0,port=0,dir=0,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=0,dir=0,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=0,dir=0,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=0,dir=1,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=2,port=0,dir=1,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=0,dir=1,cmp_l=0,cmp_h=${qos_field},mask=0/ \
sleep 5
	ps -e -o pid,psr,comm | grep -q "bw_mem\|mem_load"
	killall mem_load
}

ceva_cluster0()
{
	# duration for CEVA is env. specific. If you don't have it substitute "*run.sh"
	# with "sleep 5"
	duration=/workspace/sw/mbykowsx/lionfish/ase_rte/run.sh
	xp_id=16
	dev_port=1
	perf stat -a -e \
	ccn/xp_watchpoint,xp=${xp_id},vc=0,port=${dev_port},dir=0,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=${dev_port},dir=0,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=${dev_port},dir=0,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=1,port=${dev_port},dir=1,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=2,port=${dev_port},dir=1,cmp_l=0,cmp_h=${qos_field},mask=0/,\
ccn/xp_watchpoint,xp=${xp_id},vc=3,port=${dev_port},dir=1,cmp_l=0,cmp_h=${qos_field},mask=0/ \
${duration}
}

arm_cluster0

echo "Collection for flits with qos=${qos} for:"
echo " RN-F identifed with: xp=${xp_id} device port XP=${dev_port}"
echo " Channels (in the sequence present): txreq, txres, txdata, rxres, rxsnp, rxdata"
