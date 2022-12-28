## 1.1. Trim adaptors via HPC
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
$cutadapt -a AGATCGGAAGAG -A AGATCGGAAGAG --trim-n --max-n=0.5 --quality-base=33 -q 30,20 -m 30 -o $FQfilepath/xxx_PE1.clean.fq.gz -p $FQfilepath/xxx_PE2.clean.fq.gz $FQfilepath/xxx_PE1.raw.fq.gz $FQfilepath/xxx_PE2.raw.fq.gz

$fastqc $FQfilepath/xxx_PE1.clean.fq.gz -o $QCoutputPath 
$fastqc $FQfilepath/xxx_PE2.clean.fq.gz -o $QCoutputPath

## Write the following looping scripts separately for batch submitting the sequence cleanup
FQfilepath=/research_jude/rgs01_jude/groups/yu3grp/projects/RelapseALL/yu3grp/AML/JefferyKlco/SELHEM_RNASeq/BAMprocessing_SYB/FASTQ_files_SeTrial
for f in $FQfilepath/*.raw.fq.gz; do
name=$(basename $f .raw.fq.gz)
echo ${name/%_PE*/}
cat $FQfilepath/FASTQC_output_cleanFiles/QConFQ_SeTrial_HPCJob.sh | sed -e 's/xxx/'${name/%_PE*/}'/g' > tmp
bsub < tmp
done
