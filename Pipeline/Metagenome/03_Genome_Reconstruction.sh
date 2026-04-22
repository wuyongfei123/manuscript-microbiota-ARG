#! /bin/bash

# Kill script if any commands fail
set -e
echo "Job Start at `date`"

mkdir -p 07_Binning 08_dRep 09_Genome_annotation 10_MAG_quant
mkdir -p 07_Binning/MAG_Fasta

# ##############Part3 Binning: Contigs to MAGs###########################
## use several modules of metawrap pipeline
parent_dir=/home/wbq/0427

# metawrap=/home/wbq/miniconda3/envs/metawrap/bin/metawrap

dRep=${parent_dir}/08_dRep
CleanData=${parent_dir}/01_CleanData
Contigs=${parent_dir}/02_Assembly/Contigs
Binning=${parent_dir}/07_Binning
Genome_annotation=${parent_dir}/09_Genome_annotation
MAG_quant=${parent_dir}/10_MAG_quant
SRA=${parent_dir}/SRA.txt
Scripts=${parent_dir}/Scripts

# 从txt文件中读取每行作为数组元素
mapfile -t SampleIDs < ${SRA}

# 遍历数组中的元素
for SampleID in "${SampleIDs[@]}"
do
    # 创建目录
    if [ ! -d ${Binning}/${SampleID} ]; then
        mkdir ${Binning}/${SampleID}
    fi

    cd ${Binning}/${SampleID}

    if [ ! -d INITIAL_BINNING ]; then
        mkdir INITIAL_BINNING
    fi
    if [ ! -d BIN_REFINEMENT ]; then
        mkdir BIN_REFINEMENT
    fi
    if [ ! -d BIN_REASSEMBLY ]; then
        mkdir BIN_REASSEMBLY
    fi

    # 进入环境
    source /home/wbq/miniconda3/bin/activate metawrap

    #binning with two different algorithms with the Binning module
    metawrap binning -o INITIAL_BINNING -t 96 -a ${Contigs}/${SampleID}.fa --metabat2 --maxbin2 --universal ${CleanData}/${SampleID}_filter_host_1.fastq ${CleanData}/${SampleID}_filter_host_2.fastq

    #Consolidate bin sets with the Bin_refinement module
    metawrap bin_refinement -o BIN_REFINEMENT -t 96 -A INITIAL_BINNING/metabat2_bins/ -B INITIAL_BINNING/maxbin2_bins/ -c 50 -x 10 --quick 

    #Re-assemble the consolidated bin set with the Reassemble_bins module
    metawrap reassemble_bins -o BIN_REASSEMBLY \
        -1 ${CleanData}/${SampleID}_filter_host_1.fastq \
        -2 ${CleanData}/${SampleID}_filter_host_2.fastq \
        -t 60 \
        -m 200 \
        -c 50 \
        -x 10 \
        -b BIN_REFINEMENT/metawrap_50_10_bins

    # 将reassemble后的bin文件重命名并移动到MAG_Fasta文件夹(在rename_bin.py脚本里创建了)
    python ${Scripts}/rename_bin.py ${SRA} ${Binning}/MAG_Fasta
    
    conda deactivate

    #return to initial directory
    cd ../..
done

#############Part4 MAG de-replication###########################
dRep=/home/public/miniforge3/envs/drep/bin/dRep

Binning=${parent_dir}/07_Binning
MAGs=${Binning}/MAG_Fasta

mkdir -p 08_dRep/dRep99 08_dRep/dRep95
dRep99=${parent_dir}/08_dRep/dRep99
dRep95=${parent_dir}/08_dRep/dRep95

source /home/public/miniforge3/bin/activate drep
#MAG de-replicate
${dRep} dereplicate ${dRep99} -g ${MAGs}/*.fa -p 96 -d -comp 50 -con 10 -nc 0.25 -pa 0.9 -sa 0.99

${dRep} compare ${dRep95} -g ${MAGs}/*.fa -p 16 -nc 0.25 -pa 0.9 -sa 0.95 
# dRep cluster /home/wbq/test/data/08_dRep/dRep/dRep95 -p 16 -nc 0.25 -pa 0.9 -sa 0.95 -g /home/wbq/test/data/03_Binning/MAG_Fasta/*.fa(有问题,没有cluster这个命令)
# dRep compare /home/wbq/test/data/08_dRep/dRep/dRep95 -p 16 -nc 0.25 -pa 0.9 -sa 0.95 -g /home/wbq/test/data/03_Binning/MAG_Fasta/*.fa

#############Part5 Taxonomic classification and phylogenetic analysis###########################
phylophlan=~/bin/phylophlan.py
gtdbtk=~/bin/gtdbtk
genomes=./04_dRep/dRep/dRep99/dereplicated_genomes
Taxonomy=/home/wbq/test/data/05_Taxonomy

cd ${Taxonomy}
mkdir gtdbtk phylophlan

##Taxonomic classification
$gtdbtk classify_wf --cpus 16 --out_dir gtdbtk --genome_dir ../${genomes} --extension fa
gtdbtk classify_wf --cpus 16 --out_dir gtdbtk --genome_dir /home/wbq/test/data/08_dRep/dRep/dRep99/dereplicated_genomes --extension fa --skip_ani_screen

#Phylogenetic analysis
# 配置文件
bash /home/public/miniforge3/envs/phylophlan/bin/phylophlan_write_default_configs.sh

$phylophlan -i ../${genomes} -d ${phylophlan} --diversity high -f ${cfg} --accurate -o ${OUTPUT} --nproc 8
phylophlan -i /home/wbq/test/data/08_dRep/dRep/dRep99/dereplicated_genomes -d /home/public/database/Phylophlan/phylophlan_databases/phylophlan --diversity high --accurate -o phylophlan1 --nproc 8 -f supermatrix_aa.cfg --verbose --genome_extension .fa

# 用这个标记了数据库文件夹位置的命令，注意databases_folder下只需要有phylophlan.tar和phylophlan.md5两个文件即可正确运行
phylophlan -i /home/wbq/test/data/08_dRep/dRep/dRep99/dereplicated_genomes --databases_folder /home/public/database/Phylophlan/phylophlan_databases -d phylophlan --diversity high --accurate -o phylophlan2 --nproc 8 -f supermatrix_aa.cfg --verbose --genome_extension .fa
              
cd ../

##############Part6 Genome annotation###########################
# genomes=./04_MAG_de-replication/dereplicated_genomes
prokka_Result=/home/wbq/test/data/09_Genome_annotation/genomes_protein
# mkdir 09_Genome_annotation/genomes_protein

cd ${prokka_Result}

for i in $(ls /home/wbq/test/data/08_dRep/dRep/dRep99/dereplicated_genomes/*.fa)
do
file=${i##*/}
ID=${file%.*}
prokka $i --prefix $ID --metagenome --kingdom Bacteria --outdir $ID
done

##############Part7 MAG abundance ###########################
CleanData=${parent_dir}/01_CleanData
allContigs=${parent_dir}/02_Assembly/allSample500.final_contigs.fasta
genomes=${parent_dir}/08_dRep/dRep99/dereplicated_genomes
MAG_quant=${parent_dir}/10_MAG_quant

#进入环境
source /home/wbq/miniconda3/bin/activate metawrap

metawrap quant_bins -b ${genomes} -o ${MAG_quant} -a ${allContigs} ${CleanData}/*.fastq -t 16

conda deactivate

#get time end the job
echo "Job finished at:" `date`