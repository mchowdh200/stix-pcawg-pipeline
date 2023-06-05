#!/bin/env bash
set -eo pipefail

bam=$1
fasta=$2
output=$3

echo "running excord with discordant distance = $disc_dist"
samtools view -b $bam |
    excord --fasta $fasta /dev/stdin |
    bgzip -c > $output
