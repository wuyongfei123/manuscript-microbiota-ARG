# 导入序列数据，并可视化质量


rule import_fastq:
    input:
        samples_metadata_file=config['samples_metadata_file']
    output:
        "results/samples_raw_data.qza"
    log:
        "logs/import_fastq.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime tools import \
            --type 'SampleData[PairedEndSequencesWithQuality]' \
            --input-path {input.samples_metadata_file} \
            --output-path {output} \
            --input-format PairedEndFastqManifestPhred33V2 \
            > {log} 2>&1
        '''

rule trim_fastq:
    input:
        "results/samples_raw_data.qza"
    output:
        seq="results/samples_trimmed_data.qza",
        stats="results/samples_trimmed_data_stats.qza"
    log:
        "logs/trim_fastq.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        "qiime cutadapt trim-paired "
        "--i-demultiplexed-sequences {input} "
        f"--p-front-f {config['trim_params']['p-front-f']} "
        f"--p-front-r {config['trim_params']['p-front-r']} "
        "--p-discard-untrimmed "
        "--o-trimmed-sequences {output.seq} "
        "--o-stats {output.stats} > {log} 2>&1"


rule fastq_summarize:
    input:
        "{fastq_qza}.qza"
    output:
        "{fastq_qza}_fastq_summariz.qzv"
    log:
        "logs/{fastq_qza}_fastq_summariz.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime demux summarize \
            --i-data {input} \
            --o-visualization {output}
        '''