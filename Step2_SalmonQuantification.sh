## Write the following scripts in a .sh file to run salmon quasi-mapping and quantification on HPC
#! /bin/sh
#BSUB -P RNASeq_pipelines_02
#BSUB -n 8
#BSUB -M 2500
#BSUB -o sample_SalmonQuant.out -e sample_SalmonQuant.err
#BSUB -J SalmonQuant_sample
#BSUB -q standard

#locate salmon software
salmon=/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/Salmon/bin/salmon

#databases used as transcript index references
index_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/Salmon/index_quasi/
index_hg39=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/Salmon/index_quasi/
index_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/Salmon/index_quasi/
tr2gene_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/Salmon/idmap.tr2gene.txt
tr2gene_hg19=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/Salmon/idmap.tr2gene.txt
tr2gene_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/Salmon/idmap.tr2gene.txt

#input & output directories
indir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/Salmon_Quanti

#run quantification on pair-end sequencing files
$salmon quant -i $index_hg38 $index_hg39 $index_mm10 -l A -p 8 -g $tr2gene_hg38 $tr2gene_hg39 $tr2gene_mm10 \
-1 $indir/sample_PE1.clean.fq.gz -2 $indir/sample_PE2.clean.fq.gz -o $outdir/sample

# For single-end sequencing, use $salmon quant -i $index -l A -p 8 -g $tr2gene -r $indir/sample.clean.fq.gz -o $outdir/sample
# Output explanations:
# 1) quant.sf: quantification results of transcripts. TPM and COUNTS are included.
# 2) quant.genes.sf: quantification results of genes. TPM and COUNTS are included.
# 3) lib_format_counts.json: library type is predicted: IOM(inward, outward, matching) + SU(stranded, unstranded) + FR(Forward, Reverse)
# 4) check out here for more information: https://salmon.readthedocs.io/en/latest/salmon.html.

# NOTE
# 1) The default index files were generated under k=31. This is recommanded by Salmon, and works well for reads of 75bp or longer.
# If the sequence reads of samples are shorter than 31bp, no hits (transcript match) will be found. In this case, one need to generate the index manually. 
# The scripts to generate the index is the following .sh file
# /research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/Salmon/00_buildIndex_quasi.sh.


## Write separately the looping scripts below for batch submitting the above quantification jobs
#! /bin/sh
indir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/Salmon_Quanti

for file in $indir/*.clean.fq.gz; do
name=$(basename $file .clean.fq.gz)
echo ${name/%_PE*/}
cat $outdir/SalmonRunonHPC.sh |sed -e 's/sample/'${name/%_PE*/}'/g' > tmp
bsub < tmp
done
