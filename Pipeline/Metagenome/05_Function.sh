#CARD
# 删除90蛋白序列文件后的*号
sed 's/\*//g' /data/project898/04_Gene_Catalog/02_cdhit_cluster/total.protein.faa.90 > /data/project898/04_Gene_Catalog/02_cdhit_cluster/total.protein-de_asterisk.faa.90
rgi main -i /data/project898/04_Gene_Catalog/02_cdhit_cluster/total.protein-de_asterisk.faa.90 -o /home/project/function/total.protein.faa.90.card -n 50 --debug -t protein -a DIAMOND --clean > /home/project/function/CARD.log 2>&1

#KEGG
diamond blastp --query /data2/salmon/keep_genes.fa --db /data/public/database/KEGG/kegg.dmnd --out /data/project898/09_Function/KEGG/ko_blastp.out --threads 128 --evalue 1e-5 --outfmt 6
kobas-annotate -i /data/project898/09_Function/KEGG/ko_blastp.out -n 72 -t blastout:tab -s ko -k /home/public/database/KEGG/kobas/ -o /data/project898/09_Function/KEGG/blastouttab.ann > /data/project898/09_Function/KEGG/blastouttab.log 2>&1