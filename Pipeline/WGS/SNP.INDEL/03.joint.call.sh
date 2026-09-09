#call GVCF 为了加快速度， 通过-L $region 进行并行
gatk --java-options '-Xms${mem}m -Xmx${mem}m -Djava.io.tmpdir=/data/' HaplotypeCaller  \
     -R $ref_path \
     -L $region  \
     -I $sam.sort.mkdup.realign.cram   \
     -O $sam.$region.g.vcf.gz \
     --emit-ref-confidence GVCF 
                    
#合并所有区间的文件， input.list  为文件列表，一个文件一行（建议绝对路径)
gatk --java-options "-Xms${mem}m -Xmx${mem}m -Djava.io.tmpdir=/tmp/" GatherVcfs  \
     -O $sam.g.vcf.gz -I $sam.$region.g.vcf.gz -I .......

#joint call 
gatk CombineGVCFs -R ${ref_path} --variant ${sam1}.g.vcf.gz --variant \
     ${sam2}.g.vcf.gz --variant ${sam3}.g.vcf.gz -O combined.g.vcf.gz -L ${region} -ip 50 

#allow-old-rms-mapping-quality-annotation-data 兼容了gatk 3 的gvcf
gatk GenotypeGVCFs --allow-old-rms-mapping-quality-annotation-data -R ${ref} -V combined.g.vcf.gz -O final.joint.vcf.gz -L ${region} [-all-sites]