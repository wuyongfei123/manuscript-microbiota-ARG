import os
def get_samples_min_depth(input):
    if snakemake.config.get('min_depth'):
        return snakemake.config.get('min_depth')
    else:
        import pandas as pd
        from qiime2 import Artifact
        unrarefied_table = Artifact.load(input.table)
        df = unrarefied_table.view(pd.DataFrame)
        min_depth = int(df.sum(axis=1).min())
        return min_depth
min_depth=get_samples_min_depth(snakemake.input)

cmd=f"qiime diversity core-metrics-phylogenetic "+\
    f"--i-phylogeny {snakemake.input.rooted_tree} "+\
    f"--i-table {snakemake.input.table} "+\
    f"--p-sampling-depth {min_depth} "+\
    f"--m-metadata-file {snakemake.input.samples_metadata_file} "+\
    f"--output-dir {snakemake.output} > {snakemake.log} 2>&1"
print(cmd)
os.system(cmd)