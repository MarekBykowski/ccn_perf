#!/bin/bash

taskset -c 0 ./mem_load -N 100000
#sleep 2
taskset -c 0 perf stat -a -e ccn/hnf_cache_miss,node=3/,ccn/cycles/ sleep 2

