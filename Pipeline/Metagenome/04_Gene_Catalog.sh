# prodigal - 单样本预测或合并预测，根据需要调整
xargs -I{} -a sample.txt sh -c "prodigal -a protein.faa -d nucl.fna -o gff -f gff -p meta -i /data/project898/02_Assembly/Contigs/hybird_contigs/{}.fa -s ref.stat"

#合并所有单个样本的protein.faa
xargs -I{} -a sample.txt sh -c 'cat "/data/project898/04_Gene_Catalog/01_before_cdhit/single_sample_data/{}/protein.faa" >> /data/project898/04_Gene_Catalog/01_before_cdhit/allSample_protein.faa; echo "" >>  /data/project898/04_Gene_Catalog/01_before_cdhit/allSample_protein.faa'
#去掉空行
sed '/^$/d' /data/project898/04_Gene_Catalog/01_before_cdhit/allSample_protein.faa > /data/project898/04_Gene_Catalog/01_before_cdhit/nonull_allSample_protein.faa
# extract protein sequence of complete genes from all samples ----> get 'filter.allSample_protein.faa' file
bash /data/project898/Scripts/Sample_gene_info_deal.sh /data/project898/04_Gene_Catalog/01_before_cdhit/nonull_allSample_protein.faa

#合并所有单个样本的nucl.fna
xargs -I{} -a /data/wbq/sample.txt sh -c 'cat "/data/project898/04_Gene_Catalog/01_before_cdhit/single_sample_data/{}/nucl.fna" >> /data/project898/04_Gene_Catalog/01_before_cdhit/allSample_nucl.fna; echo "" >>  /data/project898/04_Gene_Catalog/01_before_cdhit/allSample_nucl.fna'
#去掉空行
sed '/^$/d' /data/project898/04_Gene_Catalog/01_before_cdhit/allSample_nucl.fna > /data/project898/04_Gene_Catalog/01_before_cdhit/nonull_allSample_nucl.fna

# 用没过滤的文件去冗余
cd-hit -i /data/project898/04_Gene_Catalog/01_before_cdhit/nonull_allSample_protein.faa -o total.protein.faa.90 -c 0.90 -s 0.8 -n 5 -M 0 -g 1 -d 0 -T 96 > cd-hit.log 2>&1

cat total.protein.faa.90|grep "^>"|awk -F ' ' '{print $1}'|awk -F '>' '{print $2}' >geneID.list

#extract the nucleotide sequence corresponding to a protein sequence of allsample90 by sequence ID - sample_before_redundancy_nofilter_cds.fna(去冗余后的核酸序列)
perl /data/project898/Scripts/extract_fabyid.pl /data/project898/04_Gene_Catalog/01_before_cdhit/nonull_allSample_nucl.fna /home/wbq/gene/02_cdhit_cluster_nofilter/geneID.list /home/wbq/gene/02_cdhit_cluster_nofilter/sample_before_redundancy_nofilter_cds.fna
#生成sample_before_redundancy_nofilter_cds.fna文件的注释文件
gawk -f /data/project898/Scripts/fa2saf.awk /home/wbq/gene/02_cdhit_cluster_nofilter/sample_before_redundancy_nofilter_cds.fna > /home/wbq/gene/02_cdhit_cluster_nofilter/cds.saf


