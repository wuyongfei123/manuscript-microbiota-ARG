bam=tos:/xxxx 
ref=tos://yyyy 
out=tos://zzz

binbash-cli.py run -s svtyper.sh -t 32 -m 128 -dist_data 40 \
    -a ' tos://geneway-data-beijing2/pipeline/data/wgs/AiJi_BaiKe_20260324/final_data/S31.Lba.assembly.fa/allSample.SURVIVOR.sort.vcf $bam '
input_path=$1
bam_path=$2
ref_path=$3 
out=$4 


docker load < /ossfs/docker_images/svtyper.tar.gz
#svtyper 并行不好，切分成小个文件
cat allSample.SURVIVOR.sort.vcf  |head -10000 | grep '#' > header 
cat allSample.SURVIVOR.sort.vcf | grep -v '^#' | split -l 10000 -d -a 10 
rm -rf $sam.merge.list  /data/job.sh 
ls x000000* |grep -v vcf | while read id
do
        echo "$sam.$id.svtyper.vcf" >> /data/$sam.merge.list 
    cat header $id > $id.vcf
    echo " svtyper -B $bam_path -T $ref_path -i $id.vcf > $sam.$id.svtyper.vcf " >> /data/job.sh 
done 
docker run -d -v /ossfs:/ossfs -v /usr/bin/parallel:/usr/bin/parallel \
     -v /data:/data -w /data localhost/svtyper:latest /bin/bash -c "
       parallel -j $(nproc) < /data/job.sh  "
bcftools concat -a -f /data/$sam.merge.list -O z -o /data/$sam.svtyper.vcf.gz
