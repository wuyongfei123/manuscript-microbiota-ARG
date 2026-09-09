#!/bin/bash

diamond blastx \
    --query "/data3/1162_ARG_data/ARG/ARG_contig_anno_nr_blast/before_cdhit_ARG_contig.fa" \
    --db /data1/public/databases/diamond/nr_250930/nr.dmnd \
    --out "/data3/1162_ARG_data/ARG/ARG_contig_anno_nr_blast2/output/contig_anno.tsv" \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids \
    --evalue 1e-5 \
    --threads 4 \
    --max-target-seqs 5


blast2rma \
  --in /data3/1162_ARG_data/ARG/ARG_contig_anno_nr_blast2/output/contig_anno.tsv \
  --format BlastTab \
  --mapDB /data1/public/databases/megan/megan-map-Feb2022.db \
  --out /data3/1162_ARG_data/ARG/ARG_contig_anno_nr_blast2/tax_output/contig_anno.rma6 \
  --threads 64

rma2info \
  --in /data3/1162_ARG_data/ARG/ARG_contig_anno_nr_blast2/tax_output/contig_anno.rma6 \
  --out /data3/1162_ARG_data/ARG/ARG_contig_anno_nr_blast2/tax_output/contig_anno_read2taxonomy2.txt \
  --read2class Taxonomy \
  --names \
  --paths \
  --ranks \
  --majorRanksOnly