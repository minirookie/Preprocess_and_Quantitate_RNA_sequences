#! /bin/sh
#BSUB -P RNASeq_pipelines_02
#BSUB -n 8
#BSUB -M 2500
#BSUB -o sample_SalmonQuant.out -e sample_SalmonQuant.err
#BSUB -J SalmonQuant_sample
#BSUB -q standard

#salmon software
salmon=/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/Salmon/bin/salmon

#databases of transcript index references
index_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/Salmon/index_quasi/
index_hg39=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/Salmon/index_quasi/
index_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/Salmon/index_quasi/
tr2gene_hg38=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg38/gencode.release32/Salmon/idmap.tr2gene.txt
tr2gene_hg19=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/hg19/gencode.release32/Salmon/idmap.tr2gene.txt
tr2gene_mm10=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_databases/references/mm10/gencode.releaseM23/Salmon/idmap.tr2gene.txt

#input & output directory
indir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/Salmon_Quanti

#command line to run on pair-end sequencing files
$salmon quant -i $index_hg38 $index_hg39 $index_mm10 -l A -p 8 -g $tr2gene_hg38 $tr2gene_hg39 $tr2gene_mm10 \
-1 $indir/sample_PE1.clean.fq.gz -2 $indir/sample_PE2.clean.fq.gz -o $outdir/sample

# For single-end sequencing, use $salmon quant -i $index -l A -p 8 -g $tr2gene -r $indir/sample.clean.fq.gz -o $outdir/sample



#! /bin/sh
indir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
outdir=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/Salmon_Quanti

for file in $indir/*.clean.fq.gz; do
name=$(basename $file .clean.fq.gz)
echo ${name/%_PE*/}
cat $outdir/SalmonRunonHPC.sh |sed -e 's/sample/'${name/%_PE*/}'/g' > tmp
bsub < tmp
done
