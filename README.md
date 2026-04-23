# Manuscript-microbiota-ARGs

This directory contains scripts related to the manuscript "An overdominant host genetic locus reduces the gut resistome by inhibiting Bacteroidaceae peptidoglycan biosynthesis".

Before running, you must ensure that all required softwares and databases are installed successfully.

## INSTALLATION

Create two directories "bin" and "Database" in user home directory.

### Software installation

The installation method refer to the manual of each software. The name, version and availability of the software are as follows:

| Software             | Source              | Availability                                                                                                           |
| :------------------- | :------------------ | :--------------------------------------------------------------------------------------------------------------------- |
| fastp (v0.23.4)      | Chen et al.         | <https://github.com/OpenGene/fastp>                                                                                    |
| Bowtie 2 (v2.5.3)    | Langmead & Salzberg | <https://github.com/BenLangmead/bowtie2>                                                                               |
| MEGAHIT (v1.2.9)     | Li et al.           | <https://github.com/voutcn/megahit>                                                                                    |
| porechop (v0.2.4)    | Wick et al.         | <https://github.com/rrwick/Porechop>                                                                                   |
| Kraken2 (v2.1.3)     | Wood et al.         | <https://github.com/DerrickWood/kraken2>                                                                               |
| SPAdes (v4.0.0)      | Prjibelski et al.   | <https://github.com/ablab/spades>                                                                                      |
| Prodigal (v2.6.3)    | Hyatt et al.        | <https://github.com/hyattpd/Prodigal>                                                                                  |
| CD-HIT (v4.8.1)      | Fu et al.           | <https://github.com/weizhongli/cdhit>                                                                                  |
| Salmon (v1.10.3)     | Patro et al.        | [https://github.com/COMBINE-lab/salmon](https://github.com/COMBINE-lab/salmon "https://github.com/COMBINE-lab/salmon") |
| Diamond (v2.1.9)     | Buchfink et al.     | <https://github.com/bbuchfink/diamond>                                                                                 |
| KOBAS (v3.0.3)       | Bu et al.           | <https://github.com/xmao/kobas>                                                                                        |
| RGI (v6.0.3)         | Alcock et al.       | <https://github.com/arpcard/rgi>                                                                                       |
| tblastn（v2.15.0+)    | Camacho et al.      | <https://github.com/ncbi/blast_plus_docs>                                                                              |
| plasFlow (v1.1)      | Krawczyk et al.     | <https://github.com/smaegol/PlasFlow>                                                                                  |
| MetaWRAP (v1.3.2)    | Uritskiy et al.     | <https://github.com/bxlab/metaWRAP>                                                                                    |
| dRep (v3.4.2)        | Olm et al.          | <https://github.com/MrOlm/drep>                                                                                        |
| GTDB-Tk (v2.3.2)     | Chaumeil et al.     | <https://github.com/Ecogenomics/GTDBTk>                                                                                |
| Prokka (v1.14.6)     | Seemann             | [https://github.com/tseemann/prokka](https://github.com/tseemann/prokka "https://github.com/tseemann/prokka")          |
| SOAPnuke (v2.1.9)    | Chen et al.         | <https://github.com/BGI-flexlab/SOAPnuke>                                                                              |
| BWA (v0.7.17)        | Li & Durbin         | <https://github.com/lh3/bwa>                                                                                           |
| Samtools (v1.10)     | Danecek et al.      | <https://github.com/samtools/samtools>                                                                                 |
| sambamba (v0.7.1)    | Tarasov et al.      | <https://github.com/biod/sambamba>                                                                                     |
| GATK (v4.2.0.0)      | McKenna et al.      | <https://github.com/broadinstitute/gatk>                                                                               |
| vcftools (v0.1.16)   | Danecek et al.      | [https://github.com/vcftools/vcftools](https://github.com/vcftools/vcftools "https://github.com/vcftools/vcftools")    |
| lumpy (v0.2.14)      | Layer et al.        | <https://github.com/arq5x/lumpy-sv>                                                                                    |
| Delly (v0.8.3)       | Rausch et al.       | <https://github.com/dellytools/delly>                                                                                  |
| BreakDancer (v1.4.5) | Chen et al.         | <https://github.com/genome/breakdancer>                                                                                |
| CNVnator (v0.4.1)    | Abyzovet al.        | <https://github.com/abyzovlab/CNVnator>                                                                                |
| Manta (v1.6.0)       | Chen et al.         | <https://github.com/Illumina/manta>                                                                                    |
| SURVIVOR (v1.0.7)    | Jeffares et al.     | <https://github.com/fritzsedlazeck/SURVIVOR>                                                                           |
| bcftools (v1.13)     | Danecek et al.      | <https://github.com/samtools/bcftools>                                                                                 |
| SVtyper (v0.7.1)     | Chiang et al.       | <https://github.com/hall-lab/svtyper>                                                                                  |
| smoove (v0.2.8)      | Pedersen et al.     | [https://github.com/brentp/smoove](https://github.com/brentp/smoove "https://github.com/brentp/smoove")                |
| ADDO (v0.1.0)        | Cui et al.          | <https://github.com/LeileiCui/ADDO>                                                                                    |
| PLINK (v1.9)         | Purcell et al.      | <https://github.com/insilico/plink>                                                                                    |

Note: Make all needed command of software availability in the "\~/bin" directory or in system environment variables. The version is only the version used in the paper and does not have to be the same.

### Database installation

All databases are stored in the "\~/Database" directory.

The name, description and availability of the database are as follows:

| Database                     | Version/release date | Description                                                                    | Availability                                                                                                                                       |
| :--------------------------- | :------------------- | :----------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| standard Kraken2 database    | version 2024.09.04   | Microbial annotation                                                           | <https://github.com/DerrickWood/kraken2>                                                                                                           |
| CARD                         | v3.2.9               | Antibiotic Resistance genes annotation                                         | <https://github.com/arpcard/rgi#install-dependencies>                                                                                              |
| MobileGeneticElementDatabase | version 2018.09.24   | Contains a fasta format database of a large variety of mobile genetic elements | [https://github.com/KatariinaParnanen/MobileGeneticElementDatabase](https://github.com/KatariinaParnanen/MobileGeneticElementDatabase/tree/master) |
| GTDB                         | v214.1               | Genome taxonomy database                                                       | <https://gtdb.ecogenomic.org/>                                                                                                                     |
| duck                         | GCA\_047663525.1     | duck reference genome                                                          | <https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/047/663/525/GCF_047663525.1_IASCAAS_PekinDuck_T2T/>                                                  |

Note: The version are only the version used in the paper, most of database are constantly updated.

## OVERVIEW OF PIPELINE

The code of metagenomic analysis and Genome-Wide Association Studies were placed in "Pipeline" directory. The scripts of statistical analysis and visualization are placed in other directory.

### Part1: Metagenomic analysis

The scripts stored in this directory (Metagenome) are mainly used for metagenomic analysis, including metagenomic data quality control, metagenomic assembly, gene prediction, taxonomic annotation, functional annotation, abundance calculation, and so on.

### Part2: Variant calling

The scripts stored in this directory (duck\_WGS) are mainly used for host genome variant detection, including resequencing data quality control, sequence alignment, variant detection, and raw variant data filtering, among others.

### Part3: Genome-Wide Association Studies

The scripts stored in this directory (GWAS) are mainly used for whole-genome sequencing analysis, with functions including variant data filtering, estimation of additive and dominant genetic variances, and detection, classification, and visualization of additive and dominant trait loci. They are primarily cited from <https://github.com/LeileiCui/ADDO>, with code adjustments made for this study. Example data are stored in the data directory, and AddDom.r can directly call the programs in the R directory to process the data.

## Statistical analysis and visualization

Statistical analysis and visualization were handled by scripting with R program. These scripts were placed in other directory.


