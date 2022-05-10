#!/bin/bash
export LOCAL_RANK=$SLURM_LOCALID
export GLOBAL_RANK=$SLURM_PROCID

# affinity for devices indexed by numa node
export NICS=(mlx5_0:1 mlx5_1:1 mlx5_2:1 mlx5_3:1)
export GPUS=(3 2 1 0)

# bind devices to mpi rank
export NUMA_NODE=$LOCAL_RANK
export UCX_NET_DEVICES=${NICS[$NUMA_NODE]}
export CUDA_VISIBLE_DEVICES=${GPUS[$NUMA_NODE]}

#
# global variables that have an impact
#

# con:
#   - increases latency by ~1ms for all message sizes
# pro:
#   - increases bandwidth up to around 12-25 % -- effect less pronounced for large messages
#   - largest improvement is for internode communication
export UCX_MEMTYPE_CACHE=n

#
# To be tested
#

#export UCX_RNDV_SCHEME=put_zcopy
#export UCX_RNDV_THRESH=2048

#
# environment variables that have no measureable impact
#

export UCX_TLS=all

# This appears to be set by default for the configuration on OpenMPI on manali
export OMPI_MCA_pml=ucx

# These were not enabled by default, so turning them off has no effect
export OMPI_MCA_btl="^vader,tcp,openib,smcuda"

# No impact because `smcuda` is not enabled.
# UCX is used to manage memory movement and not the BTL smcuda implementation
export OMPI_MCA_btl_smcuda_use_cuda_ipc=1

echo "rank $GLOBAL_RANK:$LOCAL_RANK on $(hostname) gpu $CUDA_VISIBLE_DEVICES numa-node $NUMA_NODE nic $UCX_NET_DEVICES"

for exe in osu_bw osu_bibw osu_latency
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
