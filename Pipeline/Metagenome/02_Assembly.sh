#single sample Assembly
xargs -I{} -a /data/project898/455duck.txt -P 4 bash -c "megahit -1 01_clean_data/{}_final_1.fastq.gz -2 01_clean_data/{}_final_2.fastq.gz --min-count 2 --k-min 27 --k-max 127 --k-step 20 --num-cpu-threads 40 --min-contig-len 500 -o /data/project898/02_Assembly/{}_megahit"

# 在每个.fa文件里添加该样本前缀
bash /data/project898/Scripts/megahit_rename.sh /data/project898/455duck.txt

mkdir -p /data/project898/02_Assembly/Contigs
mkdir -p /data/project898/02_Assembly/Quast_out
# cp rename_final.contigs.fa到新文件夹
xargs -I{} -a /data/project898/455duck.txt bash -c "cp /data/project898/02_Assembly/{}_megahit/rename_final.contigs.fa /data/project898/02_Assembly/Contigs/{}.fa"

# quast评估megahit质量
xargs -I{} -a /data/project898/SRA.txt -P 4 bash -c "python /home/wbq/miniforge3/envs/quast/bin/quast /data/project898/02_Assembly/Contigs/{}.fa -o /data/project898/02_Assembly/Quast_out/{}_quast_out"

#merge all contigs from single sample assembled - 根据需求选择合并与否
# cat /data/project898/02_Assembly/Contigs/allSample_906.final_contigs.fasta /data/project323/02_Assembly/Contigs/allSample_326.final_contigs.fasta /data/project898/02_Assembly/Contigs/hybird_contigs/allSample_ont_54.final_contigs.fasta > /data/project898/02_Assembly_combind_contig_file/allSample_1286.final_contigs.fasta