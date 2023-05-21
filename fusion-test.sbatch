#!/bin/env bash
###############################################################################
#SBATCH -p long
#SBATCH --job-name=fusion-test
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --mem=1G
#SBATCH --time=168:00:00
#SBATCH --output=logs/fusion-test.out
#SBATCH --error=logs/fusion-test.err
###############################################################################


mkdir -p logs
snakemake -j 128 -c 64 \
    --latency-wait 5 \
    -s stix-fusion-test.smk \
    --cluster-config config/cluster_config.yaml \
    --cluster "sbatch -p {cluster.partition} \\
                      -J {cluster.job-name} \\
                      -t {cluster.time} \\
                      -N {cluster.nodes} \\
                      -n {cluster.ntasks} \\
                      --mem={cluster.mem} \\
                      -o {cluster.output} \\
                      -e {cluster.error}"
