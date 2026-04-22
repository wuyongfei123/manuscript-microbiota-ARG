#### 基因集丰度 ####
mkdir -p /data/project898/06_Abundance/Gene
##Gene abundance
cd /data/project898/06_Abundance/Gene
# mkdir -p sam sort_bam flagstat abundance log

######################################################### salmon #########################################################
# 建索引
salmon index -p 96 -t total.nucl.90.fna -i /data2/wbq/salmon/gene_index -k 31
#双端测序数据reads表达量的估计
xargs -I{} -a sample.txt -P 2 bash -c 'salmon quant -i index -l A --meta -1 {}.filter.1.fastq -2 {}.filter.2.fastq -o abundance/{}_transcripts_quant'
