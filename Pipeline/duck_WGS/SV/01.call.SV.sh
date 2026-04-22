#lumpy
#--exclude $bed  -p 线程， 2/3 效果较好
docker run -v /data:/data -v /ossfs:/ossfs -v /database:/database -w /data brentp/smoove \
     smoove call --outdir /data/ --name $sam \
         --fasta $ref_path -p 2 --genotype $bam_path 
zcat ${sam}-smoove.genotyped.vcf.gz > $sam.smoove.vcf  
            
#delly 
docker run -d -v /data:/data -v /ossfs:/ossfs -v /database:/database -w /data slocalhost/delly \
    delly call -g $ref_path  \
         -o ${sam}.delly.bcf $bam_path 
bcftools view -O z -o $sam.delly.vcf ${sam}.delly.bcf

#breakdancer 
docker run -it -v /data:/data -v /ossfs:/ossfs -v /database:/database -w /data localhost/breakdancer:1.4.5 \
    /bin/bash -c "bam2cfg -q 30 -n 10000 -o breakdancer.cfg  $bam_path  && \
                  breakdancer-max breakdancer.cfg > $sam.breakdancer.out && \
                   /usr/bin/breakdancer2vcf.py -i $sam.breakdancer.out -o $sam.breakdancer.vcf "
sed -i sed 's/SVEND=/END=/g' $sam.breakdancer.vcf
                                 
#cnvnator 1000 bp bins
bin=1000
#处理参考基因组
cnvnator_image=localhost/cnvnator:0.4.1 
mkdir -p fa/file 
cat $ref_path | awk '{if(/>/){id=substr($1,2);print $1>"fa/file/"id".fa"}else{print $1>>"fa/file/"id".fa"}}'

chr=$(cat $ref_path.fai | awk '{if($2>1000000)printf(" %s ",$1)}') 
docker run -v /ossfs:/ossfs -v /data:/data -v /database:/database -w /data/ $cnvnator_image /bin/bash -c "
    cnvnator -root ${sam}.$bin.root -chrom $chr -tree $bam_path && \
    cnvnator -root ${sam}.$bin.root -his $bin -d fa/file/ && \
    cnvnator -root ${sam}.$bin.root  -stat $bin && \
    cnvnator -root ${sam}.$bin.root -partition $bin && \
    cnvnator -root ${sam}.$bin.root  -call $bin > $sam.$bin.cnvnator && \
    cnvnator -root ${sam}.$bin.root -eval $bin > $sam.$bin.QC.txt && \
    cnvnator2VCF.pl -prefix ${sam} -reference $ref_path $sam.$bin.cnvnator fa/file/ \
         > $sam.$bin.cnvnator.vcf"  
                  
#manta  images: localhost/manta
docker run -v /ossfs:/ossfs -v /data:/data -v /database:/database -w /data dbin/bash -c "
    configManta.py --bam $bam_path \
          --referenceFasta $ref_path  \
          --runDir /data && \
    /data/runWorkflow.py  && \
    python2 /usr/local/share/manta-1.6.0-2/libexec/convertInversion.py \
          /usr/local/share/manta-1.6.0-2/libexec/samtools \
          $ref_path \
          results/variants/diploidSV.vcf.gz > /data/$sam.manta.vcf "
                 
#SURVIVOR合并
docker load < /ossfs/docker_images/survivor-1.0.7.tar.gz 
echo $sam.smoove.vcf > merge.list
echo $sam.delly.vcf >> merge.list 
echo $sam.breakdancer.vcf >> merge.list 
echo $sam.manta.vcf >> merge.list
echo $sam.$bin.cnvnator.vcf >> merge.list
docker run -v /data/:/data -w /data survivor-1.0.7 SURVIVOR merge merge.list 500 3 1 1 0 30 $sam.SURVIVOR.vcf 

#cnvnator 含有DUP 和 DEL 变异，单独提取出来
#delly 含有DEL，DUP INV BND INS 变异，单独提                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
#smoove（lumpy） 含有 DEL DUP INS INV 
#manta 含有INV,DEL,INS,DUP
#breakdancer CTX,DEL,INV,ITX,INS,

#merge all sample
docker load < /ossfs/docker_images/survivor-1.0.7.tar.gz 
echo $sam1.SURVIVOR.vcf > merge.list
echo $sam2.SURVIVOR.vcf > merge.list
echo $sam3.SURVIVOR.vcf > merge.list

docker run -v `pwd`:/data -w /data survivor-1.0.7 \
  SURVIVOR merge merge.list 500 1 1 1 0 50 allSample.SURVIVOR.vcf 

python3 /ossfs/soft/ngs_sv_process.py allSample.SURVIVOR.vcf | \
    awk -v OFS='\t' '{if(/^##/){print}else{print $1,$2,$3,$4,$5,$6,$7,$8}}'> tmp.allSample.SURVIVOR.vcf

#使用bcftools norm修复
bcftools annotate --remove INFO/SUPP_VEC -Oz -o tmp.allSample.SURVIVOR.vcf.gz tmp.allSample.SURVIVOR.vcf

bcftools norm --check-ref -s \
         --fasta /ossfs/database/bwa/$ref/$ref  -O z \
         -o allSample.SURVIVOR.norm.vcf.gz \
         tmp.allSample.SURVIVOR.vcf.gz 
         
bcftools sort -O v -o allSample.SURVIVOR.sort.vcf allSample.SURVIVOR.norm.vcf.gz                              
#allSample.SURVIVOR.sort.vcf 用于svtyper 分型z