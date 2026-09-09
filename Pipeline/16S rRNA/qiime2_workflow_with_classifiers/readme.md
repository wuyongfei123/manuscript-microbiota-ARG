`*.qza`/`*.qzv`文件在网页 [https://view.qiime2.org](https://view.qiime2.org) 中查看，并且它们实际上就是个`zip`文件，可以修改后缀为`.zip`解压查看。

* 原始fastq文件统计信息
  results/samples_raw_data_fastq_summariz.qzv

* 去除接头和引物序列后的fastq文件统计信息
  results/samples_trimmed_data_fastq_summariz.qzv

* DADA2过滤信息
  results/feature_table/feature_table-denoising-stats-dada2.qzv

* DADA2结果特征表统计信息
  results/feature_table/feature_table-dada2_summary.qzv
  | 列名 | 中文含义 | 解释 |
  | :--- | :--- | :--- |
  | sample-id | 样本编号 | 样品的唯一标识符（如 HB_161）。 |
  | input | 原始序列数 | 测序下机后导入分析流程的原始 Reads 总数。 |
  | filtered | 过滤后序列数 | 经过质量修剪（去低质量碱基、去N碱基、长度筛选等）后保留的序列数。 |
  | percentage of input passed filter | 过滤通过率 | `filtered / input`。反映原始测序质量，一般 >70% 为合格。 |
  | denoised | 去噪后序列数 | 使用 DADA2 或 Deblur 等算法纠错、去除测序错误和单碱基突变后的序列数（ASV/OTU 推断前一步）。 |
  | merged | 合并后序列数 | 双端测序（Paired-end）正反向 Reads 成功重叠拼接的序列数。这是关键质控指标。 |
  | percentage of input merged | 合并率 | `merged / input`。反映片段长度与测序读长的匹配度及整体数据完整性。 |
  | non-chimeric | 非嵌合体序列数 | 去除 PCR 扩增过程中产生的嵌合体（Chimera）后的最终有效序列数。这是用于后续物种注释和多样性分析的最终数据量。 |
  | percentage of input non-chimeric | 非嵌合体占比 | `non-chimeric / input`。综合反映数据的最终有效利用率。 |

* ASV代表序列
  results/feature_table/rep-seqs-dada2.fasta

* 绝对丰度表
  results/feature_table/feature_table-dada2.tsv

* 相对丰度表
  results/feature_table/feature_table-dada2_relative_frequency.tsv

* 各个物种层级的相对丰度表
  results/feature_table/specified/feature_table-dada2_class_relative_frequency.tsv
  results/feature_table/specified/feature_table-dada2_family_relative_frequency.tsv
  results/feature_table/specified/feature_table-dada2_genus_relative_frequency.tsv
  results/feature_table/specified/feature_table-dada2_order_relative_frequency.tsv
  results/feature_table/specified/feature_table-dada2_phylum_relative_frequency.tsv
  results/feature_table/specified/feature_table-dada2_species_relative_frequency.tsv

* alpha多样性
  results/diversity/alpha_diversity.tsv

* alpha多样性稀疏曲线
  results/diversity/alpha_rarefaction.qzv

* beta多样性
  results/diversity/beta/aitchison.tsv
  results/diversity/beta/braycurtis.tsv
  results/diversity/beta/jaccard.tsv
  results/diversity/beta/unweighted_unifrac.tsv
  results/diversity/beta/weighted_unifrac.tsv

* PCOA分析
  results/diversity/pcoa

* rooted系统发育树
  results/phylogeny/rooted-tree.qza

* 物种丰度堆叠柱状图
  results/taxonomy/taxa-bar-plots.qzv

* ASV物种注释
  results/taxonomy/taxonomy.tsv

* picrust2功能注释结果，ITS没有
  results/picrust2
  * **`EC_metagenome_out/`**: EC编号（酶功能）宏基因组预测结果目录。
    * `pred_metagenome_unstrat.tsv.gz`: **EC编号丰度表**（行=EC编号，列=样本）。这是功能分析的核心输入文件。
    * `seqtab_norm.tsv.gz`: 经预测16S拷贝数校正后的ASV/序列丰度表。
    * `weighted_nsti.tsv.gz`: 每个样本的加权NSTI值。用于评估预测准确性，值越低表示ASV与参考基因组匹配度越高，预测越可靠。
  * **`KO_metagenome_out/`**: KEGG Ortholog (KO) 宏基因组预测结果目录。包含与上述EC目录结构相同的三个文件，但针对KO功能分类。
  * **`pathways_out/`**: 代谢通路预测结果目录。
    * `path_abun_unstrat.tsv.gz`: **MetaCyc通路丰度表**。基于预测的EC编号通过MinPath推断得出。
