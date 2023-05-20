"""
Simple stix pipeline to test STIX fusion idea
"""

from types import SimpleNamespace

configfile: 'config/config.yaml'
config = SimpleNamespace(**config)

rule All:
  pass

rule STIXFilter1kg:
  """
  Query the 1kg STIX index using the genes list as the query regions

  Procedure:
    for each gene:
      let left interval be whole gene
      let right interval be whole gene
      make stix query
      filter out gene if > than some threshold of hits (start with >1)
  """
  output:
    f'{config.outdir}/1kg_filtered/1kg_filtered_genes.bed'
  threads:
    workflow.cores
  shell:
    # TODO nail down all the files needed for stix query
    # then modify args here as necessary
    f"""bash scripts/stix_filter.sh \\
    --genes {config.genes} \\
    --giggle_index {config.1kg_giggle} \\
    --stix_index {config.1kg_stix} \\
    --threshold {config.1kg_filter_threshold} \\
    --out {{output}} \\
    --processes {{threads}}
    """

rule PairwiseGeneSTIXQueries:
  """
  Query the STIX index using the genes list as the query regions
  in the tumor index
  Procedure:
    for each pair of genes:
      let left interval be whole gene[0]
      let right interval be whole gene[1]
      make stix query
      report pair of genes along with number of hits from query
  """
  input:
    rules.STIXFilter1kg.output.genes
  output:
    f'{config.outdir}/pairwise_genes_queries/pairwise_genes_queries.txt'
  threads:
    workflow.cores
  shell:
    f"""
    bash scripts/stix_pairwise_query.sh \\
    --genes {{input}} \\
    --giggle_index {config.tumor_giggle} \\
    --stix_index {config.tumor_stix} \\
    --out {{output}} \\
    --processes {{threads}}
    """

rule RankPairs
  """
  Rank the pairs of genes by the number of hits from the STIX query
  """
  input:
    rules.PairwiseGeneSTIXQueries.output
  output:
    f'{config.outdir}/ranked_pairs/ranked_pairs.txt'
  shell:
    f"""
    bash scripts/rank_pairs.sh \\
    --pairs {{input}} \\
    --out {{output}}
    """



