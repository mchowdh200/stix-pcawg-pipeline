from pathlib import Path
import numpy as np
import pandas as pd
from types import SimpleNamespace


## UTILITY FUNCTIONS ===========================================================
def nested_dict_to_namespace(d: dict) -> SimpleNamespace:
  """Converts a nested dict to a SimpleNamespace"""
  namespace = SimpleNamespace(**d) # top level namespace

  # recursively convert sub-dicts to SimpleNamespaces
  for key, value in d.items():
    if isinstance(value, dict):
      setattr(namespace, key, nested_dict_to_namespace(value))
  return namespace

configfile: 'config/config.yaml'
config = nested_dict_to_namespace(config).excord_config

# NOTE: need to export AWS keys in terminal before running snakemake
rule GetReference:
    output:
        fasta = temp(f'{config.outdir}/ref/hs37d5.fa'),
        fai = temp(f'{config.outdir}/ref/hs37d5.fa.fai')
    shell:
        """
        aws s3 cp s3://layerlabcu/ref/genomes/hs37d5/hs37d5.fa {output.fasta}
        aws s3 cp s3://layerlabcu/ref/genomes/hs37d5/hs37d5.fa.fai {output.fai}
        """


rule GetManifest:
  """
  Get config specified manifest, then filter by file id to create a manifest for a single bam.
  """
    output:
        f'{config.outdir}/manifests/{{file_id}}-manifest.tsv'
    run:
        Path(f'{config.outdir}/manifests').mkdir(exist_ok=True)
        m = manifest_table[manifest_table['file_id'] == wildcards.file_id]
        m.to_csv(output[0], index=False, sep='\t')


rule RunExcord:
  """
  - get bam
  - rename it with file_id
  - run excord
  """

  input:
    manifest = rules.GetManifest.output,
    fasta = rules.GetReference.output.fasta,
  output:
    f'{config.outdir}/excord/{{file_id}}.excord.bed.gz'
  run:
    Path(f'{config.outdir}/excord').mkdir(exist_ok=True)

    # get bam/bai
    shell(
      f"""score-client --quiet download \\
          --validate false \\
          --output-dir {config.outdir}/excord} \\
          --manifest {input.manifest}""")

    # find the filename in the manifest table and change the name to the file_id
    bam = f'{config.outdir}/excord/{manifest_table[manifest_table.file_id == wildcards.file_id].file_name.values[0]}'
    bai = f'{bam}.bai'

    # run excord
    shell(f"bash excord_cmd.sh {bam} {input.fasta} {output}")

    # remove the bams when done
    Path(bam).unlink()
    Path(bai).unlink()




