Step 0. Preprocess to prepare the RAW FASTQ
If you have multiple fastq files for each sample, usually generated from different lanes, you need to merge them into one.
If you start from BAM files, usually downloaded from some databases, you need to convert them into FASTQ files.

Step 1. Quality Control of RAQ FASTQ Files by FastQC
Note: From this analysis, we need to figure out the following:

a. Encoding of Phred Scores: Phred+33 is listed as Illumina 1.9/Sanger, while Phred+64 encoding is Illumina 1.5 or lower. (Find more details here: https://sequencing.qcfail.com/articles/incorrect-encoding-of-phred-scores/)
b. Sequence Length: The most common values are 46/45, 76/75, 101/100 or 151/150.
c. Adapter Type: Illumina Universal Adapter(AGATCGGAAGAG), Illumina Small RNA 3' Adapter(TGGAATTCTCGG), Illumina Small RNA 5' Adapter(GATCGTCGGACT), Nextera Transposase Sequence(CTGTCTCTTATA) and SOLID Small RNA Adapter(CGCCTTGGCCGT).

Here is an excellent tutorial for FastQC: https://www.youtube.com/watch?v=bz93ReOv87Y

If no adaptors are found within the RAW FASTQ files, we are done for this step and use the RAW FASTQ files in subsequent analysis. Otherwise, we have to trim the adaptors.

Step 2. Quantification by Salmon
Salmon is alignment-free and hence ultra-fast!
Salmon is easy to use: you need to specify only a few options. Salmon could figure some of the necessary options out by itself.
Just provide the mapping file of transcripts to genes, then it will generate the quantification results of both transcripts and genes.
Salmon predicts the library type by default. If you don't know the library type of your samples, you could use this analysis to identify them.

Step 3. Quantification by RSEM
RSEM is a well-accepted gold standard for RNA-Seq quantification.
RSEM is an alignment-based quantification method, which makes it more complicated to use: you have to specify each essential option.
RSEM generates the BAM file of transcriptomic alignment by default and could also generate a genomic alignment by specifying the corresponding arguments.

Step 4. Quantification by STAR-HTSeq Strategy
GDC recommends the STAR-HTSeq strategy.
The 2-pass STAR alignment is famous for its speed and accuracy.
HTSeq is very popular for quantifying the expression of genes.

Step 5. Gene Body Coverage Analysis
This analysis plots the distributions of reads along the transcripts/gens. It is used to evaluate the quality of the sample library, especially the status of RNA degradation.

Step 6. Quantification Summary
The expression matrix of all samples under a specific quantification method is generated.
The correlation between quantification methods is calculated.
