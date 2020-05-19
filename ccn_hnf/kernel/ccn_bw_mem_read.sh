#!/bin/bash

taskset -c 1 perf stat -a -e ccn/hnf_cache_miss,node=2/,ccn/hnf_l3_sf_cache_access,node=2/,\
ccn/hnf_cache_miss,node=5/,ccn/hnf_l3_sf_cache_access,node=5/,\
ccn/hnf_cache_miss,node=6/,ccn/hnf_l3_sf_cache_access,node=6/,\
ccn/cycles/ sleep 60

rmmod mem_load2
insmod ./mem_load2.ko &

taskset -c 1 perf stat -a -e ccn/hnf_cache_miss,node=2/,ccn/hnf_l3_sf_cache_access,node=2/,\
ccn/hnf_cache_miss,node=5/,ccn/hnf_l3_sf_cache_access,node=5/,\
ccn/hnf_cache_miss,node=6/,ccn/hnf_l3_sf_cache_access,node=6/,\
ccn/cycles/ sleep 60

dmesg |tail -n 50
