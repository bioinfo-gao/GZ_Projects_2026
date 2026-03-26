# Method1: use sigularity,  docker, or conda 
# Here we use sigularity to run the pipeline, not docker
nextflow run nf-core/sarek \
   -r 3.8.1 \
   -profile sigularity \
   --input samplesheet.csv \
   --outdir ./results \
   --genome GATK.GRCh38 \
   --tools strelka,deepvariant,haplotypecaller \
   --max_cpus 16 \
   --max_memory 80.GB



# Method2: use params.yaml as following:

# input: './samplesheet.csv'
# outdir: './results/'
# genome: 'GATK.GRCh38'
# tools:
#   - 'strelka'
#   - 'deepvariant'
# max_cpus: 16
# max_memory: '64.GB'

# nextflow run nf-core/sarek -r 3.8.1 -profile docker -params-file params.yaml   

# 使用内置测试配置（最简单）
# 运行官方测试数据集（chr22 的小片段数据）和小型参考基因组，无需准备 --input 和 --genome，系统会自动使用测试配置

nextflow run nf-core/sarek -r 3.8.1 -profile test,docker --outdir ./test_results

# test profile 会自动下载测试数据（chr22 的小片段数据）和小型参考基因组
# 无需准备 --input 和 --genome，系统会自动使用测试配置 