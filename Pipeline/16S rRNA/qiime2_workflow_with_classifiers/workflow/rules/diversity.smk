# 计算 alpha 和 beta diversity

# rule diversity:
#     input:
#         rooted_tree='results/phylogeny/rooted-tree.qza',
#         table="results/feature_table/feature_table-dada2.qza",
#         samples_metadata_file=config['samples_metadata_file']
#     output:
#         directory("results/diversity/q2_file")
#     log:
#         'logs/diversity.log'
#     conda:
#         config['conda_envs']['qiime2']
#     script: "scripts/qiime2_diversity.py"

# rule export_diversity:
#     input:
#         'results/diversity/q2_file'
#     output:
#         aplha_diversity_table='results/diversity/aplha_diversity.tsv',
#         bray_curtis_distance_matrix='results/diversity/beta_bray_curtis_distance_matrix.tsv',
#         jaccard_distance_matrix='results/diversity/beta_jaccard_distance_matrix.tsv',
#         unweighted_unifrac_distance_matrix='results/diversity/beta_unweighted_unifrac_distance_matrix.tsv',
#         weighted_unifrac_distance_matrix='results/diversity/beta_weighted_unifrac_distance_matrix.tsv'
#     conda:
#         config['conda_envs']['qiime2']
#     notebook:
#         'notebooks/export_diversity.py.ipynb'

rule alpha_rarefaction:
    input:
        rooted_tree='results/phylogeny/rooted-tree.qza',
        table="results/feature_table/feature_table-dada2.qza",
        samples_metadata_file=config['samples_metadata_file']
    output:
        "results/diversity/alpha_rarefaction.qzv"
    log:
        'logs/alpha_rarefaction.log'
    conda:
        config['conda_envs']['qiime2']
    params:
        min_depth = config['alpha_rarefaction']['min_depth'],
        max_depth = config['alpha_rarefaction']['max_depth'],
        extra_params = config['alpha_rarefaction']['extra_params']
    shell:
        'qiime diversity alpha-rarefaction '
        '--i-table {input.table} '
        '--i-phylogeny {input.rooted_tree} '
        '--p-max-depth {params.max_depth} '
        '--p-min-depth {params.min_depth} '
        '{params.extra_params} '
        '--m-metadata-file {input.samples_metadata_file} '
        '--o-visualization {output} '
        '> {log} 2>&1'


rule alpha:
    input:
        "results/feature_table/feature_table-dada2.qza"
    output:
        qza='results/diversity/alpha/{metric}.qza',
        tsv='results/diversity/alpha/{metric}.tsv'
    wildcard_constraints:
        metric="ace|berger_parker_d|brillouin_d|chao1|chao1_ci|dominance|doubles|enspie|esty_ci|fisher_alpha|gini_index|goods_coverage|heip_e|kempton_taylor_q|lladser_pe|margalef|mcintosh_d|mcintosh_e|menhinick|michaelis_menten_fit|observed_features|osd|pielou_e|robbins|shannon|simpson|simpson_e|singles|strong"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime diversity alpha \
            --i-table {input} \
            --p-metric {wildcards.metric} \
            --o-alpha-diversity {output.qza}
            7z e -so {output.qza} '*/data/*.tsv' > {output.tsv}
        '''

rule alpha_phylogenetic:
    input:
        table="results/feature_table/feature_table-dada2.qza",
        rooted_tree='results/phylogeny/rooted-tree.qza'
    output:
        qza='results/diversity/alpha/faith_pd.qza',
        tsv='results/diversity/alpha/faith_pd.tsv'
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime diversity alpha-phylogenetic \
            --i-table {input.table} \
            --i-phylogeny {input.rooted_tree} \
            --p-metric faith_pd \
            --o-alpha-diversity {output.qza}
            7z e -so {output.qza} '*/data/*.tsv' > {output.tsv}
        '''

rule join_alpha:
    input:
        expand('results/diversity/alpha/{metric}.tsv', metric=config.get('calculate_alpha_diversity',None) if config.get('calculate_alpha_diversity',None) else ['observed_features','shannon','faith_pd','chao1']),
    output:
        'results/diversity/alpha_diversity.tsv'
    conda:
        config['conda_envs']['qiime2']
    run:
        import pandas as pd
        import os
        dfs = []
        for f in input:
            metric = os.path.basename(f).replace('.tsv','')
            df = pd.read_csv(f, sep='\t', index_col=0)
            dfs.append(df)
        df_all = pd.concat(dfs, axis=1)
        df_all.to_csv(output[0], sep='\t')


rule beta:
    input:
        "results/feature_table/feature_table-dada2.qza"
    output:
        qza='results/diversity/beta/{metric}.qza',
        tsv='results/diversity/beta/{metric}.tsv'
    wildcard_constraints:
        metric="aitchison|braycurtis|canberra|canberra_adkins|chebyshev|cityblock|correlation|cosine|dice|euclidean|hamming|jaccard|jensenshannon|matching|minkowski|rogerstanimoto|russellrao|seuclidean|sokalsneath|sqeuclidean|yule"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime diversity beta \
            --i-table {input} \
            --p-metric {wildcards.metric} \
            --o-distance-matrix {output.qza}
            7z e -so {output.qza} '*/data/*.tsv' > {output.tsv}
        '''

rule beta_phylogenetic:
    input:
        table="results/feature_table/feature_table-dada2.qza",
        rooted_tree='results/phylogeny/rooted-tree.qza'
    output:
        qza='results/diversity/beta/{metric}.qza',
        tsv='results/diversity/beta/{metric}.tsv'
    wildcard_constraints:
        metric="generalized_unifrac|unweighted_unifrac|weighted_normalized_unifrac|weighted_unifrac"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime diversity beta-phylogenetic \
            --i-table {input.table} \
            --i-phylogeny {input.rooted_tree} \
            --p-metric {wildcards.metric} \
            --o-distance-matrix {output.qza}
            7z e -so {output.qza} '*/data/*.tsv' > {output.tsv}
        '''


rule pcoa:
    input:
        "results/diversity/beta/{metric}.qza"
    output:
        qza='results/diversity/pcoa/{metric}_pcoa.qza',
    wildcard_constraints:
        metric="aitchison|braycurtis|canberra|canberra_adkins|chebyshev|cityblock|correlation|cosine|dice|euclidean|hamming|jaccard|jensenshannon|matching|minkowski|rogerstanimoto|russellrao|seuclidean|sokalsneath|sqeuclidean|yule|generalized_unifrac|unweighted_unifrac|weighted_normalized_unifrac|weighted_unifrac"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime diversity pcoa \
            --i-distance-matrix {input} \
            --o-pcoa {output.qza}
        '''

rule pcoa_plot:
    input:
        pcoa='results/diversity/pcoa/{metric}_pcoa.qza',
        metadata=config['samples_metadata_file']
    output:
        qzv='results/diversity/pcoa/{metric}_pcoa.qzv'
    wildcard_constraints:
        metric="aitchison|braycurtis|canberra|canberra_adkins|chebyshev|cityblock|correlation|cosine|dice|euclidean|hamming|jaccard|jensenshannon|matching|minkowski|rogerstanimoto|russellrao|seuclidean|sokalsneath|sqeuclidean|yule|generalized_unifrac|unweighted_unifrac|weighted_normalized_unifrac|weighted_unifrac"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime emperor plot \
            --i-pcoa {input.pcoa} \
            --m-metadata-file {input.metadata} \
            --o-visualization {output.qzv}
        '''