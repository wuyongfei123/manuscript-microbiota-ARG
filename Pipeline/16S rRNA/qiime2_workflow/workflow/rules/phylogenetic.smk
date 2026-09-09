


rule phylogenetic_tree:
    input:
        "results/feature_table/rep-seqs-dada2.qza",
    output:
        aligend_rep_seqs='results/phylogeny/aligned-rep-seqs.qza',
        masked_aligned_rep_seqs='results/phylogeny/masked-aligned-rep-seqs.qza',
        unrooted_tree='results/phylogeny/unrooted-tree.qza',
        rooted_tree='results/phylogeny/rooted-tree.qza',
    log:
        'logs/phylogenetic_tree.log'
    threads:32
    resources:
        mem_mb=64*1024
    conda:
        config['conda_envs']['qiime2']
    shell:
        "qiime phylogeny align-to-tree-mafft-fasttree "
        "--i-sequences {input} "
        "--p-n-threads {threads} "
        "--o-alignment {output.aligend_rep_seqs} "
        "--o-masked-alignment {output.masked_aligned_rep_seqs} "
        "--o-tree {output.unrooted_tree} "
        "--o-rooted-tree {output.rooted_tree} > {log} 2>&1"