#!/bin/bash

mkdir -p 04_Taxonomy
mkdir -p 04_Taxonomy/temp

##############Part4 Taxonomic annotation###########################
# make Uniprot TrEMBL database
diamond makedb --in ${Database}/Uniprot/uniprot_trembl.fasta.gz -d ${Database}/Uniprot/uniprot_trembl

#aligning protein sequence of gene catalog to the Uniprot TrEMBL database  
diamond blastp -q total.protein.faa.90 -d ${Database}/Uniprot/uniprot_trembl.dmnd --tmpdir temp -p 128 -e 1e-5 -k 50 --id 30 --sensitive -o total.protein.faa.90.diamond2uniprot_tremblc

###basta is configured before use
#You must download the taxonomy, which automatically downloads the idmapping_selecter.tab.gz file and creates complete_taxa.db
${basta} taxonomy
#download uni database from basta,automatic construction prot_mapping.db
${basta} download uni

#taxonomic classification based on the LCA algorithms
basta sequence -l 25 -i 80 -e 0.00001 -m 3 -b 1 -p 60 ${Taxonomy}/total.protein.faa.90.diamond2uniprot_trembl /data/project898/05_Taxonomy/Basta/03_lca_out/allsample.diamond2uniprot_trembl.dmnd.lca.out prot