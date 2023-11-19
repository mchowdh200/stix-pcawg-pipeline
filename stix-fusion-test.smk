"""
Simple stix pipeline to test STIX fusion idea
"""

from types import SimpleNamespace
import pandas as pd

## UTILITY FUNCTIONS ===========================================================
def nested_dict_to_namespace(d: dict) -> SimpleNamespace:
  """Converts a nested dict to a SimpleNamespace"""
  namespace = SimpleNamespace(**d) # top level namespace

  # recursively convert sub-dicts to SimpleNamespaces
  for key, value in d.items():
    if isinstance(value, dict):
      setattr(namespace, key, nested_dict_to_namespace(value))
  return namespace

## SETUP ======================================================================

configfile: 'config/config.yaml'
config = nested_dict_to_namespace(config).fusion_test # pipeline subconfig

# table of protein coding gene regions
genes_bed = pd.read_csv(
  config.genes,
  sep="\t",
  names=["chr", "start", "end", "name", "strand"],
)
# list of gene names to use as wildcard in rules
genes = genes_bed["name"].tolist()


## RULES ======================================================================
rule All:
  input:
    f'{config.outdir}/1kg_gene_hits.txt'

rule STIX1kgGeneQuery:
  """
  Given a particular gene, query the 1kg STIX index
  Let the left and right intervals be the whole gene
  """
  input:
    index = config.onekg_index,
    ped_db = config.onekg_ped_db
  params:
    chrom = lambda w: genes_bed[genes_bed['name'] == w.gene]['chr'].values[0],
    start = lambda w: genes_bed[genes_bed['name'] == w.gene]['start'].values[0],
    end =   lambda w: genes_bed[genes_bed['name'] == w.gene]['end'].values[0],
  output:
    f'{config.outdir}/1kg_queries/{{gene}}.txt'

  shell:
    f"""
    bash scripts/stix_query.sh \\
    -i {{input.index}} \\
    -d {{input.ped_db}} \\
    -l {{params.chrom}}:{{params.start}}-{{params.end}} \\
    -r {{params.chrom}}:{{params.start}}-{{params.end}} \\
    -t DEL \\
    -o {{output}}
    """

rule STIXAggregate1kg:
  """
  For each gene, aggregate the 1kg query results to count the number of hits
  accross the 1kg population, and report the gene and total number of hits
  """
  input:
    query_results = f'{config.outdir}/1kg_queries' # directory of query results
  output:
    f'{config.outdir}/1kg_gene_hits.txt'
  threads:
    workflow.cores
  shell:
    # runs python scripts/aggregate_1kg_query_result.py {input.query_result}
    # in parallel with gargs
    """
    bash scripts/aggregate_1kg_gene_queries.sh {input.query_results} {output} {threads}
    """

# rule PairwiseGeneSTIXQueries:
#   pass

# rule RankPairs
#   pass
