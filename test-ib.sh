#!/bin/bash
#rank=$SLURM_PROCID
#--nodelist=nid020004,nid020005
host=`hostname`
flags="-F"
flags="$flags --all"                 # test all message sizes
#flags="$flags --bidirectional"      # test bidirectional bandwidth
flags="$flags --iters 1000"          # number of iterations
#flags="$flags --output=message_rate" # number of iterations

if [ $host == nid020004 ]
then
    ofile=ib_server_out
    # redirect output to avoid duplicating output from other side.
    numactl --cpunodebind=0 --membind=0 ib_read_bw -d mlx5_3 $flags > $ofile
else
    ofile=ib_client_out
    numactl --cpunodebind=0 --membind=0 ib_read_bw -d mlx5_3 $flags nid020004 > $ofile
    cat $ofile
    echo
fi


if [ $host == nid020004 ]
then
    awk 'BEGIN {first=1; printf("{\"size\": [");} /^[ ]+[0-9]+/ {if (first) {printf("%s", $1); first=0;} else {printf(", %s", $1)}} END {printf("], ")}' $ofile
    awk 'BEGIN {first=1; printf(" \"bw\": [");} /^[ ]+[0-9]+/ {if (first) {printf("%s", $4); first=0;} else {printf(", %s", $4)}} END {printf("]}\n")}' $ofile
fi
