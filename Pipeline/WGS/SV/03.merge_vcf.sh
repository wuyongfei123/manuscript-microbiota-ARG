#合并每个样本的vcf文件
ulimit -n 65535
zcat $(find | grep .svtyper.vcf.gz | head -1) | grep -v '##' | awk -v OFS='\t' '{
 if(/#/){print $1,$2,$3,$4,$5,$6,$7,$8,$9}else{print $1,$2,$3,$4,$5,$6,".",$8,$9 }}' > com
find | grep svtyper.vcf.gz$ | while read id;
do 
    echo "zcat $id |grep -v '##' | awk -v OFS='\t' '{print \$NF}' > $(basename $id).txt "
done > jobs.sh 
parallel -j 10 < jobs.sh 
ulimit -n 65535
paste com *svtyper.vcf.gz.txt > all
zcat $(find |grep .svtyper.vcf.gz$ | head -1) |grep "^##"  > header
cat header all | bgzip > final.sv.vcf.gz 