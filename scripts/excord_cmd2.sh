#!/bin/env bash
set -o pipefail

bam="$1"
fasta="$2"
output="$3"

# Function to check if a filename starts with a hyphen
filename_starts_with_hyphen() {
    [[ "$1" == -* ]]
}

# If the BAM file starts with a hyphen, move it to a temporary file
if filename_starts_with_hyphen "$bam"; then
    tmp_bam="./temp.bam"
    mv "$bam" "$tmp_bam"
    bam="$tmp_bam"
fi

# Rest of your script remains the same
samtools view -f66 "$bam" | head -100000 |
    awk '{print sqrt($9^2)}' \
    > "$bam.insert-sizes.txt"

disc_dist=$(python3 scripts/get_disc_distance.py "$bam.insert-sizes.txt")

echo "running excord with discordant distance = $disc_dist"
samtools view -b "$bam" |
    excord --discordantdistance "$disc_dist" --fasta "$fasta" /dev/stdin |
    bgzip -c > "$output"

# If the BAM file was temporarily renamed, clean up the temporary file
if filename_starts_with_hyphen "$bam"; then
    rm "$bam"
fi
