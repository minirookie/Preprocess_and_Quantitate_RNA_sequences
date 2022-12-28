## 0.1 If starting from BAM files (e.g., downloaded from some databases), the BAM files of paired-end sequencing 
## MUST be first sorted by individual sequence names (indices). 

## Write the following scripts in a .sh file ("BAM_sort_HPCJob.sh") to run the sorting jobs on HPC
## "#BUSB" can be recognized by HPC to inititate the runs
#! /bin/sh
#BSUB -P RNASeq_pipeline
#BSUB -n 8
#BSUB -R "rusage[mem=2000]"
#BSUB -R "span[hosts=1]"
#BSUB -oo Jobreport_xxx.out -eo Job_xxx.err
#BSUB -J Sorting_xxx
#BSUB -q standard

sortedfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAM/sort_bySYB_Oct2022
bamfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAM
module load samtools

## To sort the BAM files, use "samtools sort -n -o output.sorted input.bam".
## If there is error: "fail to open file output.sorted", use the command instead: samtools sort -n input.bam output.sorted
samtools sort -n $bamfilepath/xxx.bam $sortedfilepath/xxx_sorted 


## Write the following looping scripts separately for batch submitting the sorting jobs
bamfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAM
for f in $bamfilepath/*.bam; do
name=$(basename $f .bam)
echo $name
cat $bamfilepath/sort_bySYB_Oct2022/BAM_sort_HPCJob.sh | sed -e 's/xxx/'$name'/g' > tmp
bsub < tmp
done


## 0.2 convert BAM files into FASTQ files
## Write the following scripts in a .sh file ("GenerateFASTQ_HPCJob_SETrial.sh") to run the preprocessing jobs on HPC
#! /bin/sh
#BSUB -P RNASeq_pipeline
#BSUB -n 8
#BSUB -R "rusage[mem=2000]"
#BSUB -R "span[hosts=1]"
#BSUB -oo Jobreport_xyz.out -eo JobErr_xyz.err
#BSUB -J Convert2FQ_xyz
#BSUB -q standard

bedtools=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/yulab_apps/apps/bedtools2/bin/bedtools
Sortedfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAM/sort_bySYB_Oct2022
FQfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/FASTQ_files_SeTrial

# For single-end sequencing files, using less options
# $bedtools bamtofastq -i input.bam -fq output.raw.fq 

# For pair-end sequencing files, using 
$bedtools bamtofastq -i $Sortedfilepath/xyz_sorted.bam -fq $FQfilepath/xyz_PE1.raw.fq -fq2 $FQfilepath/xyz_PE2.raw.fq


## Write the following looping scripts separately for batch submitting the bam-to-fq conversion jobs
Sortedfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAM/sort_bySYB_Oct2022
FQfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/FASTQ_files_SeTrial
for f in $Sortedfilepath/*.bam; do
name=$(basename $f .bam)
echo ${name/%_sorted/}
cat $FQfilepath/GenerateFASTQ_HPCJob_SETrial.sh | sed -e 's/xyz/'${name/%_sorted/}'/g' > tmp
bsub < tmp
done



## 0.3 Compress the .raw.fq files to allow them viewed afterwards by the zcat command
## Write the following scripts in a .sh ("RunGzip_HPCJob_SeTrial.sh") file to run the compress jobs via HPC
#! /bin/sh
#BSUB -P Compress raw .fq file
#BSUB -n 8
#BSUB -M 5000
#BSUB -R "span[hosts=1]"
#BSUB -oo Gzip_xyz.out -eo Gzip_xyz.err
#BSUB -J Gzip_xyz
#BSUB -q standard

gzip xyz.raw.fq


## Write the following looping scripts separately for batch submitting the compressing jobs
FQfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
for f in $FQfilepath/*.raw.fq; do
name=$(basename $f .raw.fq)
echo ${name}
cat $FQfilepath/RunGzip_HPCJob_SeTrial.sh | sed -e 's/xyz/'${name}'/g' > tmp
bsub < tmp
done



## 0.4  If starting from Fastq file, preprocess to prepare the RAW FASTQ
## If there are multiple fastq files for one sample (usually generated by different lanes), merge files of one sample into one.

# For single-end sequencing
# cat sample1_L001.fq.gz sample1_L002.fq.gz sample1_L003.fq.gz sample1_L004.fq.gz > sample1.raw.fq.gz

# For paired-end sequencing
cat sample1_L001_R1.fq.gz sample1_L002_R1.fq.gz sample1_L003_R1.fq.gz sample1_L004_R1.fq.gz > sample1_R1.raw.fq.gz
cat sample1_L001_R2.fq.gz sample1_L002_R2.fq.gz sample1_L003_R2.fq.gz sample1_L004_R2.fq.gz > sample1_R2.raw.fq.gz
