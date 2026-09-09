#检查SV的vcf文件中FORMAT列的信息、过滤条件
bcftools view -h your_sv.vcf.gz | grep "BP_DEPTH"
###FILTER=<ID=BP_DEPTH,Description="One or more breakpoints have abnormal depth"> 表示该变异在 断点（Breakpoint）位置的测序深度不足

#可去除这部分SV
zcat input.vcf.gz | awk 'BEGIN{OFS="\t"} $0 ~ /^#/ || $7 !~ /BP_DEPTH/' | bgzip -c > output.no_BP_DEPTH.vcf.gz

#去除低质量的SV
vcftools --gzvcf SHCT.SV.no_BP_DEPTH.vcf.gz --minDP 5 --maxDP 100 --min-meanDP 3 --max-missing 0.9 --maf 0.05 --out sv --recode
bcftools view sv.vcf -Oz -o sv.norm.vcf.gz  #统一压缩文件
tabix -p vcf sv.norm.vcf.gz  #创建索引  