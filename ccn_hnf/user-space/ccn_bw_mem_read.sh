#!/bin/bash

taskset -c 1 perf stat -a -e ccn/hnf_cache_miss,node=2/,ccn/hnf_l3_sf_cache_access,node=2/,\
ccn/hnf_cache_miss,node=5/,ccn/hnf_l3_sf_cache_access,node=5/,\
ccn/hnf_cache_miss,node=6/,ccn/hnf_l3_sf_cache_access,node=6/,\
ccn/cycles/ sleep 2

taskset -c 0 ./mem_load -N 100000 &

#sleep 2
taskset -c 1 perf stat -a -e ccn/hnf_cache_miss,node=2/,ccn/hnf_l3_sf_cache_access,node=2/,\
ccn/hnf_cache_miss,node=5/,ccn/hnf_l3_sf_cache_access,node=5/,\
ccn/hnf_cache_miss,node=6/,ccn/hnf_l3_sf_cache_access,node=6/,\
ccn/cycles/ sleep 2

#ps -e -o pid,psr,comm | grep "bw_mem\|perf"
