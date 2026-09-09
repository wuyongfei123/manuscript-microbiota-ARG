#!/bin/bash

#Author: yeyun
#Version: 1.0
#Create time: 2025-03-24 星期一 10:43:53
#Description: summer
set -euo pipefail

filelist=(
    readme.md
    results/feature_table/rep-seqs-dada2.fasta
    results/feature_table/*.tsv
    results/feature_table/specified/*.tsv
    results/diversity/alpha_diversity.tsv
    results/diversity/beta/*.tsv
    results/diversity/alpha_rarefaction.qzv
    results/phylogeny/rooted-tree.qza
    results/taxonomy/taxonomy.tsv
    results/taxonomy/taxa-bar-plots.qzv
    results/feature_table/feature_table-dada2_summary.qzv
    results/feature_table/feature_table-denoising-stats-dada2.qzv
    results/samples_raw_data_fastq_summariz.qzv
    results/samples_trimmed_data_fastq_summariz.qzv
    results/diversity/pcoa
    results/picrust2/{EC_metagenome_out,KO_metagenome_out,pathways_out}
 )

# 检查 filelist 中的文件是否存在，将不存在的文件从列表中移除
mapfile -t filelist < <(for file in "${filelist[@]}"; do if [ -f "$file" ]; then echo "$file"; fi; done)
# 如果 filelist 为空，则退出脚本
if [ ${#filelist[@]} -eq 0 ]; then
    echo "No files found in filelist."
    exit 1
fi

output=${1:-summary.zip}

7z a "${output}" "${filelist[@]}"