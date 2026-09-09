#mapping
bwa mem -K 10000000 -M -Y -t $thread \
    -R "'@RG\tLB:$sam\tID:$sam\tSM:$sam\tPL:$pl" \
    $ref_path ${sam}_1.fq.gz  ${sam}_2.fq.gz  | \
    samtools sort -@ 8 --write-index -O CRAM --reference $ref_path -o ${sam}.sort.bam

#mkdup和 bam转cram（节约保存空间）
sambamba markdup -t $thread2  --sort-buffer-size=${mem}  \
    --tmpdir=/data ${sam}.sort.bam ${sam}.sort.mkdup.bam
samtools view -@ $thread -h -O CRAM --write-index --no-PG -o ${sam}.sort.mkdup.cram \
        --reference $ref_path ${sam}.sort.mkdup.bam
