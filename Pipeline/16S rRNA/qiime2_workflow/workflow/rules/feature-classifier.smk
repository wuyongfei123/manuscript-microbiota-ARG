# 物种注释

rule tax_classify:
    input:
        classifier=config['classifiers_file'],
        seq="results/feature_table/rep-seqs-dada2.qza",
    output:
        'results/taxonomy/taxonomy.qza'
    log:
        'logs/tax_classify.log'
    threads: 32
    resources:
        mem_mb=lambda wildcards,input,threads: max(1024 * 8 * threads, 4096)
    conda:
        config['conda_envs']['qiime2']
    shell:
        "qiime feature-classifier classify-sklearn  "
        "--p-n-jobs {threads} "
        "--i-classifier {input.classifier} "
        "--i-reads {input.seq} "
        "--o-classification {output} >{log} 2>&1"



# 导出物种注释表格
rule export_taxa:
    input:rules.tax_classify.output
    output:'results/taxonomy/taxonomy.tsv'
    shell:'7z e -so {input} */data/taxonomy.tsv > {output}'

# 物种注释可视化
rule tax_summer:
    input:
        'results/taxonomy/taxonomy.qza'
    output:
        'results/taxonomy/taxonomy.qzv'
    log:
        "logs/tax_summer.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime metadata tabulate \
            --m-input-file {input} \
            --o-visualization {output} > {log} 2>&1
        '''

# 物种注释柱状图
rule taxa_barplot:
    input:
        table="results/feature_table/feature_table-dada2.qza",
        taxa='results/taxonomy/taxonomy.qza',
        samples_metadata_file=config['samples_metadata_file']
    output:
        'results/taxonomy/taxa-bar-plots.qzv'
    log:
        "logs/taxa_barplot.log"
    conda:
        config['conda_envs']['qiime2']
    shell:  
        "qiime taxa barplot "
        "--i-table {input.table} "
        "--i-taxonomy {input.taxa} "
        "--m-metadata-file {input.samples_metadata_file} "
        "--o-visualization {output}  > {log} 2>&1"


rule collapse_taxa:
    input:
        table="results/feature_table/feature_table-dada2.qza",
        taxonomy=rules.tax_classify.output
    output:
        'results/feature_table/specified/feature_table-dada2_{level}.qza'
    wildcard_constraints:
        level='kingdom|phylum|class|order|family|genus|species'
    params:level=lambda wc:{'kingdom':1,'phylum':2,'class':3,'order':4,'family':5,'genus':6,'species':7}[wc['level']]
    conda:
        config['conda_envs']['qiime2']
    shell:
        'qiime taxa collapse --i-table {input.table} --i-taxonomy {input.taxonomy} --p-level {params.level} --o-collapsed-table {output}'