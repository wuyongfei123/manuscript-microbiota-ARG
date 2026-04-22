#bowtie2建库
bowtie2-build GCF_015476345.1_ZJU1.0_genomic.fna GCF_015476345.1_ZJU1.0_genomic.fa

#bowtie2比对宿主基因组
xargs -I{} -a SRA.txt -P 4 bash -c "bowtie2 -p 40 --un-gz {}.filter --un-conc-gz {}.filter.gz -x GCF_015476345.1_ZJU1.0_genomic.fa -1 00_raw_data/01_fastp/{}_1.fastq.gz -2 00_raw_data/01_fastp/{}_2.fastq.gz"

# Generate Reports
xargs -I{} -a SRA.txt -P 4 bash -c "fastp -A -G -Q -L -i 00_raw_data/02_bowtie2/{}.filter.1.gz -I 00_raw_data/02_bowtie2/{}.filter.2.gz -o 00_raw_data/03_final_fastp/{}_final_1.fastq.gz -O 00_raw_data/03_final_fastp/{}_final_2.fastq.gz -h 00_raw_data/03_final_fastp/{}_final.html -j 00_raw_data/03_final_fastp/{}_final.json"

# 解压缩.gz文件，生成fastq文件用作后面metawrap - 可暂时不运行
# xargs -I{} -a SRA.txt -P 4 bash -c "unpigz -k -d -p 20 00_raw_data/03_final_fastp/{}_final_1.fastq.gz"
# xargs -I{} -a SRA.txt -P 4 bash -c "unpigz -k -d -p 20 00_raw_data/03_final_fastp/{}_final_2.fastq.gz"
# xargs -I{} -a 00_raw_data/6.txt -P 4 bash -c "unpigz -k -d -p 20 00_raw_data/03_final_fastp/{}_1.fastq.gz"
# xargs -I{} -a 00_raw_data/6.txt -P 4 bash -c "unpigz -k -d -p 20 00_raw_data/03_final_fastp/{}_2.fastq.gz"