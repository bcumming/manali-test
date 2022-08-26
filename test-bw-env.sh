#!/bin/bash

export CUDA_VISIBLE_DEVICES=3,0,1,2
export NUMA_NODE=0

export MPICH_GPU_SUPPORT_ENABLED=1
export LD_LIBRARY_PATH=/user-environment/linux-sles15-zen3/gcc-11.3.0/cuda-11.7.0-aa6dfvjnbsdgy42oyskz2shr6ne4fkpg/lib64:$LD_LIBRARY_PATH

ofile=bw_out
echo numactl --cpunodebind=$NUMA_NODE --membind=$NUMA_NODE ./gpu-bw/build/bandwidth > $ofile
numactl --cpunodebind=$NUMA_NODE --membind=$NUMA_NODE ./gpu-bw/build/bandwidth > $ofile

awk 'BEGIN {first=1; printf("{\"size\": [");} /^[ ]+[0-9]+/ {if (first) {printf("%s", $1); first=0;} else {printf(", %s", $1)}} END {printf("], ")}' $ofile
awk 'BEGIN {first=1; printf(" \"bw\": [");} /^[ ]+[0-9]+/ {if (first) {printf("%s", $3); first=0;} else {printf(", %s", $3)}} END {printf("]}\n")}' $ofile
