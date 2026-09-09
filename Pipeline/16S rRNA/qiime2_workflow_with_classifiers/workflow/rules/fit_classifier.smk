# Author: yeyun (Converted to Snakemake)
# Description: SILVA database processing and classifier training with QIIME2 & RESCRIPt
# Reference: https://forum.qiime2.org/t/processing-filtering-and-evaluating-the-silva-database-and-other-reference-sequence-data-with-rescript/15494

import os

# configfile: "configs/config.yaml"
# 默认参数（如果未提供 config.yaml 则使用这些值）
F_PRIMER = config['classifier'].get("f_primer", "338f")
R_PRIMER = config['classifier'].get("r_primer", "806r")
F_PRIMER_SEQ = config['classifier'].get("f_primer_seq", "ACTCCTACGGGAGGCAGCAG")
R_PRIMER_SEQ = config['classifier'].get("r_primer_seq", "GGACTACHVGGGTWTCTAAT")

# 动态生成文件名前缀
PRIMER_TAG = f"{F_PRIMER}-{R_PRIMER}"
PREFIX = config.get("classifiers_file", "").replace(f'-{PRIMER_TAG}-classifier.qza', '')

# ==================== 1. 下载 SILVA 数据 ====================
# rule get_silva_data:
#     output:
#         seqs=f"{PREFIX}-rna-seq.qza",
#         tax=f"{PREFIX}-tax.qza"
#     threads: 1
#     conda: config['conda_envs']['qiime2']
#     shell:
#         """
#         qiime rescript get-silva-data \
#             --o-silva-sequences {output.seqs} \
#             --o-silva-taxonomy {output.tax}
#         """

# # ==================== 2. RNA 反转录为 DNA ====================
# rule reverse_transcribe:
#     input:
#         seqs=f"{PREFIX}-rna-seq.qza"
#     output:
#         f"{PREFIX}-seqs.qza"
#     threads: 1
#     conda: config['conda_envs']['qiime2']
#     shell:
#         """
#         qiime rescript reverse-transcribe \
#             --i-rna-sequences {input.seqs} \
#             --o-dna-sequences {output}
#         """


rule get_gtdb_data:
    output:
        seqs=f"{PREFIX}-rna-seq.qza",
        tax=f"{PREFIX}-tax.qza"
    threads: 1
    conda: config['conda_envs']['qiime2']
    shell:
        """
        qiime rescript get-gtdb-data \
            --o-gtdb-sequences {output.seqs} \
            --o-gtdb-taxonomy {output.tax}
        """

# ==================== 3. 过滤低质量序列 ====================
rule cull_seqs:
    input:
        f"{PREFIX}-seqs.qza"
    output:
        f"{PREFIX}-seqs-cleaned.qza"
    threads: 1
    conda: config['conda_envs']['qiime2']
    shell:
        """
        qiime rescript cull-seqs \
            --i-sequences {input} \
            --o-clean-sequences {output}
        """

# ==================== 4. 按分类学过滤序列长度 ====================
rule filter_seqs_length_by_taxon:
    input:
        seqs=f"{PREFIX}-seqs-cleaned.qza",
        tax=f"{PREFIX}-tax.qza"
    output:
        filtered=f"{PREFIX}-seqs-filt.qza",
        discarded=f"{PREFIX}-seqs-discard.qza"
    threads: 1
    conda: config['conda_envs']['qiime2']
    shell:
        """
        qiime rescript filter-seqs-length-by-taxon \
            --i-sequences {input.seqs} \
            --i-taxonomy {input.tax} \
            --p-labels Archaea Bacteria Eukaryota \
            --p-min-lens 900 1200 1400 \
            --o-filtered-seqs {output.filtered} \
            --o-discarded-seqs {output.discarded}
        """

# ==================== 5. 全长序列去冗余 ====================
rule dereplicate_full:
    input:
        seqs=f"{PREFIX}-seqs-filt.qza",
        tax=f"{PREFIX}-tax.qza"
    output:
        seqs=f"{PREFIX}-seqs-derep-uniq.qza",
        tax=f"{PREFIX}-tax-derep-uniq.qza"
    threads: 24
    conda: config['conda_envs']['qiime2']
    shell:
        """
        qiime rescript dereplicate \
            --i-sequences {input.seqs} \
            --i-taxa {input.tax} \
            --p-mode 'uniq' \
            --p-threads {threads} \
            --o-dereplicated-sequences {output.seqs} \
            --o-dereplicated-taxa {output.tax}
        """

# ==================== 6. 提取引物区域 ====================
rule extract_reads:
    input:
        seqs=f"{PREFIX}-seqs-derep-uniq.qza"
    output:
        seq=f"{PREFIX}-seqs-{PRIMER_TAG}.qza",
        stats=f"{PREFIX}-seqs-{PRIMER_TAG}-extraction-stats.qza"
    threads: 1
    conda: config['conda_envs']['qiime2']
    params:
        f_primer=F_PRIMER_SEQ,
        r_primer=R_PRIMER_SEQ
    shell:
        """
        qiime feature-classifier extract-reads \
            --i-sequences {input.seqs} \
            --p-f-primer {params.f_primer} \
            --p-r-primer {params.r_primer} \
            --p-identity 0.8 \
            --p-n-jobs {threads} \
            --p-read-orientation 'forward' \
            --o-reads {output.seq} \
            --o-read-extraction-stats {output.stats}
        """

# ==================== 7. 引物区域序列去冗余 ====================
rule dereplicate_primer:
    input:
        seqs=f"{PREFIX}-seqs-{PRIMER_TAG}.qza",
        tax=f"{PREFIX}-tax-derep-uniq.qza"
    output:
        seqs=f"{PREFIX}-seqs-{PRIMER_TAG}-uniq.qza",
        tax=f"{PREFIX}-tax-{PRIMER_TAG}-derep-uniq.qza"
    threads: 1
    conda: config['conda_envs']['qiime2']
    shell:
        """
        qiime rescript dereplicate \
            --i-sequences {input.seqs} \
            --i-taxa {input.tax} \
            --p-mode 'uniq' \
            --o-dereplicated-sequences {output.seqs} \
            --o-dereplicated-taxa {output.tax}
        """

# ==================== 8. 训练 Naive Bayes 分类器 ====================
rule fit_classifier:
    input:
        reads=f"{PREFIX}-seqs-{PRIMER_TAG}-uniq.qza",
        tax=f"{PREFIX}-tax-{PRIMER_TAG}-derep-uniq.qza"
    output:
        f"{PREFIX}-{PRIMER_TAG}-classifier.qza"
    threads: 4
    resources:
        mem_mb=32*1024
    conda: config['conda_envs']['qiime2']
    shell:
        """
        qiime feature-classifier fit-classifier-naive-bayes \
            --i-reference-reads {input.reads} \
            --i-reference-taxonomy {input.tax} \
            --o-classifier {output}
        """