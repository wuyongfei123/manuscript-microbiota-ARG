#CARD
# 删除90蛋白序列文件后的*号
sed 's/\*//g' /data/project898/04_Gene_Catalog/02_cdhit_cluster/total.protein.faa.90 > /data/project898/04_Gene_Catalog/02_cdhit_cluster/total.protein-de_asterisk.faa.90
rgi main -i /data/project898/04_Gene_Catalog/02_cdhit_cluster/total.protein-de_asterisk.faa.90 -o /home/wbq/project/function/total.protein.faa.90.card -n 50 --debug -t protein -a DIAMOND --clean > /home/wbq/project/function/CARD.log 2>&1

#VFDB
# blast建库 -- setA:核心库；setB:全库
# setA仅包含经实验验证过的毒力基因，而setB在setA的基础上增加了预测的毒力基因
makeblastdb -in ${Database}/VFDB/VFDB_setB_pro.fas -dbtype prot -parse_seqids -out ${Database}/VFDB/index
blastp -query /data2/wbq/salmon/keep_genes.fa -db /home/public/database/VFDB/index -out /data2/wbq/function/VFDB/total.protein.faa.90.vfdb.tab -evalue 1e-5 -outfmt 6 -num_threads 70 -num_alignments 5 > /data2/wbq/function/VFDB/VFDB.log 2>&1

#CAZy
# make dbCAN database index -- just use for the first time
${hmmpress} ${Database}/dbCAN/dbCAN-HMMdb-V12.txt
hmmscan -o /data2/wbq/function/CAZy/total.protein.faa.90.dbcan --tblout /data2/wbq/function/CAZy/total.protein.faa.90.dbcan.tab -E 1e-5 --cpu 50 /data/public/database/dbCAN/dbCAN-HMMdb-V12.txt /data2/wbq/salmon/keep_genes.fa

#eggNOG
emapper.py -i /data2/wbq/salmon/keep_genes.fa --temp_dir /data2/wbq/function/temp --dmnd_db /data/public/database/EggNOG/eggnog_proteins.dmnd --data_dir /data/public/database/EggNOG -o /data2/wbq/function/eggNOG/result.eggout --cpu 50 --matrix BLOSUM62 --seed_ortholog_evalue 1e-5 --dbtype seqdb -m diamond

#KEGG
diamond blastp --query /data2/wbq/salmon/keep_genes.fa --db /data/public/database/KEGG/kegg.dmnd --out /data/project898/09_Function/KEGG/ko_blastp.out --threads 128 --evalue 1e-5 --outfmt 6
kobas-annotate -i /data/project898/09_Function/KEGG/ko_blastp.out -n 72 -t blastout:tab -s ko -k /home/public/database/KEGG/kobas/ -o /data/project898/09_Function/KEGG/blastouttab.ann > /data/project898/09_Function/KEGG/blastouttab.log 2>&1