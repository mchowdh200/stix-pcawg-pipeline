#!/bin/env bash

indir=$1
output=$2
threads=$3

ls $indir |
  gargs -p $threads 'python scripts/aggregate_1kg_query_result.py {}' > $output
