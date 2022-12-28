# .bashrc

# Source global definitions
if [ -f /etc/bashrc.modules ]; then
        . /etc/bashrc.modules
else
        . /etc/bashrc
fi

#Frequently used modules
module load java/1.8.0_66
module load perl/5.10.1
module load samtools
module load svn
module load python/3.6.1
module load R/3.6.1
#module load conda3/5.1.0
#module --ignore-cache load "maven"

PATH=$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
export PATH=$PATH:/research_jude/rgs01_jude/applications/hpcf/apps/homer/install/4.5/bin


# Set up environment for Comp Bio code
source /research_jude/rgs01_jude/resgen/system/sjcbinit/sjcbinit.sh
#source activate /research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/conda_env/bulkRNA-seq/

#alias
alias loadenv_bulkRNAseq='module load conda3/5.1.0; source activate /research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/conda_env/bulkRNA-seq'

setcbenv prod
#cbload phoenix
#cbload util-python
#cbload --set official

# User specific aliases and functions
