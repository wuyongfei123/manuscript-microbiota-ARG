



rule dada2_paired:
    input:
        "results/samples_trimmed_data.qza" if config.get('trim-paired',False) else "results/samples_raw_data.qza"
    output:
        seq='results/feature_table/rep-seqs-dada2.qza',
        table='results/feature_table/feature_table-dada2.qza',
        denoising_stats='results/feature_table/feature_table-denoising-stats-dada2.qza',
        base_transition_stats='results/feature_table/feature_table-base-transition-stats-dada2.qza'
    params:
        trim=f" --p-trunc-len-f {config['dada2_params']['trunc_len_f']} --p-trunc-len-r {config['dada2_params']['trunc_len_r']} --p-trim-left-f {config['dada2_params']['trim_left_f']} --p-trim-left-r {config['dada2_params']['trim_left_r']} {config['dada2_params']['extra_params']}"
    log:
        "logs/dada2_paired.log"
    threads: 8
    resources:
        mem_mb=lambda wildcards,input,threads: max(input.size_mb * 2 * threads, 4096)
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime dada2 denoise-paired \
            --i-demultiplexed-seqs {input} \
            {params.trim} \
            --p-n-threads {threads} \
            --o-representative-sequences {output.seq} \
            --o-table {output.table} \
            --o-denoising-stats {output.denoising_stats} \
            --o-base-transition-stats {output.base_transition_stats} > {log} 2>&1
        '''


# dada2 或 debulr 过滤和特征表生成统计结果可视化
rule demux_filter_stats:
    input:
        "results/feature_table/feature_table-denoising-stats-dada2.qza"
    output:
        "results/feature_table/feature_table-denoising-stats-dada2.qzv"
    log:
        "logs/feature_table/feature_table-denoising-stats-dada2.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime metadata tabulate \
            --m-input-file {input} \
            --o-visualization {output} > {log} 2>&1
        '''

# 特征表可视化
rule feature_table_summer:
    input:
        feature_table="results/feature_table/feature_table-dada2.qza",
    output:
        feature_frequencies="results/feature_table/feature_table-dada2_feature_frequencies.qza",
        sample_frequencies="results/feature_table/feature_table-dada2_sample_frequencies.qza",
        summary="results/feature_table/feature_table-dada2_summary.qzv"
    log:
        "logs/feature_table/feature_table_summer.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        "qiime feature-table summarize "
        "--i-table {input.feature_table} "
        f"--m-metadata-file {config['samples_metadata_file']} "
        "--o-feature-frequencies {output.feature_frequencies} "
        "--o-sample-frequencies {output.sample_frequencies} "
        "--o-summary {output.summary} "
        "> {log} 2>&1"

# 代表性序列可视化
rule req_seqs_summer:
    input:
        "results/feature_table/rep-seqs-dada2.qza",
    output:
        "results/feature_table/rep-seqs-dada2.qzv",
    log:
        "logs/feature_table/req-seqs-dada2_summer.log"
    conda:
        config['conda_envs']['qiime2']
    shell:
        "qiime feature-table tabulate-seqs "
        "--i-data {input} "
        "--o-visualization {output} > {log} 2>&1"

# 将 qza 格式的表格转换为相对丰度表格
rule to_relative_frequency:
    input:table='{prefix}.qza',
    output:table='{prefix}_relative_frequency.qza',
    conda:
        config['conda_envs']['qiime2']
    shell:
        'qiime feature-table relative-frequency --i-table {input} --o-relative-frequency-table {output}'

# 根据 ASV 在 百分之几 的样本中存在 过滤 ASV
rule filter_teatures_conditionally:
    input:
        'results/{prefix}.qza'
    output:
        'results/{prefix}_prevalence{prevalence}.qza'
    log:
        'logs/{prefix}_prevalence{prevalence}.log'
    conda:
        config['conda_envs']['qiime2']
    shell:
        'qiime feature-table filter-features-conditionally --i-table {input} '
        '--p-abundance 0.000000000000000000000001 --p-prevalence {wildcards.prevalence} '
        '--o-filtered-table {output} > {log} 2>&1'


# 将 qza 格式的表格转换为 tsv 格式
# rule feature_table2tsv:
#     input:
#         '{prefix}.qza'
#     output:
#         '{prefix}.tsv'
#     conda:
#         config['conda_envs']['qiime2']
#     notebook:
#         'notebooks/feature_table2tsv.py.ipynb'

rule feature_table2tsv:
    input:
        '{prefix}.qza'
    output:
        '{prefix}.tsv'
    wildcard_constraints:
        prefix='results/feature_table/.*'
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime tools export --input-path {input} --output-path {output}.tmp
            biom convert -i {output}.tmp/* -o {output} --to-tsv && sed -i '1d' {output}
            rm -rf {output}.tmp
        '''
# 将 qza 格式的序列转换为 fasta 格式
rule seq_qza2fasta:
    input:
        '{prefix}.qza'
    output:
        '{prefix}.fasta'
    conda:
        config['conda_envs']['qiime2']
    shell:
        '''
            qiime tools export --input-path {input} --output-path {output}.tmp
            mv {output}.tmp/* {output}
            rm -rf {output}.tmp
        '''