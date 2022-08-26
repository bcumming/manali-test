#!/bin/bash
export LOCAL_RANK=$SLURM_LOCALID
export GLOBAL_RANK=$SLURM_PROCID

# affinity for devices indexed by numa node
export GPUS=(3 2 1 0)

# bind devices to mpi rank
export NUMA_NODE=$LOCAL_RANK
export CUDA_VISIBLE_DEVICES=${GPUS[$NUMA_NODE]}

export MPICH_GPU_SUPPORT_ENABLED=1
export LD_LIBRARY_PATH=/user-environment/linux-sles15-zen3/gcc-11.3.0/cuda-11.7.0-aa6dfvjnbsdgy42oyskz2shr6ne4fkpg/lib64:$LD_LIBRARY_PATH

echo "rank $GLOBAL_RANK:$LOCAL_RANK on $(hostname) gpu $CUDA_VISIBLE_DEVICES numa-node $NUMA_NODE nic $UCX_NET_DEVICES"

for exe in osu_bw #osu_bibw osu_latency
do
    ofile=${exe}_DD_out
    numactl --cpunodebind=$NUMA_NODE --membind=$NUMA_NODE $exe --accelerator=cuda D D > $ofile
    if [ $GLOBAL_RANK == 0 ]
    then
        printf "\n=== %s DD\n" "$exe"
        awk 'BEGIN {first=1; printf("{\"size\": [");} /^[0-9]+/ {if (first) {printf("%s", $1); first=0;} else {printf(", %s", $1)}} END {printf("], ")}' $ofile
        awk 'BEGIN {first=1; printf(" \"bw\": [");} /^[0-9]+/ {if (first) {printf("%s", $2); first=0;} else {printf(", %s", $2)}} END {printf("]}\n")}' $ofile
    fi
    ofile=${exe}_HH_out
    numactl --cpunodebind=$NUMA_NODE --membind=$NUMA_NODE $exe > $ofile
    if [ $GLOBAL_RANK == 0 ]
    then
        printf "\n=== %s HH\n" "$exe"
        awk 'BEGIN {first=1; printf("{\"size\": [");} /^[0-9]+/ {if (first) {printf("%s", $1); first=0;} else {printf(", %s", $1)}} END {printf("], ")}' $ofile
        awk 'BEGIN {first=1; printf(" \"bw\": [");} /^[0-9]+/ {if (first) {printf("%s", $2); first=0;} else {printf(", %s", $2)}} END {printf("]}\n")}' $ofile
    fi
done
