#!/bin/bash
#rank=$SLURM_PROCID
#--nodelist=nid020004,nid020005
echo "===== rank $SLURM_PROCID on $(hostname)"
host=`hostname`
flags="-F"
flags="$flags --all"               # test all message sizes
flags="$flags --bidirectional"     # test bidirectional bandwidth
flags="$flags --iters 1000"            # number of iterations

if [ $host == nid020004 ]
then
    numactl --cpunodebind=0 --membind=0 ib_read_bw -d mlx5_3 $flags
else
    numactl --cpunodebind=0 --membind=0 ib_read_bw -d mlx5_3 $flags nid020004
fi
