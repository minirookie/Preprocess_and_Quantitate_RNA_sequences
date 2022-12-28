## Trim adaptors and check the quality for each sample
## Write the following scripts in a .sh file to run the trimming jobs on HPC
#BSUB -P RNASeq_pipeline
#BSUB -n 8
#BSUB -R "rusage[mem=4000]"
#BSUB -R "span[hosts=1]"
#BSUB -oo Jobreport_xxx_TrimAdaptor.out -eo Job_xxx_TrimAdaptor.err
#BSUB -J QConSamples
#BSUB -q standard

fastqc=/research_jude/rgs01_jude/applications/hpcf/apps/fastqc/install/0.11.5/fastqc
cutadapt=/research_jude/rgs01_jude/applications/hpcf/apps/python/install/3.6.1/bin/cutadapt

FQfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
QCoutputPath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial/FASTQC_output_cleanFiles

module load python/3.6.1
$cutadapt -a AGATCGGAAGAG -A AGATCGGAAGAG --trim-n --max-n=0.5 --quality-base=33 -q 30,20 -m 30 \
-o $FQfilepath/xxx_PE1.clean.fq.gz -p $FQfilepath/xxx_PE2.clean.fq.gz $FQfilepath/xxx_PE1.raw.fq.gz $FQfilepath/xxx_PE2.raw.fq.gz

# option explanation:
# 0) For Single-end sequence reads, use $cutadapt -a AGATCGGAAGAG --trim-n --max-n=0.5 --quality-base=33 -q 30 -m 30 -o sample.clean.fq.gz sample.raw.fq.gz
# 1) -m refers to the minimum length. Trimmed reads that are shorter than this value will be discarded. 
# Usually,  20 is used for raw sequences no longer than 50 nucleotides (nt), and 30 for those of over 50 nt. Adjust the value to suit different needs.
# 2) -a/-A are used to trim the 3' adapters.
# 3) --trim-n and --max-n are used to trim the sequence of unknown bases. Disable it if needed.
# 4) --quality-base and -q are used to trim the sequence of low quality. Disable it if needed.
# 5) For more information about cutadapt, check out here: https://cutadapt.readthedocs.io/en/stable/guide.html.

# Run the command fastqc on cleaned fastq files to check the sample quality.
$fastqc $FQfilepath/xxx_PE1.clean.fq.gz -o $QCoutputPath 
$fastqc $FQfilepath/xxx_PE2.clean.fq.gz -o $QCoutputPath

# For Single-end sequence reads, use $fastqc sample.clean.fq.gz -o output_dir

## Write the following looping scripts separately for batch submitting the sequence cleanup
FQfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
for f in $FQfilepath/*.raw.fq.gz; do
name=$(basename $f .raw.fq.gz)
echo ${name/%_PE*/}
cat $FQfilepath/FASTQC_output_cleanFiles/QConFQ_SeTrial_HPCJob.sh | sed -e 's/xxx/'${name/%_PE*/}'/g' > tmp
bsub < tmp
done
