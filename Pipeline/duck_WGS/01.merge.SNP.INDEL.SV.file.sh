#合并SNP、INDEL、SV到一个vcf文件中
bcftools concat --allow-overlaps --rm-dups none SNP.Indel.filter.merge.vcf.gz sv.norm.vcf.gz -Oz -o SNP.Indel.SV.vcf.gz
#转为plink格式，方便GWAS
plink --allow-extra-chr --vcf SNP.Indel.SV.vcf.gz --make-bed --out SNP.INDEL.SV