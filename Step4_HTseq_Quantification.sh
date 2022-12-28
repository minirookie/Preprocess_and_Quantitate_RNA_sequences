## Write the following scripts in a .sh file ("STAR_HTseq_Genebody_RunonHPC.sh") to run HTSeq mapping and quantification on HPC
#! /bin/sh
#BSUB -P RNASeq_pipelines
#BSUB -n 8
#BSUB -M 5000
#BSUB -oo 04_Sample_STAR&HTseq&Genebody.out -eo 04_Sample_STAR&HTseq&Genebody.err
#BSUB -J 04_STAR&HTseq&Genebody
#BSUB -q standard

#HTSeq software
star=/research_jude/rgs01_jude/applications/hpcf/apps/star/install/2.5.3a/bin/STAR
htseq=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/conda_env/bulkRNA-seq/bin/htseq-count
bedtools=/research_jude/rgs01_jude/applications/hpcf/apps/bedtools/install/2.25.0/bin/bedtools
salmon=/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/Salmon/bin/salmon
genebody=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/git_repo/RNASeq_pipelines/05_genebodyCoverage.R

#reference database for indexing transcripts
index_hg38oh100=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/STAR/index_overhang100
index_hg38oh150=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/STAR/index_overhang150
index_hg19oh100=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/STAR/index_overhang100
index_hg19oh150=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/STAR/index_overhang150
index_mm10oh100=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/STAR/index_overhang100
index_mm10oh150=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/STAR/index_overhang150
binlist_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/binlist_150.txt
binlist_hg19=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/binlist_150.txt
binlist_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/binlist_150.txt
gtf_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/gencode.v32.annotation.gtf
gtf_hg19=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/gencode.v32lift37.annotation.gtf
gtf_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/gencode.vM23.annotation.gtf

#input & output directories
CleanFQPath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
Outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/QuantHTseq_STARalignment_GeneBody

# STAR Alignment for paired-end sequencing
$star --runMode alignReads --runThreadN 8 --twopassMode Basic \
    --quantMode TranscriptomeSAM --outSAMtype BAM SortedByCoordinate --outFileNamePrefix $Outdir/Sample/ \
    --outSAMattrRGline ID:Sample SM:Sample LB:Illumina PL:Illumina PU:Illumina --outSAMattributes All --outSAMunmapped Within \
    --alignIntronMin 20 --alignIntronMax 1000000 --alignSJDBoverhangMin 1 --alignSJoverhangMin 8 --alignMatesGapMax 1000000 \
    --chimJunctionOverhangMin 15 --chimMainSegmentMultNmax 1 --chimSegmentMin 15 --limitSjdbInsertNsj 1200000 --chimOutType SeparateSAMold SoftClip \
    --outFilterMatchNminOverLread 0.33 --outFilterScoreMinOverLread 0.33 --outFilterMismatchNoverLmax 0.1 \
    --outFilterMismatchNmax 999 --outFilterMultimapNmax 20 --outFilterType BySJout --outSAMstrandField intronMotif \
    --readFilesCommand zcat --genomeDir $index_hg38oh100 --readFilesIn $CleanFQPath/SampSubs_PE1.clean.fq.gz $CleanFQPath/SampSubs_PE2.clean.fq.gz
    
# $star options explanation
# 1) --quantMode TranscriptomeSAM: used to generate the alignment to transcriptome. Highly recommended.
# 2) --outSAMattrRGline: edit it everytime.
# 3) --readFilesCommand: zcat for .gz files, bzcat for .bz2 files.
# 4) The GDC mRNA quantification analysis pipeline is followed, https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/.
# 5) check out more information of STAR: https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf.

# HTSeq Quantification
module load python/3.6.1
$htseq -f bam -r pos -s reverse -a 10 -t exon -i gene_id -m intersection-nonempty --nonunique none --secondary-alignments score \
  --supplementary-alignments score $Outdir/Sample/Aligned.out.bam $gtf_hg38 > $Outdir/Sample/htseq_counts.txt
# htseq-count requires libcrypto.so.1.0.0, which may not be properly installed under some python versions. 
# If a error message is generateing saying the libary is missing, try to load the python/3.6.1 to fix it.

# Gene Body Coverage
$samtools sort $Outdir/Sample/Aligned.toTranscriptome.out.bam \
$Outdir/Sample/Aligned.toTranscriptome.out.sorted && $samtools index $Outdir/Sample/Aligned.toTranscriptome.out.sorted.bam
$bedtools multicov -bams $Outdir/Sample/Aligned.toTranscriptome.out.sorted.bam -bed $binlist_hg38 > $Outdir/Sample/readsDistribution.txt
$genebody $Outdir/Sample/readsDistribution.txt $Outdir/Sample/genebodyCoverage
# It is recommended to complete the alignment and quantification runs ($star & $htseq) before and the $genebody run 
# check out here for more information of HTSeq: https://htseq.readthedocs.io/en/release_0.11.1/count.html.

# Key Outputs:
# 1) Aligned.sortedByCoord.out.bam: Alignments to reference genome, sorted by coordinates.
# 2) Aligned.toTranscriptome.out.bam: Alignments to reference transcriptome.
# 3) htseq_counts.txt: HTSeq gene expression quantification, COUNTS.

## Write separately the looping scripts below for batch submitting the above quantification and/or gene body analysis jobs
#! /bin/sh
CleanFQPath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial

Outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/QuantHTseq_STARalignment_GeneBody

for file in $CleanFQPath/*.clean.fq.gz; do
name=$(basename $file .clean.fq.gz)
echo ${name}
# create an output directory
# mkdir $Outdir/Sample
cat $Outdir/STAR_HTseq_Genebody_RunonHPC.sh |sed -e 's/Sample/'${name}'/g'|sed -e 's/SampSubs/'${name/%_PE*/}'/g' > tmp
bsub < tmp
done
