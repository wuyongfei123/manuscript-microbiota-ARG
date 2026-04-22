#qc
fastp -i $read1_path -I $read2_path \
    -o ${sam}_1.fq.gz -O ${sam}_2.fq.gz \
    -j ${sam}.json -h ${sam}.html -w $(nproc)  