# rule STIXAggregate1kg:
#   """
#   For each gene, aggregate the 1kg query results to count the number of hits
#   accross the 1kg population, and report the gene and total number of hits
#   """
#   input:
#     query_result = f'{config.outdir}/1kg_queries/{{gene}}.txt'
#   output:
#     f'{config.outdir}/1kg_agg/{{gene}}.txt'
#   shell:
#     f"""
#     python scripts/aggregate_1kg_query_result.py {input.query_result} {output}
#     """
import sys
from os.path import splitext, basename
import pandas as pd


def main():
    input_file = sys.argv[1]

    # First row is a extraneous header row, so skip it
    # The second line contains the column names
    # the columns are:
    # Giggle_File_Id, Indivisual, Sex, Population,
    # Super_Population, Alt_file, Pairend, Split
    df = pd.read_csv(input_file, sep="\t", skiprows=1)

    # we want to count the number of hits in the query result
    # which is the summation of all values in the pariend and
    # split columns combined
    total_hits = (df["Pairend"] + df["Split"]).sum()

    key = splitext(basename(input_file))[0]
    print(f"{key}\t{total_hits}")

if __name__ == "__main__":
    main()

