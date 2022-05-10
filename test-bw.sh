#!/bin/bash

export CUDA_VISIBLE_DEVICES=3,0,1,2
export NUMA_NODE=0

ofile=bw_out
numactl --cpunodebind=$NUMA_NODE --membind=$NUMA_NODE ./gpu-bw/build/bandwidth > $ofile

awk 'BEGIN {first=1; printf("{\"size\": [");} /^[ ]+[0-9]+/ {if (first) {printf("%s", $1); first=0;} else {printf(", %s", $1)}} END {printf("], ")}' $ofile
awk 'BEGIN {first=1; printf(" \"bw\": [");} /^[ ]+[0-9]+/ {if (first) {printf("%s", $3); first=0;} else {printf(", %s", 34)}} END {printf("]}\n")}' $ofile
