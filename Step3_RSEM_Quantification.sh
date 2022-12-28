## Write the following scripts in a .sh file ("RSEMnBowtie2_RunonHPC.sh") to run RSEM mapping and quantification on HPC
#! /bin/sh
#BSUB -P RNASeq_pipelines_GB
#BSUB -n 8
#BSUB -M 2500
#BSUB -oo GB _Sample.out -eo GB_Sample.err
#BSUB -J GB_Sample_Se
#BSUB -q standard

#RSEM and bowtie2 software
rsem=/research_jude/rgs01_jude/applications/hpcf/apps/RSEM/1.3.0/rsem-calculate-expression
bowtie2=/research_jude/rgs01_jude/applications/hpcf/apps/bowtie/install/2.2.9/bin
bedtools=/research_jude/rgs01_jude/applications/hpcf/apps/bedtools/install/2.25.0/bin/bedtools
genebody=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/git_repo/RNASeq_pipelines/05_genebodyCoverage.R

#reference database for indexing transcripts
reference_hg38bowtie2=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/RSEM/index_bowtie2/hg38
reference_hg38star=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/RSEM/index_star/hg38
reference_hg19bowtie2=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/RSEM/index_bowtie2/hg19
reference_hg19star=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/RSEM/index_star/hg19
reference_mm10bowtie2=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/RSEM/index_bowtie2/mm10
reference_mm10star=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/RSEM/index_star/mm10
binlist_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/binlist_150.txt
binlist_hg19=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/binlist_150.txt
binlist_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/binlist_150.txt

#input & output directories
CleanFQPath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/Bowtie2Alignment_RSEMQuanti

# Bowtie2 Alignment and RSEM Quantification on pair-end sequencing files
$rsem -p 8 \
    --bowtie2 --bowtie2-path $bowtie2 --bowtie2-sensitivity-level sensitive \
    --strandedness reverse --sort-bam-by-coordinate --phred33-quals --paired-end \
    $CleanFQPath/Sample_PE1.clean.fq.gz $CleanFQPath/Sample_PE2.clean.fq.gz \
    $reference_hg38bowtie2 $outdir/Sample/quant

# $rsem options explanation
# 1) --strandedness: none|forward|reverse. This information can be obtained from the person prepared the libraries. Otherwise, one needs to figure it out. Salmon is recommended because the Salmon output, lib_format_counts.json, provides this information.
# 2) sorting method: --sort-bam-by-coordinate or --sort-bam-by-read-name.
# 3) BAM Outputs: BAM file of transcriptome is generated by default. Use --no-bam-output to cancal it, or --output-genome-bam to generate the BAM file of genome simultaneously.
# 4) encoding of Phred Scores: --phred33-quals or --phred64-quals. Check the FastQC output, where Phred+33 encoding is listed as Illumina 1.9/Sanger, and Phred+64 as illumina 1.5 or lower.
# 5) check out here for more information: https://github.com/bli25broad/RSEM_tutorial.


#Gene Body Coverage
$bedtools multicov -bams $outdir/Sample/quant.transcript.sorted.bam -bed $binlist_hg38 > $outdir/Sample/readsDistribution.txt
$genebody $outdir/Sample/readsDistribution.txt $outdir/Sample/genebodyCoverage
# RSEM pipeline can be pretty finicky and computing intense. It is better to complete the $rsem and $genebody run subsequentially 

# Output explanations:
# 1) quant.genes.results: quantification results of transcripts/isoforms. TPM, FPKM and COUNTS are provided.
# 2) quant.isoforms.results: quantification results of genes. TPM, FPKM and COUNTS are provided.
# 3) quant.transcript.bam: alignments to reference transcriptome
# 4) quant.transcript.sorted.bam: sorted alignments to reference transcriptome
# 5) quant.transcript.sorted.bam.bai: index of sorted alignments to reference transcriptome

## Write separately the looping scripts below for batch submitting the above quantification jobs
#! /bin/sh
CleanFQPath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/Bowtie2Alignment_RSEMQuanti

for file in $CleanFQPath/*.clean.fq.gz;
do
    name=$(basename $file .clean.fq.gz)
    echo ${name/%_PE*/}
    # mkdir -p $outdir/${name/%_PE*/} $outdir/${name/%_PE*/}/quant.temp $outdir/${name/%_PE*/}/quant.stat
    cat $outdir/RSEMnBowtie2_RunonHPC.sh |sed -e 's/Sample/'${name/%_PE*/}'/g' > tmp
    bsub < tmp
done
