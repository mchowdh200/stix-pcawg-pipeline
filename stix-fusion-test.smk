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
    expand(f'{config.outdir}/1kg_queries/{{gene}}.txt', gene=genes)

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




# rule STIXFilter1kg:
#   pass

# rule PairwiseGeneSTIXQueries:
#   pass

# rule RankPairs
#   pass



