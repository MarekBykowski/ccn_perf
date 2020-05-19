#!/bin/bash

# empty kernel logbuffer
# it gets logged to only if ccn perf driver is configured to do so
echo > /sys/kernel/debug/tracing/trace
perf stat -a -e ccn/hnf_cache_miss,node=2/,ccn/hnf_l3_sf_cache_access,node=2/ sleep 1
cat /sys/kernel/debug/tracing/trace

perf stat -a -e \
ccn/hnf_cache_miss,node=2/,ccn/hnf_l3_sf_cache_access,node=2/,\
ccn/hnf_cache_miss,node=5/,ccn/hnf_l3_sf_cache_access,node=5/,\
ccn/hnf_cache_miss,node=6/,ccn/hnf_l3_sf_cache_access,node=6/,\
ccn/hnf_cache_miss,node=9/,ccn/hnf_l3_sf_cache_access,node=9/,\
ccn/hnf_cache_miss,node=20/,ccn/hnf_l3_sf_cache_access,node=20/,\
ccn/hnf_cache_miss,node=23/,ccn/hnf_l3_sf_cache_access,node=23/,\
ccn/hnf_cache_miss,node=24/,ccn/hnf_l3_sf_cache_access,node=24/ sleep 1
