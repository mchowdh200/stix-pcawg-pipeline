#!/bin/env bash
###############################################################################
# Given absolute path to index and ped_db do a stix query.
# NOTE: Stix has a minor bug that it does not accept absolute path.
# The query has to be run in the same directory as the index and ped_db
###############################################################################

function usage {
    echo "Usage: $0 -i index -d ped_db -l left -r right -t svtype -o out" 1>&2
    echo "  -i index: path to index" 1>&2
    echo "  -d ped_db: path to ped_db" 1>&2
    echo "  -l left: left query with format ch:start-end" 1>&2
    echo "  -r right: right query with format ch:start-end" 1>&2
    echo "  -t svtype: for svtype specific query (optional)" 1>&2
    echo "  -o out: path to output file" 1>&2
    exit 1
}


while getopts ":i:d:l:r:t:o:" opt; do
  case $opt in
    i) index="$OPTARG"
    ;;
    d) ped_db="$OPTARG"
    ;;
    g) gene="$OPTARG"
    ;;
    l) left="$OPTARG"
    ;;
    r) right="$OPTARG"
    ;;
    t) svtype="$OPTARG"
    ;;
    o) out="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        usage
    ;;
  esac
done

[ -z "$index" ] && echo "Missing index" && usage
[ -z "$ped_db" ] && echo "Missing ped_db" && usage
[ -z "$left" ] && echo "Missing left" && usage
[ -z "$right" ] && echo "Missing right" && usage
[ -z "$out" ] && echo "Missing out" && usage
[ ! -z "$svtype" ] && svtype="-t ${svtype}"

index_dir=$(dirname "${index}")
cd "${index_dir}"

stix -s 500 ${svtype} \
    -i $(basename "${index}") \
    -d $(basename "${ped_db}") \
    -l "${left}" \
    -r "${right}" > "${out}"



