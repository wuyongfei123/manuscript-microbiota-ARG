#!/bin/bash

#Author: yeyun
#Version: 1.0
#Create time: 2026-08-16 星期天 16:00:21
#Description: 使用 qiime2 进行 SILVA 数据库的处理和分类器训练，参考https://forum.qiime2.org/t/processing-filtering-and-evaluating-the-silva-database-and-other-reference-sequence-data-with-rescript/15494
set -euo pipefail

f_primer="515f"
r_primer="806r"
f_primer_seq="GTGYCAGCMGCCGCGGTAA"
r_primer_seq="GGACTACNVGGGTWTCTAAT"
threads=24

# 下载 SILVA 数据库的序列和分类信息
qiime rescript get-silva-data --o-silva-sequences silva-138.2-ssu-nr99-rna-seq.qza --o-silva-taxonomy silva-138.2-ssu-nr99-tax.qza
# 将 RNA 序列转为 DNA 序列
qiime rescript reverse-transcribe --i-sequences silva-138.2-ssu-nr99-rna-seq.qza --o-dna-sequences silva-138.2-ssu-nr99-seqs.qza
# 过滤掉低质量序列
qiime rescript cull-seqs --i-sequences silva-138.2-ssu-nr99-seqs.qza --o-clean-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza
# 按分类信息过滤序列长度
qiime rescript filter-seqs-length-by-taxon \
    --i-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza \
    --i-taxonomy silva-138.2-ssu-nr99-tax.qza \
    --p-labels Archaea Bacteria Eukaryota \
    --p-min-lens 900 1200 1400 \
    --o-filtered-seqs silva-138.2-ssu-nr99-seqs-filt.qza \
    --o-discarded-seqs silva-138.2-ssu-nr99-seqs-discard.qza

# 序列去冗余与分类学
qiime rescript dereplicate \
    --i-sequences silva-138.2-ssu-nr99-seqs-filt.qza  \
    --i-taxa silva-138.2-ssu-nr99-tax.qza \
    --p-mode 'uniq' \
    --p-threads ${threads} \
    --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
    --o-dereplicated-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza

# 提取指定引物区域的序列
qiime feature-classifier extract-reads \
    --i-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
    --p-f-primer ${f_primer_seq} \
    --p-r-primer ${r_primer_seq} \
    --p-n-jobs 1 \
    --p-read-orientation 'forward' \
    --o-reads silva-138.2-ssu-nr99-seqs-${f_primer}-${r_primer}.qza
# 对提取的序列进行去冗余
qiime rescript dereplicate \
    --i-sequences silva-138.2-ssu-nr99-seqs-${f_primer}-${r_primer}.qza \
    --i-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-${f_primer}-${r_primer}-uniq.qza \
    --o-dereplicated-taxa  silva-138.2-ssu-nr99-tax-${f_primer}-${r_primer}-derep-uniq.qza

# 训练分类器
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138.2-ssu-nr99-seqs-${f_primer}-${r_primer}-uniq.qza \
    --i-reference-taxonomy silva-138.2-ssu-nr99-tax-${f_primer}-${r_primer}-derep-uniq.qza \
    --o-classifier silva-138.2-ssu-nr99-${f_primer}-${r_primer}-classifier.qza
