

rule picrust2:
    input:
        seq="results/feature_table/rep-seqs-dada2.fasta",
        table="results/feature_table/feature_table-dada2.tsv",
    output:
        directory("results/picrust2")
    log: 'logs/picrust2.log'
    threads: 16
    resources:
        mem_mb=32*1024
    conda: config['conda_envs']['picrust2']
    shell:
        'picrust2_pipeline.py -s {input.seq} -i {input.table} -o {output} -p {threads} > {log} 2>&1'