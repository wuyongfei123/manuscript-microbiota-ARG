#SNP 和 INDEL 硬过滤
#snp
gatk  --java-options  '-Xms1000m -Xmx1000m -Dsamjdk.compression_level=6 ' SelectVariants -R $ref -V final.vcf.gz -O final.snp.vcf.gz --select-type-to-include SNP -OVI false 
bcftools filter -O z -o final.QC_snp.vcf.gz  -e ' QUAL<30 || INFO/QD < 2.0 || INFO/MQ < 40 || INFO/FS > 60.0 || INFO/SOR > 3.0 || INFO/MQRankSum < -12.5 || INFO/ReadPosRankSum < -8.0 ' final.snp.filter.vcf.gz
#indel
gatk  --java-options  '-Xms1000m -Xmx1000m -Dsamjdk.compression_level=6 ' SelectVariants -R $ref -V final.vcf.gz -O final.indel.vcf.gz --select-type-to-include INDEL -OVI false 
bcftools filter -O z -o final.QC_indel.vcf.gz -e ' QUAL<30 || INFO/QD < 2.0 || INFO/FS > 200.0 || INFO/ReadPosRankSum < -20.0' final.indel.vcf.gz
#merge
gatk --java-options "-Xmx50g" MergeVcfs -I final.QC_indel.vcf.gz -I 0final.QC_snp.vcf.gz -O SNP.Indel.filter.merge.vcf.gz
